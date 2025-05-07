def var v_movEntrada as char.
def var v_movSaida as char.
def var v_dtFim as char.

output to HCM-empregado-dpartamento-4.CSV.

put 'CPF;CNPJ_REGISTRO;CNPJ_TOMADOR;DATA_ADMISSAO;MATRICULA;NOME_DO_DEPARTAMENTO;DATA_INICIO_DA_VIGENCIA;DATA_FIM_DA_VIGENCIA;MOVIMENTACAO_ENTRADA;MOVIMENTACAO_SAIDA' skip .

for each func_unid_lotac_plano no-lock
   where func_unid_lotac_plano.cdn_empresa = '4',
     /*and func_unid_lotac_plano.cdn_funcionario = 10074,*/
    first unid_lotac of func_unid_lotac_plano no-lock,
    first funcionario of func_unid_lotac_plano no-lock,
    first rh_pessoa_fisic of funcionario no-lock,
    first rh_estab of funcionario no-lock
      BREAK BY func_unid_lotac_plano.cdn_empresa
			BY func_unid_lotac_plano.cdn_estab
			BY func_unid_lotac_plano.cdn_funcionario
			BY func_unid_lotac_plano.dat_inic_lotac_func :

    find first rh_clien of funcionario no-lock no-error.
        
    IF funcionario.dat_desligto_func <> ? THEN DO:
        ASSIGN v_movEntrada = '3'  /* Transferencia interna */
               v_movSaida = '3'.  /* Transferencia interna */

        IF funcionario.dat_admis_func = func_unid_lotac_plano.dat_inic_lotac_func THEN
            ASSIGN v_movEntrada = '1'. /* Admissao */

        IF funcionario.dat_desligto_func = func_unid_lotac_plano.dat_fim_lotac_func or last-of(func_unid_lotac_plano.cdn_funcionario) THEN
        			    ASSIGN v_movSaida = '2'. /* Rescisao */
	
        for first sit_afast_func WHERE sit_afast_func.cdn_empresa        = func_unid_lotac_plano.cdn_empresa
                                  AND sit_afast_func.cdn_estab          = func_unid_lotac_plano.cdn_estab
                                  AND sit_afast_func.cdn_funcionario    = func_unid_lotac_plano.cdn_funcionario
                                  AND sit_afast_func.dat_inic_sit_afast = func_unid_lotac_plano.dat_fim_lotac_func NO-LOCK :
            
                    IF sit_afast_func.cdn_sit_afast_func = 40 then do:
                        
                                if  (hcm.sit_afast_func.cdn_empres_orig = hcm.sit_afast_func.cdn_empresa) and v_movSaida <> '2' then
                                    ASSIGN v_movEntrada = '3'. /*Entrada por transferencia Interna */
                                else 
                                    ASSIGN v_movEntrada = '4'. /*Entrada por transferencia Externa*/
        
                                if  (hcm.sit_afast_func.cdn_empres_dest = hcm.sit_afast_func.cdn_empresa) then
                                    ASSIGN v_movSaida = '3'. /*Entrada por transferencia Interna */
                                else 
                                    ASSIGN v_movSaida = '4'. /*Entrada por transferencia Externa*/
                    end.

                    if sit_afast_func.cdn_sit_afast_func = 45 THEN
                        ASSIGN v_movSaida = '3'. /*Saida por transferencia interna */
            
                    if sit_afast_func.cdn_sit_afast_func = 46 THEN
                        ASSIGN v_movSaida = '4'. /*Saida por transferencia externa */   
        end.
        
	END.
   ELSE DO:
           assign v_movEntrada = '3'. /* Transferencia interna */
                  v_movSaida   = '3'. /* Transferencia interna */

        IF funcionario.dat_admis_func = func_unid_lotac_plano.dat_inic_lotac_func THEN
            ASSIGN v_movEntrada = '1'. /* Admissao */

         if  hcm.func_unid_lotac_plano.dat_fim_lotac_func = 12/31/9999 and v_movSaida <> '' then
           assign v_movSaida   = ''. /* Lota‡Æo Ativa */
          
         IF funcionario.dat_desligto_func = func_unid_lotac_plano.dat_fim_lotac_func or last-of(func_unid_lotac_plano.cdn_funcionario) THEN
			ASSIGN v_movSaida = '2'. /* Rescisao */
	
        for first sit_afast_func WHERE sit_afast_func.cdn_empresa = func_unid_lotac_plano.cdn_empresa
                             AND sit_afast_func.cdn_estab          = func_unid_lotac_plano.cdn_estab
                             AND sit_afast_func.cdn_funcionario    = func_unid_lotac_plano.cdn_funcionario
                             AND sit_afast_func.dat_inic_sit_afast = func_unid_lotac_plano.dat_inic_lotac_func NO-LOCK :
        
            IF sit_afast_func.cdn_sit_afast_func = 40 then do:
                if  (hcm.sit_afast_func.cdn_empres_orig = hcm.sit_afast_func.cdn_empresa) and v_movSaida <> '2' then
                    ASSIGN v_movEntrada = '3'. /*Entrada por transferencia Interna */
                else 
                    ASSIGN v_movEntrada = '4'. /*Entrada por transferencia Externa*/


                 if  (hcm.sit_afast_func.cdn_empres_dest = hcm.sit_afast_func.cdn_empresa) then
                    ASSIGN v_movSaida = '3'. /*Entrada por transferencia Interna */
                else 
                    ASSIGN v_movSaida = '4'. /*Entrada por transferencia Externa*/

            end.
            if sit_afast_func.cdn_sit_afast_func = 45 THEN
                ASSIGN v_movSaida = '3'. /* Saida por transferencia interna */
            
            if sit_afast_func.cdn_sit_afast_func = 46 THEN
                ASSIGN v_movSaida = '4'. /* Saida por transferencia externa */
       end.

      
       
	END.

     find first hcm.func_reinteg no-lock
          where hcm.func_reinteg.cdn_funcionario         =  func_unid_lotac_plano.cdn_funcionario
            and hcm.func_reinteg.cdn_estab               =  func_unid_lotac_plano.cdn_estab
            and hcm.func_reinteg.cdn_empresa             =  func_unid_lotac_plano.cdn_empresa
            and hcm.func_reinteg.dat_admis_func_origin   >= func_unid_lotac_plano.dat_inic_lotac_func
            and hcm.func_reinteg.dat_admis_func_origin   <= func_unid_lotac_plano.dat_fim_lotac_func no-error.


            assign v_dtFim = string(hcm.func_unid_lotac_plano.dat_fim_lotac_func).

            if hcm.func_unid_lotac_plano.dat_fim_lotac_func = 12/31/9999 then 
                assign v_dtFim = ''
                       v_movSaida = ''.


            if avail hcm.func_reinteg then 
                assign v_movEntrada = '7'.

                export delimiter ';'
                hcm.rh_pessoa_fisic.cod_id_feder               /* CPF */
                hcm.rh_estab.cod_id_feder                      /* CNPJ_REGISTRO */
                if avail rh_clien then cod_cgc_cpf else ''     /* CNPJ_TOMADOR             */
                hcm.funcionario.dat_admis_func                 /* DATA_ADMISSAO            */
                hcm.funcionario.cdn_funcionario                /* MATRICULA                */
                hcm.unid_lotac.des_unid_lotac                  /* NOME_DO_DEPARTAMENTO     */ /* verificar o uso do c¢digo hcm.func_unid_lotac_plano.cod_unid_lotac *****/      
                hcm.func_unid_lotac_plano.dat_inic_lotac_func  /* DATA_INICIO_DA_VIGENCIA  */
                if v_movEntrada = '7' then string(hcm.func_reinteg.dat_demis_func_origin) else v_dtFim   /* DATA_FIM_DA_VIGENCIA     */
                if v_movEntrada = '7' then '3' else v_movEntrada /* MOVIMENTACAO_ENTRADA     */
                if v_movEntrada = '7' then '2' else v_movSaida   /* MOVIMENTACAO_SAIDA       */ .


                if v_movEntrada = '7' then do:
                    export delimiter ';'
                            hcm.rh_pessoa_fisic.cod_id_feder               /* CPF */
                            hcm.rh_estab.cod_id_feder                      /* CNPJ_REGISTRO */
                            if avail rh_clien then cod_cgc_cpf else ''     /* CNPJ_TOMADOR             */
                            hcm.funcionario.dat_admis_func                 /* DATA_ADMISSAO            */
                            hcm.funcionario.cdn_funcionario                /* MATRICULA                */
                            hcm.unid_lotac.des_unid_lotac                  /* NOME_DO_DEPARTAMENTO     */ /* verificar o uso do c¢digo hcm.func_unid_lotac_plano.cod_unid_lotac *****/      
                            hcm.func_reinteg.dat_reinteg_func_fp           /* DATA_INICIO_DA_VIGENCIA  */
                            hcm.func_unid_lotac_plano.dat_fim_lotac_func   /* DATA_FIM_DA_VIGENCIA     */
                            v_movEntrada                                   /* MOVIMENTACAO_ENTRADA     */
                            v_movSaida                                     /* MOVIMENTACAO_SAIDA       */ 
                            .
                end.
                
end.

output close.


/******************************************************************************************/
/* 1 - AdmissÆo                 2 - RescisÆo                 3 - Transferˆncia Interna    */
/* 4 - Transferˆncia Externa    5 - Inativa‡Æo               6 - Reativa‡Æo               */
/* 7 - Reintegra‡Æo                                                                       */
/******************************************************************************************/
