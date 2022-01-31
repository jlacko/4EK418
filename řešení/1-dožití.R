# úkol = zakreslit kartogram [CZE] / choropleth map [ENG]
# střední doby dožití při narození kluků &  holčiček 
#   1) po okresech
#   2) po ORP

library(tidyverse) # protože dplyr, ggplot2 a spol.

# metadata tabulky
czso::czso_get_table_schema("130140")

# dokumentace sady = https://www.czso.cz/documents/10180/61566288/130140-17dds.pdf

# Naděje dožití v okresech a správních obvodech ORP při narození
raw_hope <- czso::czso_get_table("130140") %>% 
   filter(casref_do == as.Date("2020-12-31 UTC") & # poslední řez
          vek_kod == "400000600001000" ) # při narození

# nápověda:
# - okresy jsou v RCzechia::okresy()
# - ORP jsou v RCzechia::orp_polygony()

okresy_hope <- RCzechia::okresy() %>% 
  inner_join(raw_hope, by = c("KOD_OKRES" = "vuzemi_kod")) %>% 
  mutate(pohlavi = case_when(pohlavi_kod == 2 ~ "holky", # přepíšu kód na text / vypadá lépe v záhlaví
                             pohlavi_kod == 1 ~ "kluci",
                             T ~ "něco jiného..."))

ggplot(data = okresy_hope) + 
  geom_sf(aes(fill = hodnota)) +
  facet_grid(cols = vars(pohlavi))

# jediný rozdíl proti viz výše = RCzechia::okresy >> RCzechia::orp_polygony; jinak copy / paste
okresy_hope <- RCzechia::orp_polygony() %>% 
  inner_join(raw_hope, by = c("KOD_ORP" = "vuzemi_kod")) %>% 
  mutate(pohlavi = case_when(pohlavi_kod == 2 ~ "holky",
                             pohlavi_kod == 1 ~ "kluci",
                             T ~ "něco jiného..."))

ggplot(data = okresy_hope) + 
  geom_sf(aes(fill = hodnota)) +
  facet_grid(cols = vars(pohlavi))