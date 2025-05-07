DEFINE variable v_caminho  as char.
DEFINE VARIABLE v_CodCid   as integer.
DEFINE variable v_NomeCid  as char.
DEFINE variable v_UF       as char.
DEFINE variable v_CBO      as char.
DEFINE variable v_DescCBO  as char.
DEFINE variable v_TipoVinc as integer.
DEFINE VARIABLE v_codNac   as integer.
DEFINE VARIABLE v_TipoAut  as integer.

ASSIGN v_caminho = 'HCM-autonomo.csv'.

PROCEDURE verificaUF:
    DEFINE INPUT PARAMETER cod_cidade as integer NO-UNDO.
    DEFINE OUTPUT PARAMETER estado as CHAR NO-UNDO.
    assign estado = ''.
    case cod_cidade:
        when  1 THEN assign estado = 'PR'.
        when  2 THEN assign estado = 'RS'.
        when  3 THEN assign estado = 'RS'.
        when  4 THEN assign estado = 'ES'.        
        when  5 THEN assign estado = 'PR'.        
        when  6 THEN assign estado = 'PR'.        
        when  7 THEN assign estado = 'SC'.
        when  8 THEN assign estado = 'SP'.        
        when  9 THEN assign estado = 'SC'.        
        when 10 THEN assign estado = 'MG'.        
        when 11 THEN assign estado = 'GO'.
        when 12 THEN assign estado = 'RJ'.
        when 13 THEN assign estado = 'PE'.
        when 14 THEN assign estado = 'MS'.
        when 15 THEN assign estado = 'DF'.
        when 16 THEN assign estado = 'BA'.
        when 17 THEN assign estado = 'CE'.
        when 18 THEN assign estado = 'PR'.
        when 19 THEN assign estado = 'PR'.
        when 20 THEN assign estado = 'SP'.
        when 21 THEN assign estado = 'PR'.
        when 22 THEN assign estado = 'ES'.
        when 23 THEN assign estado = 'PR'.
        when 24 THEN assign estado = 'PR'.
        when 25 THEN assign estado = 'SP'.
        when 26 THEN assign estado = 'GO'.
        when 27 THEN assign estado = 'MG'.
        when 28 THEN assign estado = 'SP'.
        when 29 THEN assign estado = 'SP'.
        when 30 THEN assign estado = 'SP'.
        when 31 THEN assign estado = 'RS'.
        when 32 THEN assign estado = 'PR'.
        when 33 THEN assign estado = 'PR'.
        when 34 THEN assign estado = 'PR'.
        when 35 THEN assign estado = 'PR'.
        when 36 THEN assign estado = 'SC'.
        when 37 THEN assign estado = 'RO'.
        when 38 THEN assign estado = 'AM'.
        when 39 THEN assign estado = 'PR'.
        when 40 THEN assign estado = 'SC'.
        when 41 THEN assign estado = 'PR'.
        when 42 THEN assign estado = 'PR'.
        when 43 THEN assign estado = 'PR'.
        when 44 THEN assign estado = 'MG'.
        when 45 THEN assign estado = 'MT'.
        when 46 THEN assign estado = 'PR'.
        when 47 THEN assign estado = 'PR'.
    end case.
END PROCEDURE.

