# ------------------------------------------------------------------------------
# Proporcao de pessoas que NAO declaram gastos com cartao de credito -----------
# ------------------------------------------------------------------------------

# Esse script busca analisar a proporcao de pessoas que tem acesso a cartao de credito
# mas que nenhum membro da familia declarou gasto com anuidade

#limpando ambiente
rm(list = ls())

#baixando bases ----------------------------------------------------------------

reg_morador_0809 <- readRDS('Dados/Derivados/reg_morador_0809.RDS')
reg_morador_1718 <- readRDS('Dados/Derivados/reg_morador_1718.RDS')
reg_despind_0809 <- readRDS('Dados/Derivados/reg_despind_0809.RDS')
reg_despind_1718 <- readRDS('Dados/Derivados/reg_despind_1718.RDS')


# Manipulando despesas totais na UC --------------------------------------------

# POF 08-09
desp_tot_uc_0809 <- reg_despind_0809 %>%
  group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, SEQ, DV_SEQ, NUM_DOM, NUM_UC, NOME_DESPESA) %>% 
  summarize(VALOR_DESPESA_defl_ipca = sum(VALOR_DESPESA_defl_ipca)) %>% 
  #filtrando para anuidade de cartao de credito
  filter(NOME_DESPESA == "anuidade_cart_cred")

# POF 17-18
desp_tot_uc_1718 <- reg_despind_1718 %>% 
  group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC, NOME_DESPESA) %>% 
  summarize(VALOR_DESPESA_defl_ipca = sum(VALOR_DESPESA_defl_ipca)) %>% 
  #filtrando para anuidade de cartao de credito
  filter(NOME_DESPESA == "anuidade_cart_cred")


# Manipulando Registro Morador -------------------------------------------------

# calculo se tem disponibilidade de cartao de credito na UC 

# POF 08-09
acesso_0809 <- reg_morador_0809 %>%
  group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, SEQ, DV_SEQ, NUM_DOM, NUM_UC) %>% 
  #indica se pelo menos uma pessoa na UC tem cartao de credito
  summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
            DUM_POSSUI = case_when(max(DUM_CART_CRED) > 0 ~ 1,
                                   max(DUM_CART_CRED) == 0 ~ 0,
                                   max(DUM_CART_CRED) == -1 ~ 0),
            PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS) %>% 
  #so queremos os que possuem acesso a cartao de credito
  filter(DUM_POSSUI == 1)

# POF 17-18            
acesso_1718 <- reg_morador_1718 %>% 
  group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC) %>% 
  #indica se pelo menos uma pessoa na UC tem cartao de credito
  summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
            DUM_POSSUI = case_when(max(DUM_CART_CRED) > 0 ~ 1,
                                   max(DUM_CART_CRED) == 0 ~ 0,
                                   max(DUM_CART_CRED) == -1 ~ 0),
            PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS) %>% 
  #so queremos os que possuem acesso a cartao de credito
  filter(DUM_POSSUI == 1)


# Join nas bases ---------------------------------------------------------------

# POF 08-09
base_0809 <- left_join(acesso_0809, desp_tot_uc_0809, 
                       by = c('UF', 'REGIAO', 'ESTRATO_POF', 'TIPO_SITUACAO_REG', 'SEQ', 'DV_SEQ', 'NUM_DOM', 'NUM_UC')) 

# POF 17-18
base_1718 <- left_join(acesso_1718, desp_tot_uc_1718, 
                       by = c('UF', 'REGIAO', 'ESTRATO_POF', 'TIPO_SITUACAO_REG', 'COD_UPA', 'NUM_DOM', 'NUM_UC')) 


# Calcula estatistica ----------------------------------------------------------


# funcao que calcula, dentre aqueles com acesso a cartao de credito, quantos % nao declararam gastos com anuidade

p_s_gasto <- function(base, pof) {
  
  # base é a base para calculo
  # pof pertence a c('2008-2009', '2017-2018')
  
  base = base %>% mutate(Grupo = "Brasil")

  #quantas pessoas nao declararam gasto
  estat_zero = base %>%
    filter(is.na(VALOR_DESPESA_defl_ipca)) %>% 
    group_by(Grupo) %>% 
    summarize(numerador = sum(PESO_FINAL))
  
  #quantas pessoas existem no total
  estat_total = base %>% 
    group_by(Grupo) %>% 
    summarize(denominador = sum(PESO_FINAL))
  
  #junta
  estat = full_join(estat_zero, estat_total, by = "Grupo") %>% 
    mutate(porcentagem = numerador/denominador,
           POF = pof) %>% 
    select(-c(numerador, denominador)) 
  
  return(estat)
    
}


# Aplica -----------------------------------------------------------------------

final <- bind_rows(p_s_gasto(base = base_0809, pof = '2008-2009'),
                   p_s_gasto(base = base_1718, pof = '2017-2018'))


# Exportando para Excel --------------------------------------------------------

# Create a blank workbook
semgasto <- createWorkbook()

# Add some sheets to the workbook
addWorksheet(semgasto, "BR")

# Write the data to the sheets
writeData(semgasto, sheet = "BR", x = final)

# Export the file
saveWorkbook(semgasto, "Dados/Derivados/estats_semgasto.xlsx", overwrite = T)

