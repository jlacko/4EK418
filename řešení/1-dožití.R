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

library(sf)

# okresy / n = 77
podklad_okresy <- RCzechia::okresy() %>% 
  left_join(raw_hope, by = c("KOD_OKRES" = "vuzemi_kod"))

ggplot(data = podklad_okresy) +
  geom_sf(aes(fill = hodnota), color = NA) +
  facet_wrap(~pohlavi_txt)

# ORP / n = 206
podklad_ORP <- RCzechia::orp_polygony() %>% 
  left_join(raw_hope, by = c("KOD_ORP" = "vuzemi_kod"))

ggplot(data = podklad_ORP) +
  geom_sf(aes(fill = hodnota), color = NA) +
  facet_wrap(~pohlavi_txt)

