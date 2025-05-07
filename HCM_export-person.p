DEFINE VARIABLE v_caminho     as char.
DEFINE VARIABLE v_codNac      as integer.
DEFINE VARIABLE v_DatChegPais as char.
DEFINE VARIABLE v_CidNasc     as char.
DEFINE VARIABLE v_UFNasc      as char.
DEFINE VARIABLE v_EstCiv      as integer.
DEFINE VARIABLE v_Raca        as integer.
DEFINE VARIABLE v_Escol       as integer.
DEFINE VARIABLE v_Defic       as integer.
DEFINE VARIABLE v_PaisPasp    as char.
DEFINE VARIABLE v_TipSan      as integer.
DEFINE VARIABLE v_DatPasp     as char.

ASSIGN v_caminho = 'HCM-pessoa-fisica.csv'.

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

PROCEDURE retornaEstadoCivil:
DEFINE INPUT  PARAMETER codHCM as integer.
DEFINE OUTPUT PARAMETER codWFP as integer.
    assign codWFP = 6. /* Outros */
    case codHCM:
        when 1 THEN assign codWFP = 2. /* Casado */
        when 2 THEN assign codWFP = 1. /* Solteiro */
        when 3 THEN assign codWFP = 3. /* Desquitado */
        when 4 THEN assign codWFP = 4. /* Divorciado */
        when 5 THEN assign codWFP = 5. /* Viuvo */
        when 6 THEN assign codWFP = 3. /* Separado judicialmente */
        when 7 THEN assign codWFP = 6. /* Outros */
        when 8 THEN assign codWFP = 6. /* Uniao estavel = Outros */
    end case.
END PROCEDURE.

PROCEDURE retornaRaca:
DEFINE INPUT  PARAMETER codHCM as integer.
DEFINE OUTPUT PARAMETER codWFP as integer.
    assign codWFP = 9. /* Nao informado */
    case codHCM:
        when 1 THEN assign codWFP = 2. /* Branca */
        when 2 THEN assign codWFP = 4. /* Preta */
        when 3 THEN assign codWFP = 8. /* Parda */
        when 4 THEN assign codWFP = 6. /* Amarela */
        when 5 THEN assign codWFP = 9. /* Nao informada */
        when 6 THEN assign codWFP = 1. /* Indigena */
    end case.
END PROCEDURE.

PROCEDURE retornaEscolaridade:
DEFINE INPUT  PARAMETER codHCM as integer.
DEFINE OUTPUT PARAMETER codWFP as integer.
    assign codWFP = 0.
    case codHCM:
        when  1 THEN assign codWFP = 1.  /* Nao alfabetizado */
        when  2 THEN assign codWFP = 2.  /* Fundamental 1 a 4 incompleto */
        when  3 THEN assign codWFP = 3.  /* Fundamental 1 a 4 completo */
        when  4 THEN assign codWFP = 4.  /* Fundamental 5 a 8 incompleto */
        when  5 THEN assign codWFP = 5.  /* Fundamental 5 a 8 completo / 1 grau */
        when  6 THEN assign codWFP = 6.  /* Medio incompleto / 2 grau */
        when  7 THEN assign codWFP = 7.  /* Medio completo / 2 grau */
        when  8 THEN assign codWFP = 11. /* Superior completo */
        when  9 THEN assign codWFP = 13. /* Superior incompleto */
        when 10 THEN assign codWFP = 14. /* Pos-graduacao */
        when 11 THEN assign codWFP = 15. /* Mestrado */
        when 12 THEN assign codWFP = 17. /* PhD */
        when 13 THEN assign codWFP = 16. /* Doutorado */
        when 14 THEN assign codWFP = 1.  /* Pre-escola = Nao alfabetizado */
        when 15 THEN assign codWFP = 8.  /* Tecnico incompleto */
        when 16 THEN assign codWFP = 9.  /* Tecnico completo */
    end case.
END PROCEDURE.

