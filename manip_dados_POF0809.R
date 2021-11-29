#------------------------------------------------------------------------------- 
# Manipular Dados POF 2008/2009 ------------------------------------------------
#------------------------------------------------------------------------------- 

# Esse Script manipula as bases da POF 2008-2009 para deixar nos formatos que queremos

# Dicionario para as variaveis esta em: Originais\IBGE\POF\0809\Layout com descriçSes.xls
# tambem: Originais\IBGE\POF\0809\ClassificaçSes POF 2008-2009.doc
# Cadastro de Produtos em: Originais/IBGE/POF/0809/Cadastro de Produtos POF 2008-2009.xls

#limpando ambiente
rm(list = ls())


# IPCA -------------------------------------------------------------------------

dt_ipca <- readRDS('Dados/Derivados/deflator_ipca.RDS') 

# vamos deflacionar a niveis de dezembro/2020
# todos os valores da POF 08-09 estao a precos de 15 de janeiro de 2009

index_jan09 <- which((dt_ipca$ano == 2009) & (dt_ipca$mes == 01))
deflator_ipca <- dt_ipca$deflator[index_jan09]


# REGISTRO MORADOR -------------------------------------------------------------

reg_morador_0809 <- readRDS('Dados/Derivados/MORADOR_0809.RDS') %>% 
  #selecionando so as variaveis que queremos
  select(COD_UF, NUM_EXT_RENDA, NUM_SEQ, NUM_DV, COD_DOMC, NUM_UC, NUM_INFORMANTE, COD_REL_PESS_REFE_UC,  
         IDADE_ANOS, COD_SEXO, COD_COR_RACA, COD_TEM_CARTAO, COD_EHTITULAR_CONTA,
         RENDA_PERCAPITA, FATOR_EXPANSAO2) %>% 
  distinct() %>% 
  #renomeando variaveis para padronizar com outras POFs
  rename(UF = COD_UF, ESTRATO_POF = NUM_EXT_RENDA, SEQ = NUM_SEQ, DV_SEQ = NUM_DV, NUM_DOM = COD_DOMC,
         COD_INFORMANTE = NUM_INFORMANTE, CONDICAO_NA_UC = COD_REL_PESS_REFE_UC,SEXO = COD_SEXO, RACA = COD_COR_RACA, 
         TEM_CART_CRED = COD_TEM_CARTAO, TEM_CONTCORR = COD_EHTITULAR_CONTA, 
         PC_RENDA = RENDA_PERCAPITA, PESO_FINAL = FATOR_EXPANSAO2) %>% 
  #tirando empregado domestico e parente e filtrando para pessoas com 10 anos ou mais
  filter(CONDICAO_NA_UC != 7, CONDICAO_NA_UC != 8, IDADE_ANOS >= 10) %>%
  #colocando descricao das variaveis e deflacionando renda
  mutate(REGIAO = case_when(UF %in% c(11,12,13,14,15,16,17) ~ 'Norte',
                            UF %in% c(21,22,23,24,25,26,27,28,29) ~ 'Nordeste',
                            UF %in% c(31,32,33,35) ~ 'Sudeste',
                            UF %in% c(41,42,43) ~ 'Sul',
                            UF %in% c(50,51,52,53) ~ 'Centro-Oeste'),
         TIPO_SITUACAO_REG = case_when( (UF == 11) & (ESTRATO_POF %in% c(7,8,9,10,11)) ~ 'Rural',
                                        (UF == 12) & (ESTRATO_POF %in% c(3,4)) ~ 'Rural',
                                        (UF == 13) & (ESTRATO_POF %in% c(9,10,11,12,13)) ~ 'Rural',
                                        (UF == 14) & (ESTRATO_POF %in% c(3,4)) ~ 'Rural',   
                                        (UF == 15) & (ESTRATO_POF %in% c(9,10,11,12,13,14)) ~ 'Rural', 
                                        (UF == 16) & (ESTRATO_POF %in% c(4,5,6)) ~ 'Rural', 
                                        (UF == 17) & (ESTRATO_POF %in% c(6,7,8,9,10)) ~ 'Rural', 
                                        (UF == 21) & (ESTRATO_POF %in% seq(13,24,1)) ~ 'Rural', 
                                        (UF == 22) & (ESTRATO_POF %in% seq(10,19,1)) ~ 'Rural',
                                        (UF == 23) & (ESTRATO_POF %in% seq(24,36,1)) ~ 'Rural',
                                        (UF == 24) & (ESTRATO_POF %in% seq(9,13,1)) ~ 'Rural',
                                        (UF == 25) & (ESTRATO_POF %in% seq(10,16,1)) ~ 'Rural',
                                        (UF == 26) & (ESTRATO_POF %in% seq(16,25,1)) ~ 'Rural',
                                        (UF == 27) & (ESTRATO_POF %in% seq(9,13,1)) ~ 'Rural',
                                        (UF == 28) & (ESTRATO_POF %in% seq(8,9,1)) ~ 'Rural',
                                        (UF == 29) & (ESTRATO_POF %in% seq(22,36,1)) ~ 'Rural',
                                        (UF == 31) & (ESTRATO_POF %in% seq(28,45,1)) ~ 'Rural',
                                        (UF == 32) & (ESTRATO_POF %in% seq(10,14,1)) ~ 'Rural',
                                        (UF == 33) & (ESTRATO_POF %in% seq(31,37,1)) ~ 'Rural',
                                        (UF == 35) & (ESTRATO_POF %in% seq(31,51,1)) ~ 'Rural',
                                        (UF == 41) & (ESTRATO_POF %in% seq(19,29,1)) ~ 'Rural',
                                        (UF == 42) & (ESTRATO_POF %in% seq(14,23,1)) ~ 'Rural',
                                        (UF == 43) & (ESTRATO_POF %in% seq(19,30,1)) ~ 'Rural',
                                        (UF == 50) & (ESTRATO_POF %in% seq(9,13,1)) ~ 'Rural',
                                        (UF == 51) & (ESTRATO_POF %in% seq(11,18,1)) ~ 'Rural',
                                        (UF == 52) & (ESTRATO_POF %in% seq(18,28,1)) ~ 'Rural',
                                        (UF == 53) & (ESTRATO_POF %in% seq(8,9,1)) ~ 'Rural',
                                        TRUE ~ 'Urbano'),
         IDADE_AG = case_when(IDADE_ANOS %in% seq(0,9,1) ~ 'Até 9 anos',
                              IDADE_ANOS %in% seq(10,24,1) ~ '10 a 24 anos',
                              IDADE_ANOS %in% seq(25,49,1) ~ '25 a 49 anos',
                              IDADE_ANOS %in% seq(50,64,1) ~ '50 a 64 anos',
                              IDADE_ANOS >= 65 ~ '65 anos ou mais'),
         SEXO = case_when(SEXO == 1 ~ 'Homem',
                          SEXO == 2 ~ 'Mulher'),
         RACA = case_when(RACA == 1 ~ 'Brancos',
                          RACA == 2 ~ 'Pretos e pardos',
                          RACA == 4 ~ 'Pretos e pardos',
                          RACA == 3 ~ 'Outros',
                          RACA == 5 ~ 'Outros',
                          RACA == 9 ~ 'Sem declaração'),
         # colocando os NAs como -1 para contarmos as pessoas no total mas nao influenciar no max() em scripts posteriores
         DUM_CART_CRED = case_when(TEM_CART_CRED == 1 ~ 1,
                                   TEM_CART_CRED == 0 ~ -1,
                                   TEM_CART_CRED == 2 ~ 0),
         DUM_CONTCORR = case_when(TEM_CONTCORR == 1 ~ 1,
                                  TEM_CONTCORR == 0 ~ -1,
                                  TEM_CONTCORR == 2 ~ 0),
         PC_RENDA_defl_ipca = PC_RENDA*deflator_ipca,
         #colocando renda em categorias
         PC_RENDA_categ = case_when(is.na(PC_RENDA_defl_ipca) ~ as.character(NA),
                                    PC_RENDA_defl_ipca <= 500 ~ 'Até R$ 500',
                                    PC_RENDA_defl_ipca > 500 & PC_RENDA_defl_ipca <= 1000 ~ 'Entre R$ 500 e R$ 1.000',
                                    PC_RENDA_defl_ipca > 1000 & PC_RENDA_defl_ipca <= 2000 ~ 'Entre R$ 1.000 e R$ 2.000',
                                    PC_RENDA_defl_ipca > 2000 & PC_RENDA_defl_ipca <= 5000 ~ 'Entre R$ 2.000 e R$ 5.000',
                                    PC_RENDA_defl_ipca > 5000 ~ 'Acima de R$ 5.000')) %>% 
  #selecionando as variaveis que queremos e arrumando a ordem
  select(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, SEQ, DV_SEQ, NUM_DOM, NUM_UC, COD_INFORMANTE,
         CONDICAO_NA_UC, IDADE_ANOS, IDADE_AG, SEXO, RACA,
         DUM_CART_CRED, DUM_CONTCORR, PC_RENDA_defl_ipca, PC_RENDA_categ, PESO_FINAL)



