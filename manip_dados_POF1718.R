#------------------------------------------------------------------------------- 
# Manipular Dados POF  2017/2018 -----------------------------------------------
#------------------------------------------------------------------------------- 

# Dicionario para as variaveis esta em: G:\My Drive\3o_estudo_Zetta\Dados\Originais\IBGE\POF\1718
# Cadastro de Produtos em: G:/My Drive/3o_estudo_Zetta/Dados/Originais/IBGE/POF/1718/Cadastro de Produtos.xls

#limpando environment
rm(list = ls())

# IPCA -------------------------------------------------------------------------

dt_ipca <- readRDS('Dados/Derivados/deflator_ipca.RDS') 

#vamos deflacionar a niveis de dezembro/2020
#todos os valores da pesquisa estao a precos de 15 de janeiro de 2018

index_jan18 <- which((dt_ipca$ano == 2018) & (dt_ipca$mes == 01))
deflator_ipca <- dt_ipca$deflator[index_jan18]

# REGISTRO MORADOR -------------------------------------------------------------

reg_morador_1718 <- readRDS('Dados/Derivados/MORADOR_1718.rds') %>% 
  #so as variaveis que queremos
  select(UF, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC, COD_INFORMANTE,
         V0306, V0403, V0404, V0405, V0409, V0410, PESO_FINAL, 
         INSTRUCAO, PC_RENDA_MONET, PC_RENDA_NAO_MONET) %>% 
  #deflacionando rendas
  mutate(PC_RENDA_MONET_defl_ipca = PC_RENDA_MONET*deflator_ipca,
         PC_RENDA_NAO_MONET_defl_ipca = PC_RENDA_NAO_MONET*deflator_ipca,
         PC_RENDA_defl_ipca = PC_RENDA_MONET_defl_ipca + PC_RENDA_NAO_MONET_defl_ipca) %>% 
  #renomeando algumas variaveis para padronizar com outras POFs
  rename(CONDICAO_NA_UC = V0306,
         IDADE_ANOS = V0403,
         SEXO = V0404, 
         RACA = V0405,
         QTD_CART_CRED = V0409,
         QTD_CONTCORR = V0410) %>% 
  #tirando empregado domestico e parente e filtrando para pessoas com 10 anos ou mais
  filter(CONDICAO_NA_UC != 18, CONDICAO_NA_UC != 19, IDADE_ANOS >= 10) %>% 
  #variaveis dummy indicando posse ou nao de cartao de credito, conta corrente
  mutate(DUM_CART_CRED = case_when(is.na(QTD_CART_CRED) ~ -1,
                                   QTD_CART_CRED > 0 ~ 1,
                                   QTD_CART_CRED == 0 ~ 0),
         DUM_CONTCORR = case_when(is.na(QTD_CONTCORR) ~ -1,
                                  QTD_CONTCORR > 0 ~ 1,
                                  QTD_CONTCORR == 0 ~ 0),
         #adicionando regiao
         REGIAO = case_when(UF %in% c(11,12,13,14,15,16,17) ~ 'Norte',
                            UF %in% c(21,22,23,24,25,26,27,28,29) ~ 'Nordeste',
                            UF %in% c(31,32,33,35) ~ 'Sudeste',
                            UF %in% c(41,42,43) ~ 'Sul',
                            UF %in% c(50,51,52,53) ~ 'Centro-Oeste'),
         #agregando idade em categorias
         IDADE_AG = case_when(IDADE_ANOS %in% seq(0,9,1) ~ 'Até 9 anos',
                              IDADE_ANOS %in% seq(10,24,1) ~ '10 a 24 anos',
                              IDADE_ANOS %in% seq(25,49,1) ~ '25 a 49 anos',
                              IDADE_ANOS %in% seq(50,64,1) ~ '50 a 64 anos',
                              IDADE_ANOS >= 65 ~ '65 anos ou mais'),
         TIPO_SITUACAO_REG = case_when(TIPO_SITUACAO_REG == 1 ~ 'Urbano',
                                       TIPO_SITUACAO_REG == 2 ~ 'Rural'),
         RACA = case_when(RACA == 1 ~ 'Brancos',
                          RACA == 2 ~ 'Pretos e pardos',
                          RACA == 4 ~ 'Pretos e pardos',
                          RACA == 3 ~ 'Outros',
                          RACA == 5 ~ 'Outros',
                          RACA == 9 ~ 'Sem declaração'),
         SEXO = case_when(SEXO == 1 ~ 'Homem',
                          SEXO == 2 ~ 'Mulher'),
         PC_RENDA_categ = case_when(is.na(PC_RENDA_defl_ipca) ~ as.character(NA),
                                    PC_RENDA_defl_ipca <= 500 ~ 'Até R$ 500',
                                    PC_RENDA_defl_ipca > 500 & PC_RENDA_defl_ipca <= 1000 ~ 'Entre R$ 500 e R$ 1.000',
                                    PC_RENDA_defl_ipca > 1000 & PC_RENDA_defl_ipca <= 2000 ~ 'Entre R$ 1.000 e R$ 2.000',
                                    PC_RENDA_defl_ipca > 2000 & PC_RENDA_defl_ipca <= 5000 ~ 'Entre R$ 2.000 e R$ 5.000',
                                    PC_RENDA_defl_ipca > 5000 ~ 'Acima de R$ 5.000')) %>% 
  #selecionando as variaveis que queremos
  select(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC, COD_INFORMANTE,
         CONDICAO_NA_UC, IDADE_ANOS, IDADE_AG, SEXO, RACA,
         DUM_CART_CRED, DUM_CONTCORR,
         PC_RENDA_defl_ipca, PC_RENDA_categ, PESO_FINAL) %>% 
  distinct()