PROCEDURE retornaDeficiencia:
DEFINE INPUT  PARAMETER codHCM as integer.
DEFINE OUTPUT PARAMETER codWFP as integer.
    assign codWFP = 0. /* Nenhum */
    case codHCM:
        when  1 THEN assign codWFP = 0. /* Nenhum */
        when  2 THEN assign codWFP = 3. /* Visual */
        when  3 THEN assign codWFP = 2. /* Auditiva */
        when  4 THEN assign codWFP = 1. /* Fisica */
        when  5 THEN assign codWFP = 4. /* Mental */
        when  6 THEN assign codWFP = 6. /* Reabilitado */
        when  7 THEN assign codWFP = 5. /* Multipla */
        when  8 THEN assign codWFP = 1. /* Mobilidade reduzida = Fisica */
        when  9 THEN assign codWFP = 4. /* Intelectual = Mental */
    end case.
END PROCEDURE.

PROCEDURE retornaTipoSangue:
DEFINE INPUT  PARAMETER codTipoHCM  as integer.
DEFINE INPUT  PARAMETER codFatorHCM as integer.
DEFINE OUTPUT PARAMETER codWFP      as integer.
    assign codWFP = 0.
    case codTipoHCM:
        when 1 THEN DO: IF codFatorHCM = 1 THEN ASSIGN codWFP = 7. /* O+ */  ELSE ASSIGN codWFP = 8 /* O- */ . END.
        when 2 THEN DO: IF codFatorHCM = 1 THEN ASSIGN codWFP = 1. /* A+ */  ELSE ASSIGN codWFP = 2 /* A- */ . END.
        when 3 THEN DO: IF codFatorHCM = 1 THEN ASSIGN codWFP = 3. /* B+ */  ELSE ASSIGN codWFP = 4 /* B- */ . END.
        when 4 THEN DO: IF codFatorHCM = 1 THEN ASSIGN codWFP = 5. /* AB+ */ ELSE ASSIGN codWFP = 6 /* AB- */ . END.
    end case.
END PROCEDURE.

OUTPUT TO VALUE(v_caminho) convert target 'iso8859-1'.

PUT 'CPF;Nome;Apelido;Sexo;Nacionalidade;Data_chegada_ao_Brasil;Cidade_nascimento;UF_cidade;Data_nascimento;Mae;Pai;RG;DATA_EXPEDICAO_RG;ORGAO_EMISSOR;UF_RG;PIS;CTPS;SERIE_CTPS;UF_CTPS;ESTADO_CIVIL;RACA;ESCOLARIDADE;DEFICIENCIA;CEP;LOGRADOURO;NUMERO;BAIRRO;COMPLEMENTO;DDD_TELEFONE;TELEFONE;DDD_CELULAR;CELULAR;EMAIL;NUMERO_HABILITACAO;CATEGORIA_HABILITACAO;DATA_VALIDADE_HABILITACAO;NUMERO_TITULO_ELEITOR;ZONA_ELEITORAL;SECAO_ELEITORAL;CARTEIRA_RESERVISTA;PAIS_VISTO_PASSAPORTE;NUMERO_VISTO;DATA_VALIDADE_PASSAPORTE;POSSUI_VEICULO_PROPRIO;TIPO_VEICULO;POSSUI_SEGURO;DATA_VENCIMENTO_SEGURO;ANO_VEICULO;PLACA_VEICULO;NUMERO_RENAVAM;APOSENTADO;DATA_APOSENTADORIA;MOTIVO_APOSENTADORIA;CID_APOSENTADORIA;TIPO_SANGUINEO;DOADOR_DE_SANGUE;DATA_CASAMENTO;NOME_MAE_SOLTEIRA;NUMERO_CARTAO_NACIONAL_SAUDE' skip.