# Analise Registro Morador -----------------------------------------------------

#contando os NAs
NAs_reg_morador_0809 <- sapply(reg_morador_0809, function(x) sum(is.na(x)))
# 0 NAs

#analisando conta corrente
count_contcorr <- reg_morador_0809 %>% 
  group_by(DUM_CONTCORR) %>% 
  summarize(qtd = n())

#maior parte de conta corrente esta em -1 ("NAO APLICAVEL") - nao vamos mais usar essa variavel


# Informacoes da Pessoa de Referencia ------------------------------------------

pessoa_referencia_0809 <- reg_morador_0809 %>% 
  #selecionando so pessoa de referencia
  filter(CONDICAO_NA_UC == 1) %>%
  #so queremos algumas variaveis
  select(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, SEQ, DV_SEQ, NUM_DOM, NUM_UC,
         IDADE_ANOS, IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ) %>% 
  distinct()


# Substitui caracteristicas nas pessoas da UC pela pessoa de referencia --------

reg_morador_0809 <- reg_morador_0809 %>% 
  #tirando as caracteristicas individuais
  select(-c(IDADE_ANOS, IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ)) %>% 
  #substituindo
  left_join(.,pessoa_referencia_0809,
            by = c('UF', 'REGIAO', 'ESTRATO_POF', 'TIPO_SITUACAO_REG', 'SEQ', 'DV_SEQ','NUM_DOM', 'NUM_UC'))


