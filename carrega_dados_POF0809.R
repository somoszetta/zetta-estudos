#------------------------------------------------------------------------------- 
# Carregando Dados POF 2008-2009 -----------------------------------------------
#-------------------------------------------------------------------------------

#Link para download dos dados: https://www.ibge.gov.br/estatisticas/sociais/educacao/9050-pesquisa-de-orcamentos-familiares.html?=&t=o-que-e 

# Script para carregar dados da POF 2008-2009, a partir dos dados brutos em txt

# limpando ambiente
rm(list = ls())

# Registro Morador -------------------------------------------------------------

pof2008_2 <- read.fwf(file = 'Dados/Originais/IBGE/POF/0809/Dados/T_MORADOR_S.txt', 
                      widths=c(2,2,3,1,2,1,2,2,14,14,2,2,2,2,2,2,4,3,6,7,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,16,16,16,2,5,5,5,5,5,5,5,16,8,2,2,2,2,2,2,2,2,2,2,2,2,2))

names(pof2008_2) <- c("TIPO_REG","COD_UF","NUM_SEQ","NUM_DV","COD_DOMC","NUM_UC","NUM_INFORMANTE", "NUM_EXT_RENDA","FATOR_EXPANSAO1","FATOR_EXPANSAO2",
                      "COD_REL_PESS_REFE_UC", "NUM_FAMILIA","COD_COND_FAMILIA","COD_COND_PRESENCA","DAT_DIA_NASC","DAT_MES_NASC","DAT_ANO_NASC",
                      "IDADE_ANOS","IDADE_MES","IDADE_DIA","COD_SEXO","COD_SABE_LER","COD_FREQ_ESCOLA","COD_CURSO_FREQ","COD_DUR_PRIMEIRO_GRAU_EH",
                      "COD_SERIE_FREQ","COD_NIVEL_INSTR","COD_DUR_PRIMEIRO_GRAU_ERA","COD_SERIE_COM_APROVACAO","COD_CONCLUIU_CURSO","ANOS_DE_ESTUDO",
                      "COD_COR_RACA","COD_SIT_RECEITA","COD_SIT_DESPESA","COD_TEM_CARTAO","COD_EHTITULAR_CARTAO","COD_TEM_CHEQUE","COD_EHTITULAR_CONTA",
                      "RENDA_BRUTA_MONETARIA","RENDA_BRUTA_NAO_MONETARIA","RENDA_TOTAL","COD_GRAVIDA","NUM_COMPRIMENTO","NUM_ALTURA","NUM_PESO",
                      "NUM_PESO_CRIANCA","COMPRIMENTO_IMPUTADO","ALTURA_IMPUTADO","PESO_IMPUTADO","RENDA_PERCAPITA","COD_RELIGIAO","COD_TEM_PLANO",
                      "COD_EHTITULAR","COD_NUM_DEPENDENTE","COD_UNID_CONSUMO","TEVE_NECESSIDADE_MEDICAMENTO","PRECISOU_ALGUM_SERVICO","TEMPO_GESTACAO",
                      "COD_AMAMENTANDO","COD_LEITE_MATERNO","COD_OUTRO_ALIMENTO","MESES_LEITE_MATERNO","COD_FREQ_ALIMENTAR","COD_ALIMENTO_CONSUMIDO")


# Registro Despesa Individual --------------------------------------------------

pof2008_12 <- read.fwf(file='Dados/Originais/IBGE/POF/0809/Dados/T_DESPESA_INDIVIDUAL_S.txt', widths = c(2,2,3,1,2,1,2,2,14,14,2,5,2,11,2,5,11,16,2,16,16,16,2,5,2,2))

names(pof2008_12) <- c("TIPO_REG","COD_UF","NUM_SEQ","NUM_DV","COD_DOMC","NUM_UC","NUM_INF","NUM_EXT_RENDA","FATOR_EXPANSAO1","FATOR_EXPANSAO2","NUM_QUADRO",
                       "COD_ITEM","COD_OBTENCAO","VAL_DESPESA","FATOR_ANUAL","NUM_DEFLATOR","VAL_DESPESA_CORRIGIDO","VALOR_ANUAL_EXPANDIDO2","COD_IMPUT",
                       "RENDA_BRUTA_MONETARIA ","RENDA_BRUTA_NAO_MONETARIA","RENDA_TOTAL","COD_CARACTERISTICA","COD_LOCAL_COMPRA","COD_MOTIVO","UF_DESPESA")

# Salvando bases ---------------------------------------------------------------

saveRDS(pof2008_2,"Dados/Derivados/MORADOR_0809.rds")
saveRDS(pof2008_12,"Dados/Derivados/DESPESA_INDIVIVIDUAL_0809.rds")