PROCEDURE verificaCidade:
    DEFINE INPUT PARAMETER  codEmpresa as char.
    DEFINE INPUT PARAMETER  codEstab   as char.
    DEFINE INPUT PARAMETER  ccusto     as char.
    DEFINE OUTPUT PARAMETER codCid     as integer.
    DEFINE OUTPUT PARAMETER nomeCid    as char.
    ASSIGN codCid  = 0
           nomeCid = ''.
    IF (codEmpresa <> '3') THEN DO: /* Se nao for JM Construtora, obter Cidade do Complemento Estabelecimento */
        FOR EACH estab_localid WHERE estab_localid.cdn_empresa = codEmpresa 
                                 AND estab_localid.cdn_estab   = codEstab NO-LOCK 
                            BREAK BY estab_localid.cdn_localidade :
            ASSIGN codCid = MIN(codCid , estab_localid.cdn_localidade).
        END.
    END.
    ELSE DO: /* Se for JMCO, obter cidade da obra ou Curitiba (CCs administrativos) */
        CASE ccusto:
        WHEN '1335256' THEN ASSIGN codCid = 18.
        WHEN '1335259' THEN ASSIGN codCid = 8.
        WHEN '1335262' THEN ASSIGN codCid = 18.
        WHEN '1335263' THEN ASSIGN codCid = 43.
        WHEN '1335271' THEN ASSIGN codCid = 22.
        WHEN '1335273' THEN ASSIGN codCid = 26.
        WHEN '1335276' THEN ASSIGN codCid = 44.
        WHEN '1335277' THEN ASSIGN codCid = 45.
        WHEN '1335294' THEN ASSIGN codCid = 27.
        WHEN '1335295' THEN ASSIGN codCid = 46.
        WHEN '1335297' THEN ASSIGN codCid = 47.
        WHEN '1335298' THEN ASSIGN codCid = 32.
        WHEN '1335309' THEN ASSIGN codCid = 18.
        WHEN '1335310' THEN ASSIGN codCid = 47.
        WHEN '1335320' THEN ASSIGN codCid = 37.
        WHEN '1335323' THEN ASSIGN codCid = 47.
        WHEN '1335325' THEN ASSIGN codCid = 18.
        WHEN '1335351' THEN ASSIGN codCid = 32.
        OTHERWISE 
            ASSIGN codCid = 1.
        END CASE.
    END.
    FIND FIRST localidade WHERE localidade.cdn_localidade = codCid NO-LOCK NO-ERROR.
    IF AVAIL localidade THEN 
        ASSIGN nomeCid = localidade.des_localidade.
END PROCEDURE.

PROCEDURE retornaNacionalidade:
    DEFINE INPUT  PARAMETER codHCM as char.
    DEFINE OUTPUT PARAMETER codWFP as integer.
    assign codWFP = 10.
    case codHCM:
        when  'BRA' THEN assign codWFP = 10. /* Brasileiro */
        when  'ARG' THEN assign codWFP = 21. /* Argentino */
        when  'BOL' THEN assign codWFP = 22. /* Boliviano */
        when  'URU' THEN assign codWFP = 25. /* Uruguaio */
        when  'ALE' THEN assign codWFP = 30. /* Alemao */
        when  'EUA' THEN assign codWFP = 36. /* Norte-americano */
        when  'FRA' THEN assign codWFP = 37. /* Frances */
        when  'HTI' THEN assign codWFP = 40. /* Haitiano */
        when  'JAP' THEN assign codWFP = 41. /* Japones */
        when  'POR' THEN assign codWFP = 45. /* Portugues */
        when  'LAT' THEN assign codWFP = 48. /* Outros latino-americanos */
        when  'OUT' THEN assign codWFP = 80. /* Outros */
    end case.
END PROCEDURE.

OUTPUT TO VALUE(v_caminho) convert target 'iso8859-1'.

PUT 'CPF;NOME;SEXO;NACIONALIDADE;DATA_NASCIMENTO;PIS;CNPJ_EMPRESA;NOME_CR;ESTRUTURA_CR;TIPO_DO_AUTONOMO;NOME_FUNCAO;CBO;NUMERO_DO_ALVARA;DATA_INICIO_VIGENCIA_ALVARA;DATA_FIM_VIGENCIA_ALVARA;EXPOSICAO_AGENTES_NOCIVOS;CIDADE_LOCALIDADE_PRESTACAO_SERVICO;UF_LOCALIDADE_PRESTACAO_SERVICO;DESCRICAO_SERVICO;PERCENTUAL_ISS;DATA_PAGAMENTO;CODIGO_VERBA;DESCRICAO_VERBA;PERCENTUAL_VERBA;QUANTIDADE_REFERENCIA;VALOR_VERBA' skip.

