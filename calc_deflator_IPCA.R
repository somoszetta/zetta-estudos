#-------------------------------------------------------------------------------
# IPCA -------------------------------------------------------------------------
#-------------------------------------------------------------------------------

## Nesse codigo:
# Carregamos dados do IPCA
# Geramos deflator para niveis de dez/2020 

#limpando ambiente
rm(list = ls())

dt_ipca <- read_delim("Dados/Originais/IBGE/IPCA/tabela1737.csv", skip = 3, 
                      delim = ";", col_types = cols("-", "c", "c"),
                      col_names = c("data", "ipca_indice")) %>% 
  #removendo linhas finais que sao NAs e notas
  na.omit() %>% 
         #substituindo ponto por vazio, virgula por ponto, e transformando em numerico
  mutate(across(c(-1), function(x) {gsub(".", "", x, fixed = T) %>% gsub(",", ".", .) %>% as.numeric()}),
         #gerando colunas de mes e ano
         mes = case_when(startsWith(data, 'jan') ~ 1,
                         startsWith(data, 'fev') ~ 2,
                         startsWith(data, 'mar') ~ 3,
                         startsWith(data, 'abr') ~ 4,
                         startsWith(data, 'mai') ~ 5,
                         startsWith(data, 'jun') ~ 6,
                         startsWith(data, 'jul') ~ 7,
                         startsWith(data, 'ago') ~ 8,
                         startsWith(data, 'set') ~ 9,
                         startsWith(data, 'out') ~ 10,
                         startsWith(data, 'nov') ~ 11,
                         startsWith(data, 'dez') ~ 12),
         ano = str_sub(data, - 4, - 1) %>% as.numeric()) %>% 
  #tirando coluna data
  select(-data)
         
#Queremos deflacionar a valores de dezembro/2020

#recuperando indice da linha
index_basedate <- which((dt_ipca$ano == 2020) & (dt_ipca$mes == 12))

dt_ipca <- dt_ipca %>% 
  mutate(deflator = (ipca_indice[index_basedate])/ipca_indice) %>% 
  select(-ipca_indice)


#salvando base
saveRDS(dt_ipca, file = "Dados/Derivados/deflator_ipca.RDS")