# Analise registro morador -----------------------------------------------------

#contando os NAs
NAs_reg_morador_1718 <- sapply(reg_morador_1718, function(x) sum(is.na(x)))
# 0 NAs

# REGISTRO RENDIMENTO DO TRABALHO ----------------------------------------------

reg_rendtrab_1718 <- readRDS('Dados/Derivados/RENDIMENTO_TRABALHO_1718.rds') %>% 
  #selecionando variaveis que queremos
  select(UF, ESTRATO_POF, COD_UPA, NUM_DOM, NUM_UC, COD_INFORMANTE, SUB_QUADRO, V5302, V5304) %>%
  #vou pegar só as linhas de trabalho principal
  filter(SUB_QUADRO == 1) %>% 
  select(-SUB_QUADRO) %>% 
  #renomeando
  rename(TIPO_TRABALHO = V5302,
         CARTEIRA_ASSINADA = V5304) %>% 
  #substituindo codigos por descricoes
  mutate(TIPO_TRABALHO = case_when(TIPO_TRABALHO == 1 ~ 'Trabalhador Doméstico',
                                   TIPO_TRABALHO == 2 ~ 'Militar e empregado do setor público',
                                   TIPO_TRABALHO == 4 ~ 'Militar e empregado do setor público',
                                   TIPO_TRABALHO == 3 ~ 'Empregado do setor privado',
                                   TIPO_TRABALHO == 5 ~ 'Empregador',
                                   TIPO_TRABALHO == 6 ~ 'Conta própria',
                                   TIPO_TRABALHO == 7 ~ 'Fora da força de trabalho e outros casos'),
         CARTEIRA_ASSINADA = case_when(CARTEIRA_ASSINADA == 1 ~ 'Sim',
                                       CARTEIRA_ASSINADA == 2 ~ 'Não',
                                       is.na(CARTEIRA_ASSINADA) ~ 'Não aplicável')) %>% 
  distinct()


#todos os 'Não Aplicável' de Carteira assinada estao associados a tipo trabalho de:
#"Empregador"                               "Conta própria"                           
#"Militar e empregado do setor público"     "Fora da força de trabalho e outros casos"


# Analise rendimento do trabalho -----------------------------------------------

#contando os NAs
NAs_reg_rendtrab_1718 <- sapply(reg_rendtrab_1718, function(x) sum(is.na(x)))
# 0 NAs


# Informacoes da Pessoa de Referencia ------------------------------------------

pessoa_referencia_1718 <- left_join(reg_morador_1718, reg_rendtrab_1718,
                                    by = c('UF', 'ESTRATO_POF', 'COD_UPA', 'NUM_DOM', 'NUM_UC', 'COD_INFORMANTE')) %>% 
  #selecionando so pessoas de referencia de cada familia
  filter(CONDICAO_NA_UC == 1) %>%
  #so algumas variaveis queremos
  select(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC,
         IDADE_ANOS, IDADE_AG, SEXO, RACA, CARTEIRA_ASSINADA, PC_RENDA_defl_ipca, PC_RENDA_categ) %>% 
  distinct()


# Substituindo caracteristicas do registro de morador pelas da pessoa de referencia 

reg_morador_1718 <- reg_morador_1718 %>% 
  #tirando as caracteristicas individuais
  select(-c(IDADE_ANOS, IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ)) %>% 
  #substituindo
  left_join(.,pessoa_referencia_1718, 
            by = c('UF', 'REGIAO', 'ESTRATO_POF', 'TIPO_SITUACAO_REG', 'COD_UPA','NUM_DOM', 'NUM_UC'))


# Quantidade de pessoas em cada familia ----------------------------------------

qtd_pessoas_uc_1718 <- reg_morador_1718 %>% 
  group_by(UF, ESTRATO_POF, COD_UPA, NUM_DOM, NUM_UC) %>% 
  summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE))


# REGISTRO DESPESA INDIVIDUAL --------------------------------------------------

