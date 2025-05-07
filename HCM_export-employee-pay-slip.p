DEFINE VARIABLE i                AS integer.
DEFINE VARIABLE v_caminho        as char.
DEFINE VARIABLE v_CodMot         as integer.
DEFINE VARIABLE v_QtdDepIR       as integer.
DEFINE VARIABLE v_QtdDepSF       as integer.
DEFINE VARIABLE v_DataFinal      as char.
DEFINE VARIABLE v_ValorDepIR     AS DECIMAL.
DEFINE VARIABLE v_ValorBaseDepIR AS DECIMAL.
DEFINE VARIABLE v_ValorDepSF     AS DECIMAL.
DEFINE VARIABLE v_ValorBaseDepSF AS DECIMAL.
DEFINE VARIABLE v_Base           AS DECIMAL.
DEFINE VARIABLE v_BaseSF         AS DECIMAL.
DEFINE VARIABLE v_Tipo           AS char.
DEFINE VARIABLE v_SalFam         AS LOGICAL.

DEFINE BUFFER bmovto_calcul_func FOR movto_calcul_func.


ASSIGN v_caminho = 'HCM-holerite-4 (2016).csv'.

OUTPUT TO VALUE(v_caminho) convert target 'iso8859-1'.
PUT 'CPF;CNPJ_REGISTRO;CNPJ_TOMADOR;DATA_ADMISSAO;MATRICULA;TIPO_FOLHA;DATA_PAGAMENTO;MES;ANO;QTDE_DEPENDENTES_IRRF;QTDE_DEPENDENTES_SF;CODIGO_VERBA;DESCRICAO_VERBA;PERCENTUAL_VERBA;QUANTIDADE_REFERENCIA;VALOR_VERBA;VALOR_BASE;TIPO' skip.

