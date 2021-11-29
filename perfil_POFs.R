# ------------------------------------------------------------------------------
# Perfil de quem tem acesso a cartao de credito --------------------------------
# ------------------------------------------------------------------------------

# queremos saber qual o perfil dos que tem cartao de credito
# e tambem o perfil da populacao brasileira segundo a POF

#limpando environment
rm(list = ls())

# Baixando Bases ---------------------------------------------------------------

reg_morador_0809 <- readRDS('Dados/Derivados/reg_morador_0809.rds') 
reg_morador_1718 <- readRDS('Dados/Derivados/reg_morador_1718.rds') 

# Funcoes ----------------------------------------------------------------------

#funcao para calcular perfil de quem tem cartao de credito
estats_cc_f <- function(grupo, pof) {
  
  if(pof == "0809"){
  estats = reg_morador_0809 %>% 
    group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, SEQ, DV_SEQ, NUM_DOM, NUM_UC,
             IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ) %>% 
    #indica se pelo menos uma pessoa na UC tem cartao de credito
    summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
              DUM_POSSUI = case_when(max(DUM_CART_CRED) > 0 ~ 1,
                                     max(DUM_CART_CRED) == 0 ~ 0,
                                     max(DUM_CART_CRED) == -1 ~ 0),
              PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS, 
              #expande
              DUM_POSSUI_EXP = DUM_POSSUI*PESO_FINAL) %>% 
    #seleciona UCs que tem cartao de credito
    filter(DUM_POSSUI == 1) %>% 
    #calcula participacao das categorias dentre quem tem cartao de credito
    group_by({{grupo}}) %>% 
    summarize(qtd = sum(PESO_FINAL)) %>% 
    mutate(total = sum(qtd),
           share = qtd/total) %>% 
    select(-c(qtd, total)) %>% 
    mutate(POF = '2008-2009')
  }
  
  if(pof == "1718"){
  estats = reg_morador_1718 %>% 
    group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC,
             IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ, CARTEIRA_ASSINADA) %>% 
    #indica se pelo menos uma pessoa na UC tem cartao de credito
    summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
              DUM_POSSUI = case_when(max(DUM_CART_CRED) > 0 ~ 1,
                                     max(DUM_CART_CRED) == 0 ~ 0,
                                     max(DUM_CART_CRED) == -1 ~ 0),
              PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS, 
              #expande
              DUM_POSSUI_EXP = DUM_POSSUI*PESO_FINAL) %>% 
    filter(DUM_POSSUI == 1) %>% 
    #calcula participacao das categorias dentre quem tem cartao de credito
    group_by({{grupo}}) %>% 
    summarize(qtd = sum(PESO_FINAL)) %>% 
    mutate(total = sum(qtd),
           share = qtd/total) %>% 
    select(-c(qtd, total)) %>% 
    mutate(POF = '2017-2018')
  }
  
  return(estats)
  
}

#funcao para calcular perfil pof
perfil_pof <- function(grupo, pof) {
  
  if(pof == "0809"){
  estats = reg_morador_0809 %>% 
    group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, SEQ, DV_SEQ, NUM_DOM, NUM_UC,
             IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ) %>% 
    #peso total da UC
    summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
              PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS) %>%
    #calcula participacao das categorias na POF
    group_by({{grupo}}) %>% 
    summarize(qtd = sum(PESO_FINAL)) %>% 
    mutate(total = sum(qtd),
           share = qtd/total) %>% 
    select(-c(qtd, total)) %>% 
    mutate(POF = '2008-2009')
  }
  
  if(pof == "1718"){
  estats = reg_morador_1718 %>% 
    group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC,
             IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ, CARTEIRA_ASSINADA) %>% 
    #peso total da UC
    summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
              PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS) %>% 
    #calcula participacao das categorias na POF
    group_by({{grupo}}) %>% 
    summarize(qtd = sum(PESO_FINAL)) %>% 
    mutate(total = sum(qtd),
           share = qtd/total) %>% 
    select(-c(qtd, total)) %>% 
    mutate(POF = '2017-2018')
  }

  return(estats)
  
}


