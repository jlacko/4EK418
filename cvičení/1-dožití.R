# úkol = zakreslit kartogram [CZE] / choropleth map [ENG]
# střední doby dožití při narození kluků &  holčiček 
#   1) po okresech
#   2) po ORP

library(tidyverse) # protože dplyr, ggplot2 a spol.

# Naděje dožití v okresech a správních obvodech ORP při narození
raw_hope <- czso::czso_get_table("130140") %>% 
   filter(casref_do == as.Date("2021-12-31 UTC") & # poslední řez
          vek_kod == "400000600001000" ) # při narození

# nápověda:
# - okresy jsou v RCzechia::okresy()
# - ORP jsou v RCzechia::orp_polygony()