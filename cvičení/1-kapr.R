# úkol = zakreslit kartogram [CZE] / choropleth map [ENG]
# ceny vánočního kapra v roce 2018 (poslední známý) po krajích

library(tidyverse) # protože dplyr, ggplot2 a spol.

# podkladová data - ceny potravin (spotřební koš ČSÚ) v regionech a čase

# Průměrné spotřebitelské ceny vybraných výrobků - potravinářské výrobky
kapr <- czso::czso_get_table("012052")  %>% 
   filter(reprcen_txt %in% c("Kapr živý [1 kg]")   # relevantní cenový reprezentant,
          & uzemi_txt != "Česká republika"         # pouze regionální hodnoty (tj. ne ČR jako celek)
          & obdobiod >= "2018-12-01" 
          & obdobido <= "2019-01-01") 

# nápověda:
# - všechny kraje jsou v RCzechia::kraje()