# Quantidade de pessoas em cada familia ----------------------------------------

# so temos todas as pessoas no registro de morador
qtd_pessoas_uc_0809 <- reg_morador_0809 %>% 
  group_by(UF, ESTRATO_POF, SEQ, DV_SEQ, NUM_DOM, NUM_UC) %>% 
  summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE))

# REGISTRO DESPESAS INDIVIDUAIS ------------------------------------------------

reg_despind_0809 <- readRDS('Dados/Derivados/DESPESA_INDIVIVIDUAL_0809.RDS') %>% 
  #so as variaveis que queremos
  select(COD_UF, NUM_EXT_RENDA, NUM_SEQ, NUM_DV, COD_DOMC, NUM_UC, NUM_INF, 
         NUM_QUADRO, COD_ITEM, COD_IMPUT, VAL_DESPESA, FATOR_ANUAL, NUM_DEFLATOR, FATOR_EXPANSAO2,
         VAL_DESPESA_CORRIGIDO,VALOR_ANUAL_EXPANDIDO2, NUM_DEFLATOR) %>% 
  #renomeando
  rename(UF = COD_UF, ESTRATO_POF = NUM_EXT_RENDA, SEQ = NUM_SEQ, DV_SEQ = NUM_DV, NUM_DOM = COD_DOMC,
         COD_INFORMANTE = NUM_INF, QUADRO = NUM_QUADRO, CODIGO_DESPESA = COD_ITEM,
         VALOR_DESPESA = VAL_DESPESA, VALOR_DESPESA_DEFLA = VAL_DESPESA_CORRIGIDO, 
         FATOR_ANUALIZACAO = FATOR_ANUAL, DEFLATOR = NUM_DEFLATOR, PESO_FINAL =  FATOR_EXPANSAO2) %>% 
  #deflacionando
  mutate(VALOR_DESPESA_defl_ipca = VALOR_DESPESA_DEFLA*deflator_ipca) %>% 
  #so queremos quadro com servicos financeiros
  filter(QUADRO == 44, CODIGO_DESPESA %in% c(03602,
                                             02201,
                                             02801,
                                             02802,
                                             02803,
                                             02401,
                                             02601,
                                             02602,
                                             02603,
                                             02501)) %>% 
          #agrupando categorias  
  mutate(CODIGO_DESPESA = as.numeric(CODIGO_DESPESA),
         #substituindo DOC e TED por Transferencia Interbancaria
         CODIGO_DESPESA = case_when(CODIGO_DESPESA == as.numeric(02602) ~ as.numeric(02601),
                                    CODIGO_DESPESA == as.numeric(02603) ~ as.numeric(02601),
                                    TRUE ~ CODIGO_DESPESA),
         #criando variavel com nome da despesa
         NOME_DESPESA = case_when(CODIGO_DESPESA == 03602 ~ 'juros_cart_cred', 
                                  CODIGO_DESPESA == 02201 ~ 'anuidade_cart_cred',
                                  CODIGO_DESPESA == 02801 ~ 'tarifa_cont_banc',
                                  CODIGO_DESPESA == 02802 ~ 'manut_cont_banc',
                                  CODIGO_DESPESA == 02803 ~ 'pacote_cont_banc',
                                  CODIGO_DESPESA == 02401 ~ 'tx_extrato',
                                  CODIGO_DESPESA == 02601 ~ 'transferencia',
                                  CODIGO_DESPESA == 02602 ~ 'transferencia',
                                  CODIGO_DESPESA == 02603 ~ 'transferencia',
                                  CODIGO_DESPESA == 02501 ~ 'cadastro_banc',
                                  TRUE ~ as.character(NA))) %>% 
  #eliminando despesas nos quantis 1% e 99% (outliers)
  group_by(NOME_DESPESA) %>% 
  mutate(desp_inf = quantile(VALOR_DESPESA_defl_ipca, probs = c(0.01)),
         desp_sup = quantile(VALOR_DESPESA_defl_ipca, probs = c(0.99))) %>% 
  ungroup() %>%
  filter(VALOR_DESPESA_defl_ipca > desp_inf, VALOR_DESPESA_defl_ipca < desp_sup) %>% 
  #selecionando so variaveis que queremos
  select(UF, ESTRATO_POF, SEQ, DV_SEQ, NUM_DOM, NUM_UC, COD_INFORMANTE,
         QUADRO, CODIGO_DESPESA, NOME_DESPESA, COD_IMPUT, VALOR_DESPESA, VALOR_ANUAL_EXPANDIDO2, 
         DEFLATOR, VALOR_DESPESA_DEFLA, VALOR_DESPESA_defl_ipca,
         FATOR_ANUALIZACAO, PESO_FINAL)