# Aplicando funcao para cartao de credito --------------------------------------

# Regioes
cc_regioes <- bind_rows(estats_cc_f(REGIAO, "0809"), estats_cc_f(REGIAO, "1718"))

# Urbano vs. Rural
cc_estrato <- bind_rows(estats_cc_f(TIPO_SITUACAO_REG, "0809"), estats_cc_f(TIPO_SITUACAO_REG, "1718"))

# Renda Per Capita 
cc_renda <- bind_rows(estats_cc_f(PC_RENDA_categ, "0809"), estats_cc_f(PC_RENDA_categ, "1718"))

# Raca
cc_raca <- bind_rows(estats_cc_f(RACA, "0809"), estats_cc_f(RACA, "1718"))

# Sexo
cc_sexo <- bind_rows(estats_cc_f(SEXO, "0809"), estats_cc_f(SEXO, "1718")) 

# Carteira Assinada
cc_carteira <- estats_cc_f(CARTEIRA_ASSINADA, "1718")


# Aplicando funcao para perfil pof ---------------------------------------------

# Regioes
perfil_regioes <- bind_rows(perfil_pof(REGIAO, "0809"), perfil_pof(REGIAO, "1718"))

# Urbano vs. Rural
perfil_estrato <- bind_rows(perfil_pof(TIPO_SITUACAO_REG, "0809"), perfil_pof(TIPO_SITUACAO_REG, "1718"))

# Renda Per Capita 
perfil_renda <- bind_rows(perfil_pof(PC_RENDA_categ, "0809"), perfil_pof(PC_RENDA_categ, "1718"))

# Raca
perfil_raca <- bind_rows(perfil_pof(RACA, "0809"), perfil_pof(RACA, "1718"))

# Sexo
perfil_sexo <- bind_rows(perfil_pof(SEXO, "0809"), perfil_pof(SEXO, "1718"))

# Carteira Assinada
perfil_carteira <- perfil_pof(CARTEIRA_ASSINADA, "1718")


# SALVANDO EXCEL --------------------------------------------------------------

# Cartao de Credito -----

# Create a blank workbook
cc <- createWorkbook()

# Add some sheets to the workbook
addWorksheet(cc, "Urbano_Rural")
addWorksheet(cc, "Regioes")
addWorksheet(cc, "Raca")
addWorksheet(cc, "Sexo")
addWorksheet(cc, "Renda")
addWorksheet(cc, "Carteira")

# Write the data to the sheets
writeData(cc, sheet = "Urbano_Rural", x = cc_estrato)
writeData(cc, sheet = "Regioes", x = cc_regioes)
writeData(cc, sheet = "Raca", x = cc_raca)
writeData(cc, sheet = "Sexo", x = cc_sexo)
writeData(cc, sheet = "Renda", x = cc_renda)
writeData(cc, sheet = "Carteira", x = cc_carteira)

# Export the file
saveWorkbook(cc, "Dados/Derivados/perfil_cartcred.xlsx", overwrite = T)

# PERFIL POF -----

# Create a blank workbook
perfil_pof <- createWorkbook()

# Add some sheets to the workbook
addWorksheet(perfil_pof, "Urbano_Rural")
addWorksheet(perfil_pof, "Regioes")
addWorksheet(perfil_pof, "Raca")
addWorksheet(perfil_pof, "Sexo")
addWorksheet(perfil_pof, "Renda")
addWorksheet(perfil_pof, "Carteira")

# Write the data to the sheets
writeData(perfil_pof, sheet = "Urbano_Rural", x = perfil_estrato)
writeData(perfil_pof, sheet = "Regioes", x = perfil_regioes)
writeData(perfil_pof, sheet = "Raca", x = perfil_raca)
writeData(perfil_pof, sheet = "Sexo", x = perfil_sexo)
writeData(perfil_pof, sheet = "Renda", x = perfil_renda)
writeData(perfil_pof, sheet = "Carteira", x = perfil_carteira)

# Export the file
saveWorkbook(perfil_pof, "Dados/Derivados/perfil_pofs.xlsx", overwrite = T)
