def var diasAbono as int label 'Dias Abono'.
def var diasFalta as int label 'Dias Falta'.
def var diasGozados as int label 'Dias Gozados'.
def var adtoFerias as int label 'Adto Ferias' init 0.
def var cont as int.
def var coletivas as char init 0.

output to HCM-empregado-Ferias.csv.

put 'CPF;CNPJ_REGISTRO;CNPJ_TOMADOR;DATA_ADMISSAO;MATRICULA;DATA_INICIO_PERIODO_AQUISITIVO;DATA_FIM_PERIODO_AQUISITIVO;QTD_DIAS_DIREITO;QTD_FALTAS_NO_PERIODO_AQUISITIVO;ABONO_PECUNIARIO;QTD_DIAS_ABONO;DATA_INICIO_FERIAS;DATA_FIM_FERIAS;PAGOU_ADTO_DECIMO_TERCEIRO;FERIAS_COLETIVAS;ENCERRA_PA' skip.
    
 for each period_aqst_ferias no-lock
    where period_aqst_ferias.cdn_empresa = '4',
    first funcionario of period_aqst_ferias no-lock,
    first rh_pessoa_fisic of funcionario no-lock,
    first rh_estab of funcionario no-lock
        break by period_aqst_ferias.cdn_empresa
              by period_aqst_ferias.cdn_estab
              by period_aqst_ferias.cdn_funcionario:
    
    Assign diasFalta = 0
    	   diasAbono = 0
           adtoFerias = 0
           diasGozados = 0.    	   
    
    REPEAT cont = 1 TO 5:
        if hcm.period_aqst_ferias.qtd_dias_abdo[cont] <>  0 then
            assign diasAbono = hcm.period_aqst_ferias.qtd_dias_abdo[cont].
    END.

    REPEAT cont = 1 TO 5:
        if hcm.period_aqst_ferias.qtd_dias_gozado[cont] <>  0 then
            assign diasGozados = diasGozados + hcm.period_aqst_ferias.qtd_dias_gozado[cont].
    END.


    find first movto_ferias_calcul where period_aqst_ferias.cdn_funcionario = movto_ferias_calcul.cdn_funcionario
      and movto_ferias_calcul.dat_inic_ferias = hcm.period_aqst_ferias.dat_concess_efetd[1] no-lock no-error.

    if avail movto_ferias_calcul then do: /* Verifica se teve adiantamento de 13o nas f‚rias (eventos 416 e 419) */
      find first movto_calcul_func 
           where movto_calcul_func.cdn_funcionario = period_aqst_ferias.cdn_funcionario
             and movto_calcul_func.cdn_empresa = period_aqst_ferias.cdn_empresa
             and movto_calcul_func.cdn_estab = period_aqst_ferias.cdn_estab
             and year(movto_calcul_func.dat_pagto_salario) = year(movto_ferias_calcul.dat_pagto_salario)
             and month(movto_calcul_func.dat_pagto_salario) = month(movto_ferias_calcul.dat_pagto_salario) no-lock no-error.
    
        if avail movto_calcul_func then do:

            /*Ignorados adiantamentos que ocorrem em Novembro e dezembro*/
            repeat cont = 1 to 30:
                if (hcm.movto_calcul_func.cdn_event_fp[cont] = '416' or hcm.movto_calcul_func.cdn_event_fp[cont] = '419' )
                and (month(movto_calcul_func.dat_pagto_salario) <> 11 and  month(movto_calcul_func.dat_pagto_salario) <> 12) then
                    assign  adtoFerias = 1.
                end.
        end.    
    end.

    
    FOR EACH sit_afast_func 
       WHERE sit_afast_func.cdn_funcionario = funcionario.cdn_funcionario 
         AND dat_inic_sit_afast >= period_aqst_ferias.dat_inic_period_aqst_ferias
         AND dat_inic_sit_afast <= period_aqst_ferias.dat_term_period_aqst_ferias
         AND cdn_sit_afast_func = 50  /* Faltas */ :
         
        ASSIGN diasFalta = diasFalta + 1.
        
    END.


    if avail movto_ferias_calcul and (movto_ferias_calcul.cdn_empresa = '3' and month(movto_ferias_calcul.dat_inic_ferias) = 12 and day(movto_ferias_calcul.dat_inic_ferias) > 15) then do:
        coletivas = '1'.
    end.



        export delimiter ';'
         string(rh_pessoa_fisic.cod_id_feder)                                       /* CPF */
         hcm.rh_estab.cod_id_feder                                                  /* CNPJ_REGISTRO */
         ''                                                                         /* CNPJ_TOMADOR  */
         hcm.funcionario.dat_admis_func                                             /* DATA_ADMISSAO */ 
         hcm.funcionario.cdn_funcionario                                            /* MATRICULA */
         hcm.period_aqst_ferias.dat_inic_period_aqst_ferias                         /* DATA_INICIO_PERIODO_AQUISITIVO */
         hcm.period_aqst_ferias.dat_term_period_aqst_ferias                         /* DATA_FIM_PERIODO_AQUISITIVO */ 
         hcm.period_aqst_ferias.qtd_dias_direito_period_aqst                        /* QTD_DIAS_DIREITO */
         diasFalta				                                                    /* QTD_FALTAS_NO_PERIODO_AQUISITIVO */
         (if diasAbono > 0 then  1 else 0) label 'ABONO'                            /* ABONO_PECUNIARIO */
         diasAbono                                                                  /* QTD_DIAS_ABONO */
         if dat_concess_efetd[1] = ? then '' else string(dat_concess_efetd[1])      /* DATA_INICIO_FERIAS */
         if dat_concess_efetd[1] = ? then '' else string(dat_concess_efetd[1] + (qtd_dias_direito_period_aqst - diasAbono)) /* DATA_FIM_FERIAS */
         adtoFerias                                                                 /* PAGOU_ADTO_DECIMO_TERCEIRO */
         coletivas                                                                  /* FERIAS_COLETIVAS' */
         if (diasGozados + diasAbono) = qtd_dias_direito_period_aqst then 1 else 0  /* ENCERRA_PA */
         .   
        
end.

output close.
