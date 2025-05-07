DEFINE variable v_caminho  as char.
DEFINE VARIABLE v_DatInic  as char.
DEFINE VARIABLE v_DatFim   as char.

ASSIGN v_caminho = 'HCM-arvore-centro-resultado-4.csv'.

OUTPUT TO VALUE(v_caminho) convert target 'iso8859-1'.
PUT 'ESTRUTURA;NOME_CR;APELIDO_NIVEL;CODIGO_REDUZIDO;DATA_INICIO_VIGENCIA;DATA_FIM_VIGENCIA;CPF_RESPONSAVEL;PERMITE_LANCAMENTO;CNPJ_FILIAL' skip.

FOR EACH rh_ccusto /* WHERE rh_ccusto.cdn_empresa = '4' NO-LOCK */ :

	FOR EACH rh_estab WHERE rh_estab.cdn_empresa = rh_ccusto.cdn_empresa NO-LOCK:

		IF integer(rh_ccusto.cod_rh_ccusto) = 0 THEN /* CC de uso interno */
			NEXT.

		ASSIGN v_DatInic = '01/01/2016'.
		FIND FIRST func_ccusto WHERE func_ccusto.cdn_empresa = rh_ccusto.cdn_empresa AND func_ccusto.cod_rh_ccusto = rh_ccusto.cod_rh_ccusto NO-LOCK NO-ERROR.
		IF AVAIL func_ccusto THEN 
			ASSIGN v_DatInic = string(func_ccusto.dat_inic_lotac_func).

		ASSIGN v_DatFim = ''.
		IF rh_ccusto.log_livre_2 = NO THEN DO: /* CC inativo */
			FIND LAST func_ccusto WHERE func_ccusto.cdn_empresa = rh_ccusto.cdn_empresa AND func_ccusto.cod_rh_ccusto = rh_ccusto.cod_rh_ccusto NO-LOCK NO-ERROR.
			IF AVAIL func_ccusto THEN 
				ASSIGN v_DatFim = string(func_ccusto.dat_fim_lotac_func).
		END.

		EXPORT DELIMITER ';'
			rh_ccusto.cod_rh_ccusto
			rh_ccusto.des_rh_ccusto
			''
			rh_ccusto.cod_rh_ccusto
			v_DatInic
			v_DatFim
			''
			'1'
			rh_estab.cod_id_feder
			.
	END.
END.         
OUTPUT CLOSE.

