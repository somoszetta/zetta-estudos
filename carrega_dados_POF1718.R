#------------------------------------------------------------------------------- 
# Carregando Dados POF 2017-2018 -----------------------------------------------
#-------------------------------------------------------------------------------

#Link para download dos dados: https://www.ibge.gov.br/estatisticas/sociais/educacao/9050-pesquisa-de-orcamentos-familiares.html?=&t=o-que-e 
# Script para carregar dados da POF 2017-2018, a partir dos dados brutos em txt,
# e usando os codigos disponibilizados pelo IBGE em Programas de Leitura

# limpando ambiente
rm(list = ls())

# REGISTRO MORADOR -------------------------------------------------------------

MORADOR <- read.fwf("Dados/Originais/IBGE/POF/1718/Dados_20210304/MORADOR.txt", 
                    widths = c(2,4,1,9,2,1,2,2,1,2,2,4,3,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,1,1,
                               1,1,1,1,1,2,1,1,2,1,1,2,1,1,1,2,1,2,14,14,10,1,1,20,20,20,20),
                    na.strings=c(" "),
                    col.names = c("UF", "ESTRATO_POF", "TIPO_SITUACAO_REG", "COD_UPA", "NUM_DOM", 
                                  "NUM_UC", "COD_INFORMANTE", "V0306", "V0401", "V04021", "V04022",
                                  "V04023", "V0403", "V0404", "V0405", "V0406", "V0407", "V0408", 
                                  "V0409", "V0410", "V0411", "V0412", "V0413", "V0414", "V0415", "V0416",
                                  "V041711", "V041712", "V041721", "V041722", "V041731", "V041732", 
                                  "V041741", "V041742", "V0418", "V0419", "V0420", "V0421", "V0422",
                                  "V0423", "V0424", "V0425", "V0426", "V0427", "V0428", "V0429", "V0430", 
                                  "ANOS_ESTUDO", "PESO", "PESO_FINAL", "RENDA_TOTAL", "INSTRUCAO", 
                                  "COMPOSICAO", "PC_RENDA_DISP", "PC_RENDA_MONET", "PC_RENDA_NAO_MONET", "PC_DEDUCAO"),
                    dec=".")


# REGISTRO - RENDIMENTO DO TRABALHO --------------------------------------------

RENDIMENTO_TRABALHO <- read.fwf("Dados/Originais/IBGE/POF/1718/Dados_20210304/RENDIMENTO_TRABALHO.txt",
                                widths = c(2,4,1,9,2,1,2,2,1,1,7,1,1,1,1,1,1,7,7,7,7,2,
                                           2,3,1,12,10,10,10,10,1,1,14,14,10,4,5),
                                na.strings=c(" "),
                                col.names = c("UF", "ESTRATO_POF", "TIPO_SITUACAO_REG", "COD_UPA", "NUM_DOM", "NUM_UC",
                                              "COD_INFORMANTE", "QUADRO", "SUB_QUADRO", "SEQ", "V9001", "V5302", "V53021",
                                              "V5303","V5304", "V5305", "V5307", "V8500", "V531112","V531122", "V531132",
                                              "V9010", "V9011","V5314", "V5315", "DEFLATOR", "V8500_DEFLA","V531112_DEFLA", 
                                              "V531122_DEFLA","V531132_DEFLA", "COD_IMPUT_VALOR","FATOR_ANUALIZACAO", "PESO", 
                                              "PESO_FINAL","RENDA_TOTAL","V53011","V53061"),
                                dec=".")


#REGISTRO DESPESA INDIVIDUAL ---------------------------------------------------

DESPESA_INDIVIDUAL <- read.fwf("Dados/Originais/IBGE/POF/1718/Dados_20210304/DESPESA_INDIVIDUAL.txt",
                               widths = c(2,4,1,9,2,1,2,2,2,7,2,10,2,2,1,1,1,12,10,1,2,14,14,10,5),
                               na.strings=c(" "),
                               col.names = c("UF", "ESTRATO_POF", "TIPO_SITUACAO_REG", "COD_UPA", "NUM_DOM", "NUM_UC",
                                             "COD_INFORMANTE", "QUADRO", "SEQ", "V9001", "V9002", "V8000", "V9010", 
                                             "V9011", "V9012", "V4104", "V4105", "DEFLATOR", "V8000_DEFLA", 
                                             "COD_IMPUT_VALOR", "FATOR_ANUALIZACAO", "PESO", "PESO_FINAL", "RENDA_TOTAL","V9004"),
                               dec=".") 




# Salvando bases ---------------------------------------------------------------

saveRDS(MORADOR,"Dados/Derivados/MORADOR_1718.rds")
saveRDS(DESPESA_INDIVIDUAL,"Dados/Derivados/DESPESA_INDIVIDUAL_1718.rds")
saveRDS(RENDIMENTO_TRABALHO,"Dados/Derivados/RENDIMENTO_TRABALHO_1718.rds")
