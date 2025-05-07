DEFINE variable v_caminho   as char.
DEFINE variable v_depend    as integer.
DEFINE VARIABLE v_reglivfol as char.

ASSIGN v_caminho   = 'HCM-funcionario-dependente.csv'.

PROCEDURE retornaGrauParentesco:
DEFINE INPUT PARAMETER tipoHCM as integer.
DEFINE OUTPUT PARAMETER tipoWFP as integer.
    assign tipoWFP = 7. /* Outros */
    case tipoHCM:
        when  1 THEN assign tipoWFP = 4. /* Filho */
        when  2 THEN assign tipoWFP = 2. /* Conjuge */
        when  3 THEN assign tipoWFP = 8. /* Pais */
        when  4 THEN assign tipoWFP = 1. /* Companheiro */
        when  5 THEN assign tipoWFP = 7. /* Outros */
        when  6 THEN assign tipoWFP = 7. /* Outros */
        when  7 THEN assign tipoWFP = 7. /* Outros */
    end case.
END PROCEDURE.

OUTPUT TO VALUE(v_caminho) convert target 'iso8859-1'.

PUT 'CPF;CPF_dependente;Nome_dependente;Data_nascimento;Sexo;Grau_parentesco;Data_inativacao_dependente;Dependente_para_IRRF;Deficiente;Frequenta_creche;Frequenta_escola;Data_entrega_carteira_vacinacao;Data_entrega_frequencia_escolar;Nome_cartorio;Registro_livro_folha;Data_entrega_certidao_nascimento;Estado_civil;RG;Orgao_emissor;Data_expedicao_RG;UF_RG;Data_casamento;Nome_mae_dependente;Nome_solteira_mae_dependente;Numero_cartao_nacional_saude;Numero_declaracao_nascido_vivo;Data_inativacao_IRRF' skip.

FOR EACH depend_func WHERE cdn_empresa = '4' :

    ASSIGN v_depend    = 0.
    ASSIGN v_reglivfol = ''.

    RUN retornaGrauParentesco(depend_func.idi_grau_depen_func, OUTPUT v_depend).

    IF depend_func.num_reg_certid_depend <> 0 THEN
        ASSIGN v_reglivfol = string(depend_func.num_reg_certid_depend).

    IF string(depend_func.cod_livro_anot_depend) <> '' THEN DO:
        IF v_reglivfol <> '' THEN
            ASSIGN v_reglivfol = v_reglivfol + '/' + string(depend_func.cod_livro_anot_depend).
        ELSE
            ASSIGN v_reglivfol = string(depend_func.cod_livro_anot_depend).
    END.
    IF string(depend_func.cod_folha_anot_depend) <> '' THEN DO:
        IF v_reglivfol <> '' THEN
            ASSIGN v_reglivfol = v_reglivfol + '/' + string(depend_func.cod_folha_anot_depend).
        ELSE
            ASSIGN v_reglivfol = string(depend_func.cod_folha_anot_depend).
    END.

    FIND FIRST funcionario OF depend_func NO-LOCK NO-ERROR.

    EXPORT DELIMITER ';'
        IF AVAIL funcionario THEN funcionario.cod_id_feder ELSE ''
            IF AVAIL funcionario THEN
                IF substr(depend_func.cod_livre_1,1,11) <> funcionario.cod_id_feder THEN substr(depend_func.cod_livre_1,1,11) ELSE ''
            ELSE ''
        depend_func.nom_depend_func
        depend_func.dat_nascimento
        depend_func.idi_sexo 
        v_depend
        '' /* Data_inativacao_dependente */
        IF (depend_func.idi_inciden_depend = 1) OR (depend_func.idi_inciden_depend = 2) THEN '1' ELSE '0'
        IF depend_func.idi_estado_saude_depend <> 1 THEN '1' ELSE '0'
        '' /* Frequenta_creche */
        IF depend_func.log_estudan = YES THEN '1' ELSE '0'
        '' /* Data_entrega_carteira_vacinacao */
        IF depend_func.dat_apres_comprov_freq <> ? THEN string(depend_func.dat_apres_comprov_freq) ELSE ''
        depend_func.nom_cartor_reg_depend
        v_reglivfol
        IF depend_func.dat_livre_1 <> ? THEN STRING(depend_func.dat_livre_1) ELSE '' /* Data_entrega_certidao_nascimento */
        '' /* Estado_civil */
	 '' /* RG */
	 '' /* Orgao_emissor */
	 '' /* Data_expedicao_RG */
	 '' /* UF_RG */
	 '' /* Data_casamento */
	 depend_func.cod_livre_2 /* Nome_mae_dependente */
        '' /* Nome_solteira_mae_dependente */
        depend_func.cod_cartao_nac_saude
        substr(depend_func.cod_livre_1,74,20) /* Numero_declaracao_nascido_vivo */
        '' /* Data_inativacao_IRRF */
        .
END.         
OUTPUT CLOSE.

