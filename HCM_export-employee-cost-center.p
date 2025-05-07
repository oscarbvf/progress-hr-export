DEFINE VARIABLE v_caminho   as char.
DEFINE VARIABLE v_CodMotEnt as integer.
DEFINE VARIABLE v_CodMotSai as integer.

ASSIGN v_caminho = 'HCM-funcionario-CR-4.csv'.

OUTPUT TO VALUE(v_caminho) convert target 'iso8859-1'.
PUT 'CPF;CNPJ_REGISTRO;CNPJ_TOMADOR;DATA_ADMISSAO;MATRICULA;NOME_CR;ESTRUTURA_CR;DATA_INICIO_DA_VIGENCIA;DATA_FIM_DA_VIGENCIA;MOVIMENTACAO_ENTRADA;MOVIMENTACAO_SAIDA' skip.

FOR EACH func_ccusto WHERE func_ccusto.cdn_empresa = '4' /*AND func_ccusto.cdn_funcionario = 4100030*/ NO-LOCK 
		BREAK BY func_ccusto.cdn_empresa
			BY func_ccusto.cdn_estab
			BY func_ccusto.cdn_funcionario
			BY func_ccusto.dat_inic_lotac_func :

    FIND FIRST rh_estab   OF func_ccusto NO-LOCK NO-ERROR.
    FIND FIRST rh_ccusto  OF func_ccusto NO-LOCK NO-ERROR.

    FIND FIRST funcionario OF func_ccusto NO-LOCK NO-ERROR.
    IF NOT AVAIL funcionario THEN
        NEXT.

    FIND FIRST rh_clien OF funcionario NO-LOCK NO-ERROR.

    ASSIGN v_CodMotEnt = 3  /* Transferencia interna */
           v_CodMotSai = 3. /* Transferencia interna */

    IF funcionario.dat_admis_func = func_ccusto.dat_inic_lotac_func THEN DO:
        ASSIGN v_CodMotEnt = 1. /* Admissao */
    END.
	 
    IF funcionario.dat_desligto_func <> ? THEN DO:
        IF (LAST-OF(func_ccusto.cdn_funcionario) OR (funcionario.dat_desligto_func = func_ccusto.dat_fim_lotac_func)) THEN
	    ASSIGN v_CodMotSai = 2. /* Rescisao */

        FIND FIRST sit_afast_func WHERE sit_afast_func.cdn_empresa = func_ccusto.cdn_empresa
                             AND sit_afast_func.cdn_estab          = func_ccusto.cdn_estab
                             AND sit_afast_func.cdn_funcionario    = func_ccusto.cdn_funcionario
                             AND sit_afast_func.dat_inic_sit_afast = func_ccusto.dat_fim_lotac_func NO-LOCK NO-ERROR.
        IF AVAIL sit_afast_func THEN DO:
            IF sit_afast_func.cdn_sit_afast_func = 45 THEN /* Transferencia de estabelecimento/filial */
                ASSIGN v_CodMotSai = 4. /* Saida por transferencia externa */
            IF sit_afast_func.cdn_sit_afast_func = 46 THEN /* Transferencia de empresa */
                ASSIGN v_CodMotSai = 4. /* Saida por transferencia externa */
            IF sit_afast_func.cdn_sit_afast_func = 40 THEN /* Entrada por transferencia */
                ASSIGN v_CodMotEnt = 4. /* Entrada por transferencia externa */
        END.
        ELSE DO:
            FIND FIRST sit_afast_func WHERE sit_afast_func.cdn_empresa = func_ccusto.cdn_empresa
                                 AND sit_afast_func.cdn_estab          = func_ccusto.cdn_estab
                                 AND sit_afast_func.cdn_funcionario    = func_ccusto.cdn_funcionario
                                 AND sit_afast_func.dat_inic_sit_afast = func_ccusto.dat_inic_lotac_func NO-LOCK NO-ERROR.
            IF AVAIL sit_afast_func THEN
                IF sit_afast_func.cdn_sit_afast_func = 40 THEN /* Entrada por transferencia */
                    ASSIGN v_CodMotEnt = 4. /* Entrada por transferencia externa */
        END.
    END.
    ELSE DO:
        FIND FIRST sit_afast_func WHERE sit_afast_func.cdn_empresa = func_ccusto.cdn_empresa
                             AND sit_afast_func.cdn_estab          = func_ccusto.cdn_estab
                             AND sit_afast_func.cdn_funcionario    = func_ccusto.cdn_funcionario
                             AND sit_afast_func.dat_inic_sit_afast = func_ccusto.dat_inic_lotac_func NO-LOCK NO-ERROR.
        IF AVAIL sit_afast_func THEN
            IF sit_afast_func.cdn_sit_afast_func = 40 THEN /* Entrada por transferencia */
                ASSIGN v_CodMotEnt = 4. /* Entrada por transferencia externa */
        FIND FIRST sit_afast_func WHERE sit_afast_func.cdn_empresa = func_ccusto.cdn_empresa
                             AND sit_afast_func.cdn_estab          = func_ccusto.cdn_estab
                             AND sit_afast_func.cdn_funcionario    = func_ccusto.cdn_funcionario
                             AND sit_afast_func.dat_inic_sit_afast = func_ccusto.dat_fim_lotac_func NO-LOCK NO-ERROR.
        IF AVAIL sit_afast_func THEN DO:
            IF sit_afast_func.cdn_sit_afast_func = 45 THEN /* Transferencia de estabelecimento/filial */
                ASSIGN v_CodMotSai = 4. /* Saida por transferencia externa */
            IF sit_afast_func.cdn_sit_afast_func = 46 THEN /* Transferencia de empresa */
                ASSIGN v_CodMotSai = 4. /* Saida por transferencia externa */
	 END.
    END.

    FIND FIRST func_reinteg NO-LOCK
          WHERE func_reinteg.cdn_funcionario          = func_ccusto.cdn_funcionario
            AND func_reinteg.cdn_estab                = func_ccusto.cdn_estab
            AND func_reinteg.cdn_empresa              = func_ccusto.cdn_empresa
            AND func_reinteg.dat_admis_func_origin   >= func_ccusto.dat_inic_lotac_func
            AND func_reinteg.dat_admis_func_origin   <= func_ccusto.dat_fim_lotac_func  NO-ERROR.
    IF AVAIL func_reinteg THEN
        ASSIGN v_CodMotEnt = 7. /* Reintegracao */
	
    EXPORT DELIMITER ';'
        funcionario.cod_id_feder
        IF AVAIL rh_estab THEN rh_estab.cod_id_feder ELSE ''
        IF AVAIL rh_clien THEN rh_clien.cod_cgc_cpf ELSE ''
        funcionario.dat_admis_func
        funcionario.cdn_funcionario
        rh_ccusto.des_rh_ccusto
        rh_ccusto.cod_rh_ccusto
        func_ccusto.dat_inic_lotac_func
        IF v_CodMotEnt = 7 THEN string(func_reinteg.dat_demis_func_origin) ELSE IF string(func_ccusto.dat_fim_lotac_func) = '31/12/9999' THEN '' ELSE string(func_ccusto.dat_fim_lotac_func)
        IF v_CodMotEnt = 7 THEN '3' ELSE string(v_CodMotEnt)
        IF v_CodMotEnt = 7 THEN '2' ELSE IF string(func_ccusto.dat_fim_lotac_func) = '31/12/9999' THEN '' ELSE string(v_CodMotSai)
        func_ccusto.cdn_empresa /* DEBUG */
        func_ccusto.cdn_estab   /* DEBUG */
        IF AVAIL sit_afast_func THEN string(sit_afast_func.cdn_sit_afast_func) ELSE ''
        .

	/* Reintegracao: adicionar registro especifico */
	IF v_CodMotEnt = 7 THEN
		EXPORT DELIMITER ';'
			funcionario.cod_id_feder
			IF AVAIL rh_estab THEN rh_estab.cod_id_feder ELSE ''
			IF AVAIL rh_clien THEN rh_clien.cod_cgc_cpf ELSE ''
			funcionario.dat_admis_func
			funcionario.cdn_funcionario
			rh_ccusto.des_rh_ccusto
			rh_ccusto.cod_rh_ccusto
			func_reinteg.dat_reinteg_func_fp
			func_ccusto.dat_fim_lotac_func
			v_CodMotEnt
			v_CodMotSai
			.
		
END.         
OUTPUT CLOSE.

