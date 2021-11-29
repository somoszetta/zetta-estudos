#-------------------------------------------------------------------------------
# Master Zetta -----------------------------------------------------------------
#-------------------------------------------------------------------------------

# limpando ambiente
rm(list = ls())

# pacotes necessarios
library(openxlsx)
library(lubridate)
library(tidyverse)

#diretorio
setwd("G:/My Drive/3o_estudo_Zetta")

## Deflator IPCA ---------------------------------------------------------------

  # Calcula deflator a niveis de dez/2020

  #input: "Originais/IBGE/IPCA/tabela1737.csv"
  #output: "Derivados/deflator_ipca.RDS"  

  source('Codigos/calc_deflator_IPCA.R', encoding = "UTF-8")

## Carrega dados POF 2008/2009 -------------------------------------------------

  # Carrega dados da POF 2008-2009, a partir dos dados brutos em txt,

  #inputs: 'Dados/Originais/IBGE/POF/0809/Dados/T_MORADOR_S.txt', 'Dados/Originais/IBGE/POF/0809/Dados/T_DESPESA_INDIVIDUAL_S.txt'
  #outputs: "Dados/Derivados/MORADOR_0809.rds", "Dados/Derivados/DESPESA_INDIVIVIDUAL_0809.rds"

  source('Codigos/carrega_dados_POF0809.R', encoding = "UTF-8")


## Carrega dados POF 2017/2018 -------------------------------------------------

  # Carrega dados da POF 2017-2018, a partir dos dados brutos em txt,
  # e usando os codigos disponibilizados pelo IBGE em Programas de Leitura

  #input: "Dados/Originais/IBGE/POF/1718/Dados_20210304/MORADOR.txt", "Dados/Originais/IBGE/POF/1718/Dados_20210304/RENDIMENTO_TRABALHO.txt",
          #"Dados/Originais/IBGE/POF/1718/Dados_20210304/DESPESA_INDIVIDUAL.txt"
  #outputs: "Dados/Derivados/MORADOR_1718.rds", "Dados/Derivados/DESPESA_INDIVIDUAL_1718.rds",
            # "Dados/Derivados/RENDIMENTO_TRABALHO_1718.rds"

  source('Codigos/carrega_dados_POF1718.R', encoding = "UTF-8")

## Manipula dados POF 2008/2009 ------------------------------------------------

  # Organiza bases dos registros que estamos interessados. Substitui codigos por descricao,
  # deflaciona, seleciona variaveis desejadas. 
  # Salva bases para construcao de estatisticas agregadas

  #inputs: 'Dados/Derivados/deflator_ipca.RDS', 'Dados/Derivados/MORADOR_0809.RDS',
          # 'Dados/Derivados/DESPESA_INDIVIVIDUAL_0809.RDS'  
  #outputs: "Dados/Derivados/reg_morador_0809.RDS", "Dados/Derivados/reg_despind_0809.RDS",

  source('Codigos/manip_dados_POF0809.R', encoding = "UTF-8")

## Manipula dados POF 2017/2018 ------------------------------------------------

  #inputs: 'Dados/Derivados/deflator_ipca.RDS', 'Dados/Derivados/MORADOR_1718.rds'
          # 'Dados/Derivados/DESPESA_INDIVIDUAL_1718.rds', 'Dados/Derivados/RENDIMENTO_TRABALHO_1718.rds'
  #outputs: "Dados/Derivados/reg_morador_1718.RDS", "Dados/Derivados/reg_despind_1718.RDS",

  source('Codigos/manip_dados_POF1718.R', encoding = "UTF-8")

## Estatisticas Acesso a Cartao de Credito POFs 2008-2009, 2017-2018 -----------

  # Gera estatisticas de disponibilidade de cartao de credito, total e por grupos
  
  #inputs: 'Dados/Derivados/reg_morador_0809.RDS', 'Dados/Derivados/reg_morador_1718.RDS'
  #outputs: "Dados/Derivados/estats_acesso.xlsx"

  source('Codigos/acesso_POFs.R', encoding = "UTF-8")

## Estatisticas Acesso a Cartao de Credito x Renda POFs 2008-2009, 2017-2018 ---

  # Gera estatisticas de disponibilidade de cartao de credito x renda, total e por grupos

  # inputs: 'Dados/Derivados/reg_morador_0809.RDS', 'Dados/Derivados/reg_morador_1718.RDS'
  # outputs: "Dados/Derivados/estats_acesso_cc_renda.xlsx"

  source('Codigos/acesso_renda_POFs.R', encoding = "UTF-8")

## Estatisticas de Perfil POF --------------------------------------------------

  # perfil das pofs e daqueles que tem acesso a cartao de credito

  # inputs: 'Dados/Derivados/reg_morador_0809.RDS', 'Dados/Derivados/reg_morador_1718.RDS'
  # outputs: "Dados/Derivados/perfil_cartcred.xlsx", "Dados/Derivados/perfil_pofs.xlsx"

  source('Codigos/perfil_POFs.R', encoding = "UTF-8")

## Proporcao de pessoas que NAO declaram gastos com servicos financeiros -------

  # calcula, dentre aqueles com acesso a cartao de credito, a proporcao de pessoas em familias
  # em que nenhum membro declarou gastos com anuidade

  # inputs:   # 'Dados/Derivados/reg_morador_0809.RDS'
              # 'Dados/Derivados/reg_morador_1718.RDS'
              # 'Dados/Derivados/reg_despind_0809.RDS'
              # 'Dados/Derivados/reg_despind_1718.RDS'
  # outputs: "Dados/Derivados/estats_semgasto.xlsx"

  source('Codigos/proporcao_gastos_POFs.R', encoding = "UTF-8")
