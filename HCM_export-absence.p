DEFINE VARIABLE v_caminho     as char.
DEFINE VARIABLE v_MotivoAfast as integer.
DEFINE VARIABLE v_ClassAfast  as integer.
DEFINE BUFFER   b_SitAfast    for sit_afast_func.

ASSIGN v_caminho = 'HCM-afastamento-4.csv'.

PROCEDURE retornaMotivoAfast:
    DEFINE INPUT PARAMETER tipoAfastHCM AS INTEGER.
    DEFINE OUTPUT PARAMETER tipoAfastWFP AS INTEGER.
    assign tipoAfastWFP = -1.
    case tipoAfastHCM:
        when 5 THEN assign tipoAfastWFP  = 11. /* Afastado por acidente */
        when 8 THEN assign tipoAfastWFP  = 0.  /* Atestado medico */
        when 10 THEN assign tipoAfastWFP = 1.  /* Afastado por doenca */
        when 12 THEN assign tipoAfastWFP = 0.  /* Atestado medico */
        when 13 THEN assign tipoAfastWFP = 5.  /* Licenca nojo */
        when 14 THEN assign tipoAfastWFP = 2.  /* Licenca gala */
        when 15 THEN assign tipoAfastWFP = 3.  /* Afastado maternidade */
        when 16 THEN assign tipoAfastWFP = 0.  /* Atestado medico por hora */
        when 17 THEN assign tipoAfastWFP = 1.  /* Auxilio doenca mesmo CID */
        when 19 THEN assign tipoAfastWFP = 3.  /* Prorroga licenca maternidade */
        when 20 THEN assign tipoAfastWFP = 6.  /* Licenca paternidade */
        when 25 THEN assign tipoAfastWFP = 9.  /* Afastado servico militar */
        when 30 THEN assign tipoAfastWFP = 4.  /* Licenca nao remunerada */
        when 35 THEN assign tipoAfastWFP = 7.  /* Licenca remunerada */
        when 41 THEN assign tipoAfastWFP = 11. /* Afastado por acidente 30 dias */
        when 42 THEN assign tipoAfastWFP = 1.  /* Afastamento por doenca 30 dias */
        when 44 THEN assign tipoAfastWFP = 0.  /* Atestado medico 30 dias */
        when 48 THEN assign tipoAfastWFP = -2. /* Lei Pele (criar) */
        when 66 THEN assign tipoAfastWFP = 7.  /* Licenca sindical remunerada */
        when 67 THEN assign tipoAfastWFP = 4.  /* Licenca sindical nao remunerada */
        when 87 THEN assign tipoAfastWFP = 4.  /* Suspensao contrato de trabalho */
        when 88 THEN assign tipoAfastWFP = 10. /* Trabalho no exterior */
        when 92 THEN assign tipoAfastWFP = -3. /* Suspensao por reclusao (habilitar) */
    end case.
END PROCEDURE.

OUTPUT TO VALUE(v_caminho) convert target 'iso8859-1'.
PUT 'CPF;CNPJ_REGISTRO;CNPJ_TOMADOR;DATA_ADMISSAO;MATRICULA;MOTIVO;CLASSIFICACAO_AFASTAMENTO;DATA_INICIO_AFASTAMENTO;DATA_FIM_AFASTAMENTO;DATA_PARTO_ADOCAO' skip.

FOR EACH sit_afast_func WHERE sit_afast_func.cdn_empresa = '4' NO-LOCK :

    FIND FIRST sit_afast   OF sit_afast_func NO-LOCK NO-ERROR.
    FIND FIRST funcionario OF sit_afast_func NO-LOCK NO-ERROR.
    FIND FIRST rh_estab    OF sit_afast_func NO-LOCK NO-ERROR.

    IF AVAIL funcionario THEN
        FIND FIRST rh_clien of funcionario NO-LOCK NO-ERROR.

    ASSIGN v_MotivoAfast = 0.
        RUN retornaMotivoAfast(sit_afast_func.cdn_sit_afast_func, OUTPUT v_MotivoAfast).

    /* Eventos de ponto ou sem relacionamento */
    IF v_MotivoAfast = -1 THEN
        NEXT.

    ASSIGN v_ClassAfast = 0.
    /* Auxilio doenca */
    IF (sit_afast_func.cdn_sit_afast_func = 10) THEN
        ASSIGN v_ClassAfast = 8.
        /* CID informada */
        IF (sit_afast_func.cod_livre_1 <> '') THEN DO: 
            ASSIGN v_ClassAfast = 8. /* Doenca nao relacionada ao trabalho */
            FIND FIRST b_SitAfast 
                 WHERE b_SitAfast.cdn_empresa        = sit_afast_func.cdn_empresa
                   AND b_SitAfast.cdn_estab          = sit_afast_func.cdn_estab
                   AND b_SitAfast.cdn_funcionario    = sit_afast_func.cdn_funcionario
                   AND b_SitAfast.dat_inic_sit_afast < sit_afast_func.dat_inic_sit_afast
                   AND b_SitAfast.cdn_sit_afast_func = sit_afast_func.cdn_sit_afast_func
                   AND b_SitAfast.cod_livre_1        = sit_afast_func.cod_livre_1  NO-LOCK NO-ERROR.
                IF AVAIL b_SitAfast THEN
                    ASSIGN v_ClassAfast = 14. /* Reinicio de tratamento */
        END.

    /* Licenca maternidade */
    ELSE IF v_MotivoAfast = 3 THEN DO:
        IF sit_afast_func.cdn_sit_afast_func = 19 THEN /* Prorrogacao de licenca maternidade */
            ASSIGN v_ClassAfast = 2. /* Empresa cidada */
        ELSE
            ASSIGN v_ClassAfast = 1. /* INSS */
    END.

    /* Seguro acidente de trabalho */
    ELSE IF v_MotivoAfast = 8 THEN
        ASSIGN v_ClassAfast = 9. /* Acidente de trabalho tipico */

    /* Aposentadoria por invalidez */
    ELSE IF v_MotivoAfast = 12 THEN
        ASSIGN v_ClassAfast = 11. /* Decorrente de acodente de trabalho */

    EXPORT DELIMITER ';'
        IF AVAIL funcionario THEN funcionario.cod_id_feder ELSE ''
        IF AVAIL rh_estab    THEN rh_estab.cod_id_feder ELSE ''
        IF AVAIL rh_clien    THEN rh_clien.cod_cgc_cpf ELSE ''
        IF AVAIL funcionario THEN string(funcionario.dat_admis_func) ELSE ''
        sit_afast_func.cdn_funcionario
        v_MotivoAfast
        IF v_ClassAfast > 0 THEN v_ClassAfast ELSE ''
        sit_afast_func.dat_inic_sit_afast
        sit_afast_func.dat_term_sit_afast
        IF (v_MotivoAfast = 3) THEN string(sit_afast_func.dat_inic_sit_afast) ELSE ''
        .
END.         
OUTPUT CLOSE.

