DEFINE VARIABLE v_caminho   as char.
DEFINE VARIABLE v_CodMot    as integer.
DEFINE VARIABLE v_DataFinal as char.

ASSIGN v_caminho = 'HCM-funcionario-salario-4.csv'.

PROCEDURE retornaDataFinal:
    DEFINE INPUT  PARAMETER empresa     as char.
    DEFINE INPUT  PARAMETER estab       as char.
    DEFINE INPUT  PARAMETER funcionario as integer.
    DEFINE INPUT  PARAMETER dataRef     as date.
    DEFINE INPUT  PARAMETER dataDeslig  as date.
    DEFINE INPUT  PARAMETER numSeq      as integer.
    DEFINE OUTPUT PARAMETER data        as char.
    DEFINE BUFFER b_HistorSalFunc for histor_sal_func.
    IF dataDeslig <> ? THEN
        ASSIGN data = string(dataDeslig).
    ELSE
        ASSIGN data = ''.
    FIND FIRST b_HistorSalFunc
         WHERE b_HistorSalFunc.cdn_empresa     = empresa
           AND b_HistorSalFunc.cdn_estab       = estab
           AND b_HistorSalFunc.cdn_funcionario = funcionario
           AND ((b_HistorSalFunc.dat_liber_sal > dataRef) OR
                (b_HistorSalFunc.dat_liber_sal = dataRef AND b_HistorSalFunc.num_seq_histor_sal > numSeq))
           NO-LOCK NO-ERROR.
        IF AVAIL b_HistorSalFunc THEN
            ASSIGN data = string(b_HistorSalFunc.dat_liber_sal - 1).
END PROCEDURE.

PROCEDURE retornaMotivo:
    DEFINE INPUT  PARAMETER empresa     as char.
    DEFINE INPUT  PARAMETER estab       as char.
    DEFINE INPUT  PARAMETER funcionario as integer.
    DEFINE INPUT  PARAMETER dataRef     as date.
    DEFINE INPUT  PARAMETER salario     as decimal.
    DEFINE INPUT  PARAMETER cargo       as integer.
    DEFINE INPUT  PARAMETER codHCM      as integer.
    DEFINE INPUT  PARAMETER numSeq      as integer.
    DEFINE OUTPUT PARAMETER codWFP      as integer.
    DEFINE BUFFER b_HistorSalFunc for histor_sal_func.
    ASSIGN codWFP = -1.
    CASE codHCM:
        WHEN   0 THEN ASSIGN codWFP  = 1. /* Admissao */
        WHEN   5 THEN ASSIGN codWFP  = 8. /* Antecipacao Reajuste/Dissidio */
        WHEN   6 THEN ASSIGN codWFP  = 8. /* Antecipacao Reajuste/Dissidio */
        WHEN  10 THEN ASSIGN codWFP = 15. /* Acordo Sindical */
        WHEN  11 THEN ASSIGN codWFP = 15. /* Acordo Sindical */
        WHEN  15 THEN ASSIGN codWFP =  3. /* Merito */
        WHEN  20 THEN ASSIGN codWFP =  4. /* Promocao */
        WHEN  25 THEN ASSIGN codWFP = 11. /* Transferencia */
        WHEN  30 THEN ASSIGN codWFP = 12. /* Alteracao de Empresa */
        WHEN  35 THEN ASSIGN codWFP = 13. /* Alteracao de Estabelecimento */
        WHEN  40 THEN ASSIGN codWFP =  6. /* Ajuste de categoria */
        WHEN  45 THEN ASSIGN codWFP =  7. /* Alteracao de carga horaria */
        WHEN  50 THEN ASSIGN codWFP = 14. /* Alteracao de Cargo */
        WHEN  55 THEN ASSIGN codWFP = 20. /* Aumento cfe salario minimo */
        WHEN  60 THEN DO: 
            ASSIGN codWFP = 10. /* Ajuste de cadastro (situacao nao informada) */
            FIND FIRST b_HistorSalFunc
                 WHERE b_HistorSalFunc.cdn_empresa     = empresa
                   AND b_HistorSalFunc.cdn_estab       = estab
                   AND b_HistorSalFunc.cdn_funcionario = funcionario
                   AND b_HistorSalFunc.dat_liber_sal   < dataRef NO-LOCK NO-ERROR.
            IF AVAIL b_HistorSalFunc THEN
                IF (b_HistorSalFunc.cdn_cargo_basic <> cargo) AND (b_HistorSalFunc.val_salario_mensal = salario) THEN
                    ASSIGN codWFP = 9. /* Enquadramento */
                ELSE IF (b_HistorSalFunc.cdn_cargo_basic = cargo) AND (b_HistorSalFunc.val_salario_mensal <> salario) THEN
                    ASSIGN codWFP = 2. /*  Termino do contrato experiencia */
        END.
        WHEN  65 THEN ASSIGN codWFP = 10. /* Ajuste de cadastro */
        WHEN  70 THEN ASSIGN codWFP = 10. /* Ajuste de cadastro */
        WHEN  75 THEN ASSIGN codWFP =  9. /* Enquadramento */
        WHEN  80 THEN ASSIGN codWFP = 19. /* Equiparacao salarial */
        WHEN  85 THEN ASSIGN codWFP = 16. /* Espontaneo */
        WHEN  90 THEN ASSIGN codWFP = 22. /* Incorporacao */
        WHEN  95 THEN ASSIGN codWFP = 18. /* Piso da categoria */
        WHEN 100 THEN ASSIGN codWFP = 23. /* Reajuste por Lei */
        WHEN 105 THEN ASSIGN codWFP = 22. /* Incorporacao */
        WHEN 110 THEN ASSIGN codWFP = 22. /* Incorporacao */
        WHEN 115 THEN ASSIGN codWFP = 10. /* Ajuste de cadastro */
        WHEN 120 THEN ASSIGN codWFP =  5. /* Dissidio coletivo */
    END CASE.