# Merge despesa com as outras bases --------------------------------------------

reg_despind_0809 <- left_join(reg_despind_0809, pessoa_referencia_0809, 
                              by = c('UF', 'ESTRATO_POF', 'SEQ', 'DV_SEQ', 'NUM_DOM', 'NUM_UC')) %>% 
  # quantidade de pessoas
  left_join(., qtd_pessoas_uc_0809, by = c('UF', 'ESTRATO_POF', 'SEQ', 'DV_SEQ', 'NUM_DOM', 'NUM_UC'))


# Analise registro de despesa individual ---------------------------------------
 
#contando os NAs
NAs_reg_despind_0809 <- sapply(reg_despind_0809, function(x) sum(is.na(x)))
#0 NAs

#vendo valor expandido - se ele faz mais sentido que o valor despesa
val_exp <- reg_despind_0809 %>% 
  select(UF, SEQ, DV_SEQ, NUM_DOM, NUM_UC, COD_INFORMANTE, QUADRO, CODIGO_DESPESA, 
         VALOR_DESPESA, DEFLATOR, VALOR_DESPESA_DEFLA,
         VALOR_ANUAL_EXPANDIDO2, FATOR_ANUALIZACAO, PESO_FINAL) %>% 
  mutate(VALOR_ANUAL_EXPANDIDO_M = VALOR_DESPESA_DEFLA*FATOR_ANUALIZACAO*PESO_FINAL,
         dif = abs(VALOR_ANUAL_EXPANDIDO_M - VALOR_ANUAL_EXPANDIDO2))

# vendo diferença
max(val_exp$dif)
#deu no mesmo


# Ajuste em despesa individual -------------------------------------------------

#vou tirar uma variavel
reg_despind_0809 <- reg_despind_0809 %>% select(-VALOR_ANUAL_EXPANDIDO2)


# Salva Bases ------------------------------------------------------------------

saveRDS(reg_morador_0809, file = "Dados/Derivados/reg_morador_0809.RDS")
saveRDS(reg_despind_0809, file = "Dados/Derivados/reg_despind_0809.RDS")