reg_despind_1718 <- readRDS('Dados/Derivados/DESPESA_INDIVIDUAL_1718.rds') %>% 
  #so as variaveis que queremos
  select(UF, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC, COD_INFORMANTE, 
         QUADRO, V9001, V8000, DEFLATOR, V8000_DEFLA, FATOR_ANUALIZACAO, PESO_FINAL, COD_IMPUT_VALOR) %>% 
  #deflacionando gastos
  mutate(VALOR_DESPESA_defl_ipca = V8000_DEFLA*deflator_ipca,
         TIPO_SITUACAO_REG = case_when(TIPO_SITUACAO_REG == 1 ~ 'Urbano',
                                       TIPO_SITUACAO_REG == 2 ~ 'Rural')) %>% 
  #renomeando algumas variaveis para padronizar com outras POFs
  rename(CODIGO_DESPESA = V9001,
         VALOR_DESPESA = V8000,
         VALOR_DESPESA_DEFLA = V8000_DEFLA,
         COD_IMPUT = COD_IMPUT_VALOR) %>% 
  #so queremos gastos com despesas financeiras
  filter(QUADRO == 26,
         CODIGO_DESPESA %in% c(2600201,
                               2600301,
                               2600501,
                               2600502,
                               2600504,
                               2600701,
                               2600901,
                               2600902,
                               2600903,
                               2601101)) %>% 
  #criando variavel com nome do produto
  mutate(NOME_DESPESA = case_when(CODIGO_DESPESA == 2600201 ~ 'juros_cart_cred', 
                             CODIGO_DESPESA == 2600301 ~ 'anuidade_cart_cred',
                             CODIGO_DESPESA == 2600501 ~ 'tarifa_cont_banc',
                             CODIGO_DESPESA == 2600502 ~ 'manut_cont_banc',
                             CODIGO_DESPESA == 2600504 ~ 'pacote_cont_banc',
                             CODIGO_DESPESA == 2600701 ~ 'tx_extrato',
                             CODIGO_DESPESA == 2600901 ~ 'transferencia',
                             CODIGO_DESPESA == 2600902 ~ 'transferencia',
                             CODIGO_DESPESA == 2600903 ~ 'transferencia',
                             CODIGO_DESPESA == 2601101 ~ 'cadastro_banc',
                             TRUE ~ as.character(NA))) %>% 
  #eliminando despesas nos quantis 1% e 99% (outliers)
  group_by(NOME_DESPESA) %>% 
  mutate(desp_inf = quantile(VALOR_DESPESA_defl_ipca, probs = c(0.01)),
         desp_sup = quantile(VALOR_DESPESA_defl_ipca, probs = c(0.99))) %>% 
  ungroup() %>%
  filter(VALOR_DESPESA_defl_ipca > desp_inf, VALOR_DESPESA_defl_ipca < desp_sup) %>% 
  #selecionando as variaveis que queremos
  select(UF, ESTRATO_POF, COD_UPA, NUM_DOM, NUM_UC, COD_INFORMANTE,
         QUADRO, CODIGO_DESPESA, NOME_DESPESA, COD_IMPUT, VALOR_DESPESA, DEFLATOR, VALOR_DESPESA_DEFLA, VALOR_DESPESA_defl_ipca,
         FATOR_ANUALIZACAO, PESO_FINAL)


# Merge despesa com outras bases -----------------------------------------------

                    #trazendo caracteristicas da pessoa de referencia da familia
reg_despind_1718 <- left_join(reg_despind_1718, pessoa_referencia_1718, 
                              by = c('UF', 'ESTRATO_POF', 'COD_UPA', 'NUM_DOM', 'NUM_UC')) %>% 
  #trazendo a quantidade de pessoas em cada Unidade de Consumo
  left_join(., qtd_pessoas_uc_1718, by = c('UF', 'ESTRATO_POF', 'COD_UPA', 'NUM_DOM', 'NUM_UC')) %>% 
  distinct()


# Analise registro de despesa individual ---------------------------------------

#contando os NAs
NAs_reg_despind_1718 <- sapply(reg_despind_1718, function(x) sum(is.na(x)))
# NAs em carteira assinada (provavelmente respondeu um questionario mas nao o outro) e em deflator

# alterando NA por "Sem informacao"
reg_despind_1718 <- reg_despind_1718 %>% 
  mutate(CARTEIRA_ASSINADA = case_when(is.na(CARTEIRA_ASSINADA) ~ "Sem informação",
                                       TRUE ~ CARTEIRA_ASSINADA))

# Salva Bases ------------------------------------------------------------------

saveRDS(reg_morador_1718, file = "Dados/Derivados/reg_morador_1718.RDS")
saveRDS(reg_despind_1718, file = "Dados/Derivados/reg_despind_1718.RDS")