END PROCEDURE.

OUTPUT TO VALUE(v_caminho) convert target 'iso8859-1'.
PUT 'CPF;CNPJ_REGISTRO;CNPJ_TOMADOR;DATA_ADMISSAO;MATRICULA;DATA_INICIAL;DATA_FINAL;TIPO_PAGAMENTO;VALOR;MOTIVO' skip.

FOR EACH histor_sal_func WHERE histor_sal_func.cdn_empresa = '4' NO-LOCK 
      BREAK BY histor_sal_func.cdn_empresa
            BY histor_sal_func.cdn_estab
            BY histor_sal_func.cdn_funcionario
            BY histor_sal_func.dat_liber_sal
            BY histor_sal_func.val_salario_categ:

    FIND FIRST rh_estab OF histor_sal_func NO-LOCK NO-ERROR.
    FIND FIRST cargo_basic OF histor_sal_func NO-LOCK NO-ERROR.

    FIND FIRST funcionario OF histor_sal_func NO-LOCK NO-ERROR.
    IF NOT AVAIL funcionario THEN
        NEXT.

    FIND FIRST rh_clien OF funcionario NO-LOCK NO-ERROR.

    ASSIGN v_CodMot = 0.
/*
    IF funcionario.dat_admis_func = histor_sal_func.dat_liber_sal THEN
        ASSIGN v_CodMot = 1. /* Admissao */
    ELSE
*/    
        RUN retornaMotivo(histor_sal_func.cdn_empresa, histor_sal_func.cdn_estab, histor_sal_func.cdn_funcionario, histor_sal_func.dat_liber_sal, histor_sal_func.val_salario_mensal, histor_sal_func.cdn_cargo_basic, histor_sal_func.cdn_motiv_liber_sal, histor_sal_func.num_seq_histor_sal, OUTPUT v_CodMot).

    RUN retornaDataFinal(histor_sal_func.cdn_empresa, histor_sal_func.cdn_estab, histor_sal_func.cdn_funcionario, histor_sal_func.dat_liber_sal, funcionario.dat_desligto_func, histor_sal_func.num_seq_histor_sal, OUTPUT v_DataFinal).

    EXPORT DELIMITER ';'
        funcionario.cod_id_feder
        IF AVAIL rh_estab THEN rh_estab.cod_id_feder ELSE ''
        IF AVAIL rh_clien THEN rh_clien.cod_cgc_cpf ELSE ''
        funcionario.dat_admis_func
        funcionario.cdn_funcionario
        histor_sal_func.dat_liber_sal
        v_DataFinal
        funcionario.cdn_categ_sal /* 1-Mensalista , 2-Horista */
        IF funcionario.cdn_categ_sal = 1 THEN histor_sal_func.val_salario_categ ELSE histor_sal_func.val_salario_hora
        v_CodMot
        .

END.

OUTPUT CLOSE.