FOR EACH rh_pessoa_fisic NO-LOCK:

    IF rh_pessoa_fisic.cod_id_feder = ? THEN
        NEXT.
    
    IF int64(rh_pessoa_fisic.cod_id_feder) <= 0 THEN
        NEXT.

    ASSIGN v_codNac = 0.
    RUN retornaNacionalidade(rh_pessoa_fisic.cod_pais_nasc, OUTPUT v_codNac).

    /* Data de chegada ao Brasil - Apenas estrangeiros */    
    ASSIGN v_DatChegPais = ''.
    IF (v_codNac <> 10) THEN 
        ASSIGN v_DatChegPais = '01/01/' + string(rh_pessoa_fisic.num_ano_chegad_pais).

    /* Cidade e UF - Desconsiderar no caso de estrangeiros */
    ASSIGN v_CidNasc = 'NAO INFORMADO'
           v_UFNasc  = 'NAO INFORMADO'.
    IF (v_codNac = 10) THEN
        ASSIGN v_CidNasc = rh_pessoa_fisic.nom_naturalidade
               v_UFNasc  = rh_pessoa_fisic.cod_unid_federac_nasc.

    ASSIGN v_EstCiv = 0.
    RUN retornaEstadoCivil(rh_pessoa_fisic.idi_estado_civil, OUTPUT v_EstCiv).

    ASSIGN v_Raca = 0.
    RUN retornaRaca(rh_pessoa_fisic.idi_cor_cutis, OUTPUT v_Raca).

    ASSIGN v_Escol = 0.
    RUN retornaEscolaridade(rh_pessoa_fisic.cdn_grau_instruc, OUTPUT v_Escol).

    ASSIGN v_Defic = 0.
    IF rh_pessoa_fisic.log_livre_1 = YES THEN DO:
        FIND LAST ficha_medic OF rh_pessoa_fisic NO-LOCK NO-ERROR.
        IF AVAIL ficha_medic THEN DO:
            FIND FIRST defcncia_pacien OF ficha_medic NO-LOCK NO-ERROR.
            IF AVAIL defcncia_pacien THEN DO:
                FIND FIRST defcncia_fisic OF defcncia_pacien NO-LOCK NO-ERROR.
                IF AVAIL defcncia_fisic THEN
                    RUN retornaDeficiencia(defcncia_fisic.idi_tip_defcncia_fisic, OUTPUT v_Defic).
            END.
        END.
    END.

    FIND FIRST compl_pessoa_fisic OF rh_pessoa_fisic NO-LOCK NO-ERROR.

    ASSIGN v_PaisPasp = ''.
    IF AVAIL compl_pessoa_fisic THEN
        IF TRIM(compl_pessoa_fisic.cod_pais_emis_pasporte) <> '' THEN DO:
            FIND FIRST rh_pais WHERE rh_pais.cod_pais = compl_pessoa_fisic.cod_pais_emis_pasporte NO-LOCK NO-ERROR.
            ASSIGN v_PaisPasp = nom_pais.
        END.
    
    ASSIGN v_TipSan = 0.
    RUN retornaTipoSangue(rh_pessoa_fisic.idi_tip_sangue, rh_pessoa_fisic.idi_fatorrh, OUTPUT v_TipSan).

    ASSIGN v_DatPasp = ''.
    IF AVAIL compl_pessoa_fisic THEN 
        IF compl_pessoa_fisic.dat_valid_pasporte <> ? THEN 
            v_DatPasp = string(compl_pessoa_fisic.dat_valid_pasporte).

    FIND FIRST funcionario OF rh_pessoa_fisic NO-LOCK NO-ERROR.

    /* Funcionarios */
    IF AVAIL funcionario THEN DO:

        EXPORT DELIMITER ';'
            rh_pessoa_fisic.cod_id_feder
            rh_pessoa_fisic.nom_pessoa_fisic
            rh_pessoa_fisic.nom_abrev_pessoa_fisic
            rh_pessoa_fisic.idi_sexo
            v_codNac
            v_DatChegPais
            v_CidNasc
            v_UFNasc
            IF rh_pessoa_fisic.dat_nascimento <> ? THEN string(rh_pessoa_fisic.dat_nascimento) ELSE '01/01/1900'
            IF (rh_pessoa_fisic.nom_mae_pessoa_fisic <> ?) AND TRIM(rh_pessoa_fisic.nom_mae_pessoa_fisic) <> '' THEN rh_pessoa_fisic.nom_mae_pessoa_fisic ELSE 'NAO INFORMADO' 
            rh_pessoa_fisic.nom_pai_pessoa_fisic
            IF TRIM(rh_pessoa_fisic.cod_id_estad_fisic) <> '' THEN string(rh_pessoa_fisic.cod_id_estad_fisic) ELSE 'NAO INFORMADO'
            IF rh_pessoa_fisic.dat_emis_id_estad_fisic <> ? THEN string(rh_pessoa_fisic.dat_emis_id_estad_fisic) ELSE 'NAO INFORMADO'
            IF rh_pessoa_fisic.cod_orgao_emis_id_estad <> '' THEN rh_pessoa_fisic.cod_orgao_emis_id_estad ELSE 'NAO INFORMADO'
            IF rh_pessoa_fisic.cod_unid_federac_emis_estad <> '' THEN rh_pessoa_fisic.cod_unid_federac_emis_estad ELSE 'NAO INFORMADO'
            IF funcionario.cod_pis <> '' THEN funcionario.cod_pis ELSE 'NAO INFORMADO'
            IF funcionario.cod_cart_trab <> '' THEN funcionario.cod_cart_trab ELSE 'NAO INFORMADO'
            IF funcionario.cod_ser_cart_trab <> '' THEN funcionario.cod_ser_cart_trab ELSE 'NAO INFORMADO'
            IF funcionario.cod_unid_federac_cart_trab <> '' THEN funcionario.cod_unid_federac_cart_trab ELSE 'NAO INFORMADO'
            v_EstCiv
            v_Raca
            v_Escol
            v_Defic
            IF rh_pessoa_fisic.cod_cep_rh <> '' THEN rh_pessoa_fisic.cod_cep_rh ELSE 'NAO INFORMADO'
            rh_pessoa_fisic.nom_ender_rh
            rh_pessoa_fisic.cod_num_ender
            rh_pessoa_fisic.nom_bairro_rh
            '' /* Complemento */
            rh_pessoa_fisic.num_ddd
            rh_pessoa_fisic.num_telefone
            rh_pessoa_fisic.num_ddd_contat
            rh_pessoa_fisic.num_telef_contat
            rh_pessoa_fisic.nom_mail_contat
            IF funcionario.num_cart_habilit > 0 THEN STRING(funcionario.num_cart_habilit) ELSE ''
            funcionario.cod_categ_habilit
            IF funcionario.dat_vencto_habilit <> ? THEN STRING(funcionario.dat_vencto_habilit) ELSE ''
            funcionario.cod_tit_eletral
            IF funcionario.num_zona_tit_eletral > 0 THEN STRING(funcionario.num_zona_tit_eletral) ELSE ''
            IF funcionario.num_secao_tit_eletral > 0 THEN STRING(funcionario.num_secao_tit_eletral) ELSE ''
            funcionario.cod_docto_milit
            v_PaisPasp
            IF AVAIL compl_pessoa_fisic THEN string(compl_pessoa_fisic.cod_pasporte) ELSE ''
            v_DatPasp
            '' /* POSSUI_VEICULO_PROPRIO */
            '' /* TIPO_VEICULO */
            '' /* POSSUI_SEGURO */
            '' /* DATA_VENCIMENTO_SEGURO */
            '' /* ANO_VEICULO */
            '' /* PLACA_VEICULO */
            '' /* NUMERO_RENAVAM */
            IF funcionario.idi_tip_func = 3 THEN '1' ELSE '0' /* Aposentado */
            IF funcionario.dat_livre_1 <> ? THEN STRING(funcionario.dat_livre_1) ELSE '' /* Data de aposentadoria */
            '' /* MOTIVO_APOSENTADORIA */
            '' /* CID_APOSENTADORIA */
            IF v_TipSan <> 0 THEN v_TipSan ELSE ''
            IF rh_pessoa_fisic.log_pessoa_fisic_doador = YES THEN '1' ELSE '0'
            '' /* DATA_CASAMENTO */
            '' /* NOME_MAE_SOLTEIRA */
            IF AVAIL compl_pessoa_fisic THEN compl_pessoa_fisic.cod_cartao_nac_saude ELSE ''
            .
            
    END.
    
    /* Terceiros / prestadores de servico */
    ELSE DO:

        FIND FIRST prestdor_serv WHERE prestdor_serv.num_pessoa = rh_pessoa_fisic.num_pessoa_fisic NO-LOCK NO-ERROR. 
        IF AVAIL prestdor_serv THEN

            EXPORT DELIMITER ';'
                rh_pessoa_fisic.cod_id_feder
                rh_pessoa_fisic.nom_pessoa_fisic
                rh_pessoa_fisic.nom_abrev_pessoa_fisic
                rh_pessoa_fisic.idi_sexo
                v_codNac
                v_DatChegPais
                v_CidNasc
                v_UFNasc
                IF rh_pessoa_fisic.dat_nascimento <> ? THEN string(rh_pessoa_fisic.dat_nascimento) ELSE '01/01/1900'
                IF (rh_pessoa_fisic.nom_mae_pessoa_fisic <> ?) AND TRIM(rh_pessoa_fisic.nom_mae_pessoa_fisic) <> '' THEN rh_pessoa_fisic.nom_mae_pessoa_fisic ELSE 'NAO INFORMADO' 
                rh_pessoa_fisic.nom_pai_pessoa_fisic
                IF TRIM(rh_pessoa_fisic.cod_id_estad_fisic) <> '' THEN string(rh_pessoa_fisic.cod_id_estad_fisic) ELSE 'NAO INFORMADO'
                IF rh_pessoa_fisic.dat_emis_id_estad_fisic <> ? THEN string(rh_pessoa_fisic.dat_emis_id_estad_fisic) ELSE 'NAO INFORMADO'
                IF rh_pessoa_fisic.cod_orgao_emis_id_estad <> '' THEN rh_pessoa_fisic.cod_orgao_emis_id_estad ELSE 'NAO INFORMADO'
                IF rh_pessoa_fisic.cod_unid_federac_emis_estad <> '' THEN rh_pessoa_fisic.cod_unid_federac_emis_estad ELSE 'NAO INFORMADO'
                IF string(prestdor_serv.cdd_func_inss) <> '' THEN string(prestdor_serv.cdd_func_inss) ELSE 'NAO INFORMADO'
                'TERCEIRO' /* Carteira de trabalho */
                'TERCEIRO' /* Serie da CTPS */
                'TERCEIRO' /* UF da CTPS */
                v_EstCiv
                v_Raca
                v_Escol
                v_Defic
                IF rh_pessoa_fisic.cod_cep_rh <> '' THEN rh_pessoa_fisic.cod_cep_rh ELSE 'NAO INFORMADO'
                rh_pessoa_fisic.nom_ender_rh
                rh_pessoa_fisic.cod_num_ender
                rh_pessoa_fisic.nom_bairro_rh
                '' /* Complemento */
                rh_pessoa_fisic.num_ddd
                rh_pessoa_fisic.num_telefone
                rh_pessoa_fisic.num_ddd_contat
                rh_pessoa_fisic.num_telef_contat
                rh_pessoa_fisic.nom_mail_contat
                '' /* Carteira de habilitacao */
                '' /* Categoria CNH */
                '' /* Vencimento CNH */
                '' /* Titulo eleitoral */
                '' /* Zona titulo eleitoral */
                '' /* Secao titulo eleitoral */
                '' /* Documento militar */
                v_PaisPasp
                IF AVAIL compl_pessoa_fisic THEN string(compl_pessoa_fisic.cod_pasporte) ELSE ''
                v_DatPasp
                '' /* POSSUI_VEICULO_PROPRIO */
                '' /* TIPO_VEICULO */
                '' /* POSSUI_SEGURO */
                '' /* DATA_VENCIMENTO_SEGURO */
                '' /* ANO_VEICULO */
                '' /* PLACA_VEICULO */
                '' /* NUMERO_RENAVAM */
                '0' /* Aposentado */
                '' /* Data de aposentadoria */
                '' /* MOTIVO_APOSENTADORIA */
                '' /* CID_APOSENTADORIA */
                IF v_TipSan <> 0 THEN v_TipSan ELSE ''
                IF rh_pessoa_fisic.log_pessoa_fisic_doador = YES THEN '1' ELSE '0'
                '' /* DATA_CASAMENTO */
                '' /* NOME_MAE_SOLTEIRA */
                IF AVAIL compl_pessoa_fisic THEN compl_pessoa_fisic.cod_cartao_nac_saude ELSE ''
                .
    
    END.
END.         
OUTPUT CLOSE.