FOR EACH movto_serv_prestad_terc WHERE movto_serv_prestad_terc.cdn_empresa = '4' AND movto_serv_prestad_terc.dat_refer_movto_prestdor_serv >= 01/01/2011:

    FIND FIRST rh_estab OF movto_serv_prestad_terc NO-LOCK NO-ERROR.
    IF NOT AVAIL rh_estab THEN
        NEXT.
        
    FIND FIRST prestdor_serv OF movto_serv_prestad_terc NO-LOCK NO-ERROR.
    IF NOT AVAIL prestdor_serv THEN
        NEXT.

    FIND FIRST rh_ccusto OF movto_serv_prestad_terc NO-LOCK NO-ERROR.

    FIND FIRST tip_serv_ext OF prestdor_serv NO-LOCK NO-ERROR.

    ASSIGN v_CBO = ''
           v_DescCBO = ''.
    IF trim(substr(prestdor_serv.cod_livre_1,4,6)) = '' THEN
        ASSIGN v_CBO = 'Ocupacao nao informada'.
    ELSE DO:
        ASSIGN v_CBO = trim(substr(prestdor_serv.cod_livre_1,4,6)).
        FIND FIRST classif_ocupac WHERE classif_ocupac.cod_classif_ocupac = v_CBO NO-LOCK NO-ERROR.
        IF AVAIL classif_ocupac THEN
            ASSIGN v_DescCBO = classif_ocupac.des_classif_ocupac.
        ELSE
            ASSIGN v_DescCBO = 'Ocupacao nao informada'.
    END.

    IF prestdor_serv.idi_tip_prestdor_serv = 1 THEN DO: /* Fisica */
        FIND FIRST rh_pessoa_fisic WHERE rh_pessoa_fisic.num_pessoa_fisic = prestdor_serv.num_pessoa NO-LOCK NO-ERROR.
        IF NOT AVAIL rh_pessoa_fisic THEN
            NEXT.
    END.
    ELSE
        NEXT.

    ASSIGN v_CodCid  = 0
           v_NomeCid = ''
           v_UF      = ''.
    RUN verificaCidade(movto_serv_prestad_terc.cdn_empresa, movto_serv_prestad_terc.cdn_estab, movto_serv_prestad_terc.cod_rh_ccusto, OUTPUT v_CodCid, OUTPUT v_NomeCid).
    RUN verificaUF(v_CodCid, OUTPUT v_UF).

    ASSIGN v_codNac = 0.
    RUN retornaNacionalidade(rh_pessoa_fisic.cod_pais_nasc, OUTPUT v_codNac).

    ASSIGN v_TipoAut = 1.
    IF prestdor_serv.log_motorista = YES THEN
        IF prestdor_serv.idi_tip_transp = 1 THEN /* Carga */
            ASSIGN v_TipoAut = 2.

    EXPORT DELIMITER ';'
        rh_pessoa_fisic.cod_id_feder
        rh_pessoa_fisic.nom_pessoa_fisic
        rh_pessoa_fisic.idi_sexo
        v_CodNac
        IF rh_pessoa_fisic.dat_nascimento <> ? THEN string(rh_pessoa_fisic.dat_nascimento) ELSE '01/01/1900'
        prestdor_serv.cdd_func_inss
        rh_estab.cod_id_feder
        IF AVAIL rh_ccusto THEN rh_ccusto.des_rh_ccusto ELSE ''
        movto_serv_prestad_terc.cod_rh_ccusto
        v_TipoAut
        v_DescCBO
        v_CBO
        '' /* Alvara */
        '' /* Inicio vigencia alvara */
        '' /* Fim vigencia alvara */
        '00' /* Nao ha exposicao a agente nocivo */
        v_NomeCid
        v_UF
        IF AVAIL tip_serv_ext THEN tip_serv_ext.des_tip_serv_ext ELSE 'Ocupacao nao informada'
        prestdor_serv.val_perc_aliq_iss
        movto_serv_prestad_terc.dat_pagto_prestdor
        '-1' /* Criar no WFP o codigo */
        'Valor do servico prestado'
        '0' /* Percentual da verba */
        '0' /* Quantidade referencia */
        movto_serv_prestad_terc.val_brut_docto_movto_serv_ter /* Valor do servico prestado */
        .

    EXPORT DELIMITER ';'
        rh_pessoa_fisic.cod_id_feder
        rh_pessoa_fisic.nom_pessoa_fisic
        rh_pessoa_fisic.idi_sexo
        v_CodNac
        IF rh_pessoa_fisic.dat_nascimento <> ? THEN string(rh_pessoa_fisic.dat_nascimento) ELSE '01/01/1900'
        prestdor_serv.cdd_func_inss
        rh_estab.cod_id_feder
        IF AVAIL rh_ccusto THEN rh_ccusto.des_rh_ccusto ELSE ''
        movto_serv_prestad_terc.cod_rh_ccusto
        v_TipoAut
        v_DescCBO
        v_CBO
        '' /* Alvara */
        '' /* Inicio vigencia alvara */
        '' /* Fim vigencia alvara */
        '00' /* Nao ha exposicao a agente nocivo */
        v_NomeCid
        v_UF
        IF AVAIL tip_serv_ext THEN tip_serv_ext.des_tip_serv_ext ELSE 'Ocupacao nao informada'
        prestdor_serv.val_perc_aliq_iss
        movto_serv_prestad_terc.dat_pagto_prestdor
        '-2' /* Criar no WFP o codigo */
        'SEST/SENAT'
        '0' /* Percentual da verba */
        '0' /* Quantidade referencia */
        movto_serv_prestad_terc.val_livre_1 /* Valor do SEST/SENAT */
        .

    EXPORT DELIMITER ';'
        rh_pessoa_fisic.cod_id_feder
        rh_pessoa_fisic.nom_pessoa_fisic
        rh_pessoa_fisic.idi_sexo
        v_CodNac
        IF rh_pessoa_fisic.dat_nascimento <> ? THEN string(rh_pessoa_fisic.dat_nascimento) ELSE '01/01/1900'
        prestdor_serv.cdd_func_inss
        rh_estab.cod_id_feder
        IF AVAIL rh_ccusto THEN rh_ccusto.des_rh_ccusto ELSE ''
        movto_serv_prestad_terc.cod_rh_ccusto
        v_TipoAut
        v_DescCBO
        v_CBO
        '' /* Alvara */
        '' /* Inicio vigencia alvara */
        '' /* Fim vigencia alvara */
        '00' /* Nao ha exposicao a agente nocivo */
        v_NomeCid
        v_UF
        IF AVAIL tip_serv_ext THEN tip_serv_ext.des_tip_serv_ext ELSE 'Ocupacao nao informada'
        prestdor_serv.val_perc_aliq_iss
        movto_serv_prestad_terc.dat_pagto_prestdor
        '-3' /* Criar no WFP o codigo */
        'Imposto de Renda na Fonte'
        '0' /* Percentual da verba */
        '0' /* Quantidade referencia */
        movto_serv_prestad_terc.val_irf_retid /* Imposto de Renda na Fonte */
        .

    EXPORT DELIMITER ';'
        rh_pessoa_fisic.cod_id_feder
        rh_pessoa_fisic.nom_pessoa_fisic
        rh_pessoa_fisic.idi_sexo
        v_CodNac
        IF rh_pessoa_fisic.dat_nascimento <> ? THEN string(rh_pessoa_fisic.dat_nascimento) ELSE '01/01/1900'
        prestdor_serv.cdd_func_inss
        rh_estab.cod_id_feder
        IF AVAIL rh_ccusto THEN rh_ccusto.des_rh_ccusto ELSE ''
        movto_serv_prestad_terc.cod_rh_ccusto
        v_TipoAut
        v_DescCBO
        v_CBO
        '' /* Alvara */
        '' /* Inicio vigencia alvara */
        '' /* Fim vigencia alvara */
        '00' /* Nao ha exposicao a agente nocivo */
        v_NomeCid
        v_UF
        IF AVAIL tip_serv_ext THEN tip_serv_ext.des_tip_serv_ext ELSE 'Ocupacao nao informada'
        prestdor_serv.val_perc_aliq_iss
        movto_serv_prestad_terc.dat_pagto_prestdor
        '-4' /* Criar no WFP o codigo */
        'INSS SEG'
        '0' /* Percentual da verba */
        '0' /* Quantidade referencia */
        movto_serv_prestad_terc.val_deduc_inss_irf /* INSS SEG */
        .

    EXPORT DELIMITER ';'
        rh_pessoa_fisic.cod_id_feder
        rh_pessoa_fisic.nom_pessoa_fisic
        rh_pessoa_fisic.idi_sexo
        v_CodNac
        IF rh_pessoa_fisic.dat_nascimento <> ? THEN string(rh_pessoa_fisic.dat_nascimento) ELSE '01/01/1900'
        prestdor_serv.cdd_func_inss
        rh_estab.cod_id_feder
        IF AVAIL rh_ccusto THEN rh_ccusto.des_rh_ccusto ELSE ''
        movto_serv_prestad_terc.cod_rh_ccusto
        v_TipoAut
        v_DescCBO
        v_CBO
        '' /* Alvara */
        '' /* Inicio vigencia alvara */
        '' /* Fim vigencia alvara */
        '00' /* Nao ha exposicao a agente nocivo */
        v_NomeCid
        v_UF
        IF AVAIL tip_serv_ext THEN tip_serv_ext.des_tip_serv_ext ELSE 'Ocupacao nao informada'
        prestdor_serv.val_perc_aliq_iss
        movto_serv_prestad_terc.dat_pagto_prestdor
        '-5' /* Criar no WFP o codigo */
        'ISS'
        '0' /* Percentual da verba */
        '0' /* Quantidade referencia */
        movto_serv_prestad_terc.val_iss_terc /* ISS */
        .

END.         
OUTPUT CLOSE.