FOR EACH movto_calcul_func NO-LOCK
   WHERE movto_calcul_func.cdn_empresa = '4' 
     AND movto_calcul_func.num_ano_refer_fp = 2016
     /*AND cdn_funcionario = 4000031*/
      BREAK BY movto_calcul_func.cdn_empresa
            BY movto_calcul_func.cdn_estab
            BY movto_calcul_func.cdn_funcionario
            BY movto_calcul_func.num_ano_refer_fp
            BY movto_calcul_func.num_mes_refer_fp
            BY movto_calcul_func.idi_tip_fp :
    
    FIND FIRST rh_estab OF movto_calcul_func NO-LOCK NO-ERROR.

    FIND FIRST funcionario OF movto_calcul_func NO-LOCK NO-ERROR.
    IF NOT AVAIL funcionario THEN
        NEXT.

    FIND FIRST rh_clien OF funcionario NO-LOCK NO-ERROR.

    ASSIGN v_Base = 0.
    ASSIGN v_SalFam = FALSE.
    assign v_BaseSF = 0.

    /* Valor Salario Familia: evento 261 */
    DO i = 1 TO movto_calcul_func.qti_efp :
        ASSIGN v_BaseSF     = 0.
        ASSIGN v_SalFam     = false.
        ASSIGN v_ValorDepSF = 0.

             find first bmovto_calcul_func no-lock
                  WHERE bmovto_calcul_func.cdn_empresa       = movto_calcul_func.cdn_empresa
                    AND bmovto_calcul_func.num_ano_refer_fp  = movto_calcul_func.num_ano_refer_fp
                    AND bmovto_calcul_func.cdn_funcionario   = movto_calcul_func.cdn_funcionario
                    AND bmovto_calcul_func.cdn_empresa       = movto_calcul_func.cdn_empresa
                    AND bmovto_calcul_func.cdn_estab         = movto_calcul_func.cdn_estab
                    AND bmovto_calcul_func.cdn_funcionario   = movto_calcul_func.cdn_funcionario
                    AND bmovto_calcul_func.num_ano_refer_fp  = movto_calcul_func.num_ano_refer_fp
                    AND bmovto_calcul_func.num_mes_refer_fp  = movto_calcul_func.num_mes_refer_fp
                    AND bmovto_calcul_func.cdn_event_fp[i]   = '261' no-error.
                    if avail bmovto_calcul_func and v_BaseSF = 0 then do:
                                 ASSIGN v_BaseSF     = bmovto_calcul_func.val_base_calc_fp[i].
                                 ASSIGN v_SalFam     = TRUE.
                                 ASSIGN v_ValorDepSF = bmovto_calcul_func.val_calcul_efp[i].
                                 assign i = 30.
                    END. 
    end.

 
    DO i = 1 TO movto_calcul_func.qti_efp :

        ASSIGN v_ValorBaseDepIR = 1
               v_ValorDepIR     = 0.

        FIND FIRST event_fp WHERE event_fp.cdn_event_fp = movto_calcul_func.cdn_event_fp[i] NO-LOCK NO-ERROR.
        IF NOT AVAIL event_fp THEN
            NEXT.

        /* Dependentes IR: base do evento 511 (INSS Normal) */
        IF (movto_calcul_func.cdn_event_fp[i] = '511') THEN DO:
            ASSIGN v_Base = movto_calcul_func.val_base_calc_fp[i].
        END.

        /* Tabela de faixas de valores de IR e SF */
        FIND FIRST tab_irf_inss WHERE tab_irf_inss.num_ano_refer_tab_irf_inss = movto_calcul_func.num_ano_refer_fp
                                  AND tab_irf_inss.num_mes_refer_tab_irf_inss = movto_calcul_func.num_mes_refer_fp NO-LOCK NO-ERROR.
        IF AVAIL tab_irf_inss THEN DO:
            ASSIGN v_ValorBaseDepIR = tab_irf_inss.val_deduc_depend_irf.
            IF v_BaseSF <= tab_irf_inss.val_lim_faixa_salfam[1] THEN
                ASSIGN v_ValorBaseDepSF = tab_irf_inss.val_salfam_correspte_faixa[1].
            ELSE IF v_BaseSF <= tab_irf_inss.val_lim_faixa_salfam[2] THEN
                ASSIGN v_ValorBaseDepSF = tab_irf_inss.val_salfam_correspte_faixa[2].
        END.

        /* Dependentes IR */
        ASSIGN v_QtdDepIR = 0.
        FIND FIRST irf_rendto_mestre WHERE irf_rendto_mestre.cdn_empresa         = movto_calcul_func.cdn_empresa
                                       AND irf_rendto_mestre.cdn_estab           = movto_calcul_func.cdn_estab
                                       AND irf_rendto_mestre.cdn_funcionario     = movto_calcul_func.cdn_funcionario
                                       AND irf_rendto_mestre.num_ano_refer_fp    = movto_calcul_func.num_ano_refer_fp NO-LOCK NO-ERROR.
        IF AVAIL irf_rendto_mestre THEN DO:
            FIND FIRST irf_rendto OF irf_rendto_mestre WHERE irf_rendto.idi_tip_inform_dirf = 1 NO-LOCK NO-ERROR.
            IF AVAIL irf_rendto THEN DO:
                ASSIGN v_ValorDepIR = irf_rendto.val_depend_func[movto_calcul_func.num_mes_refer_fp].
                ASSIGN v_QtdDepIR   = TRUNCATE(v_ValorDepIR / v_ValorBaseDepIR,0).
            END.
        END.


        /* Dependentes SF */
        ASSIGN v_QtdDepSF = 0.
        IF v_SalFam THEN DO:
            ASSIGN v_QtdDepSF = TRUNCATE(v_ValorDepSF / v_ValorBaseDepSF,0).
            IF movto_calcul_func.num_mes_refer_fp = 1 THEN
                
        END.


        ASSIGN v_Tipo = ''.
        IF (event_fp.idi_ident_efp = 1) THEN 
            ASSIGN v_Tipo = 'V'.
        ELSE IF (event_fp.idi_ident_efp = 2) THEN 
            ASSIGN v_Tipo = 'D'.
        ELSE IF (event_fp.idi_ident_efp = 3) THEN
            ASSIGN v_Tipo = 'O'.

        EXPORT DELIMITER ';'
            funcionario.cod_id_feder
            IF AVAIL rh_estab THEN rh_estab.cod_id_feder ELSE ''
            IF AVAIL rh_clien THEN rh_clien.cod_cgc_cpf ELSE ''
            funcionario.dat_admis_func
            funcionario.cdn_funcionario
            IF movto_calcul_func.idi_tip_fp = 4 THEN '6' ELSE string(movto_calcul_func.idi_tip_fp)
            movto_calcul_func.dat_pagto_salario
            movto_calcul_func.num_mes_refer_fp
            movto_calcul_func.num_ano_refer_fp
            v_QtdDepIR
            v_QtdDepSF
            movto_calcul_func.cdn_event_fp[i]
            event_fp.des_event_fp
            IF (event_fp.val_tax_multcao_val_unit <> 1) THEN string(event_fp.val_tax_multcao_val_unit * 100) ELSE ''
            movto_calcul_func.qtd_unid_event_fp[i]
            movto_calcul_func.val_calcul_efp[i]
            movto_calcul_func.val_base_calc_fp[i]
            v_Tipo.
    END.

END.

OUTPUT CLOSE.
