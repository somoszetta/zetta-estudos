#-------------------------------------------------------------------------------
# Estatisticas de Acesso x Renda -----------------------------------------------
#-------------------------------------------------------------------------------

#limpando ambiente
rm(list = ls())

#baixando bases ----------------------------------------------------------------

reg_morador_0809 <- readRDS('Dados/Derivados/reg_morador_0809.RDS')
reg_morador_1718 <- readRDS('Dados/Derivados/reg_morador_1718.RDS')

# Funcao -----------------------------------------------------------------------

#funcao para calcular acesso a cartao de credito, abrindo por outros condicionantes e renda
acesso_f <- function(abertura, pof) {
  
  if(pof == '0809') {
    estatistica = reg_morador_0809 %>% 
      group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, SEQ, DV_SEQ, NUM_DOM, NUM_UC,
               IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ) %>% 
      #indica se pelo menos uma pessoa na UC tem o servico
      summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
                DUM_POSSUI = case_when(max(DUM_CART_CRED) > 0 ~ 1,
                                       max(DUM_CART_CRED) == 0 ~ 0,
                                       max(DUM_CART_CRED) == -1 ~ 0),
                #peso final
                PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS, 
                #expande
                DUM_POSSUI_EXP = DUM_POSSUI*PESO_FINAL) %>% 
      #agrupando
      group_by({{abertura}}, PC_RENDA_categ) %>% 
      summarize(porcentagem = sum(DUM_POSSUI_EXP) / sum(PESO_FINAL)) %>% 
      mutate(POF = '2008-2009')
    
  }
  
  if(pof == '1718') {
  estatistica = reg_morador_1718 %>% 
    group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC,
             IDADE_AG, SEXO, RACA, CARTEIRA_ASSINADA, PC_RENDA_defl_ipca, PC_RENDA_categ) %>% 
    #indica se pelo menos uma pessoa na UC tem o servico
    summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
              DUM_POSSUI = case_when(max(DUM_CART_CRED) > 0 ~ 1,
                                     max(DUM_CART_CRED) == 0 ~ 0,
                                     max(DUM_CART_CRED) == -1 ~ 0),
              #peso final
              PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS, 
              #expande
              DUM_POSSUI_EXP = DUM_POSSUI*PESO_FINAL) %>% 
    group_by({{abertura}}, PC_RENDA_categ) %>% 
    summarize(porcentagem = sum(DUM_POSSUI_EXP) / sum(PESO_FINAL)) %>% 
    mutate(POF = '2017-2018')
  
  }
  
  return(estatistica)
}


# Aplica funcao ----------------------------------------------------------------

# Regioes e Renda
a_cc_Regioes_RENDA <- bind_rows(acesso_f(REGIAO, pof = '0809'), acesso_f(REGIAO, pof = '1718'))

# Urbano ou Rural e Renda
a_cc_UrbRur_RENDA <- bind_rows(acesso_f(TIPO_SITUACAO_REG, pof = '0809'), acesso_f(TIPO_SITUACAO_REG, pof = '1718'))

# Raca e Renda
a_cc_RACA_RENDA <- bind_rows(acesso_f(RACA, pof = '0809'), acesso_f(RACA, pof = '1718')) 

# Sexo e Renda
a_cc_SEXO_RENDA <- bind_rows(acesso_f(SEXO, pof = '0809'), acesso_f(SEXO, pof = '1718'))

# Carteira Assinada e Renda
a_cc_CARTEIRA_RENDA <- acesso_f(CARTEIRA_ASSINADA, pof = '1718') 


# Salvando excel ---------------------------------------------------------------

# Create a blank workbook
acesso_renda <- createWorkbook()

# Add some sheets to the workbook
addWorksheet(acesso_renda, "REG_RENDA")
addWorksheet(acesso_renda, "UrbRur_RENDA")
addWorksheet(acesso_renda, "RACA_RENDA")
addWorksheet(acesso_renda, "SEXO_RENDA")
addWorksheet(acesso_renda, "CARTEIRA_RENDA")

# Write the data to the sheets
writeData(acesso_renda, sheet = "REG_RENDA", x = a_cc_Regioes_RENDA)
writeData(acesso_renda, sheet = "UrbRur_RENDA", x = a_cc_UrbRur_RENDA)
writeData(acesso_renda, sheet = "RACA_RENDA", x = a_cc_RACA_RENDA)
writeData(acesso_renda, sheet = "SEXO_RENDA", x = a_cc_SEXO_RENDA)
writeData(acesso_renda, sheet = "CARTEIRA_RENDA", x = a_cc_CARTEIRA_RENDA)

# Export the file
saveWorkbook(acesso_renda, "Dados/Derivados/estats_acesso_cc_renda.xlsx", overwrite = T)