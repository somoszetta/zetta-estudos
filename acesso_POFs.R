#-------------------------------------------------------------------------------
# Estatisticas Agregadas Acesso a cartao de credito POFs -----------------------
#-------------------------------------------------------------------------------

#Como interpretar estatisticas aqui? Dentro de tal grupo, x% tem acesso a cartao de credito

#limpando ambiente
rm(list = ls())

#baixando base
reg_morador_0809 <- readRDS('Dados/Derivados/reg_morador_0809.RDS')
reg_morador_1718 <- readRDS('Dados/Derivados/reg_morador_1718.RDS')

# Funcao -----------------------------------------------------------------------

#funcao para calcular porcentagem de acesso
acesso_f <- function(abertura, cart_ass = F) {
  
  if(cart_ass == F){
  # POF 2008-2009
  estatistica1 = reg_morador_0809 %>% 
    group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, SEQ, DV_SEQ, NUM_DOM, NUM_UC,
             IDADE_AG, SEXO, RACA, PC_RENDA_defl_ipca, PC_RENDA_categ) %>% 
              #quantidade de pessoas na UC
    summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
              DUM_POSSUI = case_when(max(DUM_CART_CRED) > 0 ~ 1,
                                     max(DUM_CART_CRED) == 0 ~ 0,
                                     max(DUM_CART_CRED) == -1 ~ 0),
              PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS, 
              #expande
              DUM_POSSUI_EXP = DUM_POSSUI*PESO_FINAL) %>% 
    #agrupando
    group_by({{abertura}}) %>% 
    summarize(Cartao_Credito = sum(DUM_POSSUI_EXP) / sum(PESO_FINAL)) %>% 
    #adiciona coluna indicando a POF
    mutate(POF = '2008-2009')
  }
  
  # POF 2017-2018
  estatistica2 = reg_morador_1718 %>% 
    group_by(UF, REGIAO, ESTRATO_POF, TIPO_SITUACAO_REG, COD_UPA, NUM_DOM, NUM_UC,
             IDADE_AG, SEXO, RACA, CARTEIRA_ASSINADA, PC_RENDA_defl_ipca, PC_RENDA_categ) %>% 
    #indica se pelo menos uma pessoa na UC tem cartao de credito
    summarize(QTD_PESSOAS = n_distinct(COD_INFORMANTE),
              DUM_POSSUI = case_when(max(DUM_CART_CRED) > 0 ~ 1,
                                     max(DUM_CART_CRED) == 0 ~ 0,
                                     max(DUM_CART_CRED) == -1 ~ 0),
              PESO_FINAL = mean(PESO_FINAL)*QTD_PESSOAS, 
              #expande
              DUM_CART_CRED_EXP = DUM_POSSUI*PESO_FINAL) %>% 
    #agrupando
    group_by({{abertura}}) %>% 
    summarize(Cartao_Credito = sum(DUM_CART_CRED_EXP) / sum(PESO_FINAL),
              POF = '2017-2018')
  
  # junta (exceto para carteira assinada, que so temos 17-18)
  if(cart_ass == F){base_final = bind_rows(estatistica1, estatistica2)}  
  else{base_final = estatistica2}

  return(base_final)
}

# Aplicando --------------------------------------------------------------------

## Brasil ## 
acesso_BR <- bind_cols(Grupo = 'Brasil', acesso_f(abertura = c()))

## Urbano vs. Rural ##
acesso_UrbRur <- acesso_f(abertura = TIPO_SITUACAO_REG) 

## Regioes ## 
acesso_Regioes <- acesso_f(abertura = REGIAO) 

## Categorias de Renda Per Capita ## 
acesso_Renda <- acesso_f(abertura = PC_RENDA_categ)

## PESSOA DE REFERENCIA ##

## Raca ##
acesso_Raca <- acesso_f(abertura = RACA) 

## Sexo ##
acesso_Sexo <- acesso_f(abertura = SEXO) 

## Carteira Assinada ##
acesso_CartAss <- acesso_f(abertura = CARTEIRA_ASSINADA, cart_ass = T) 


# Salva em um Excel ------------------------------------------------------------

# Create a blank workbook
acesso <- createWorkbook()

# Add some sheets to the workbook
addWorksheet(acesso, "BR")
addWorksheet(acesso, "Urbano_Rural")
addWorksheet(acesso, "Regioes")
addWorksheet(acesso, "Raca")
addWorksheet(acesso, "Sexo")
addWorksheet(acesso, "Renda")
addWorksheet(acesso, "Carteira_Assinada")

# Write the data to the sheets
writeData(acesso, sheet = "BR", x = acesso_BR)
writeData(acesso, sheet = "Urbano_Rural", x = acesso_UrbRur)
writeData(acesso, sheet = "Regioes", x = acesso_Regioes)
writeData(acesso, sheet = "Raca", x = acesso_Raca)
writeData(acesso, sheet = "Sexo", x = acesso_Sexo)
writeData(acesso, sheet = "Renda", x = acesso_Renda)
writeData(acesso, sheet = "Carteira_Assinada", x = acesso_CartAss)

# Export the file
saveWorkbook(acesso, "Dados/Derivados/estats_acesso.xlsx", overwrite = T)



