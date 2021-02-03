# úkol = změřit, jakou délku má tok řeky Nilu v jednotlivých státech světa

library(sf)
library(giscoR)
library(ggplot2)
library(dplyr)

# všechny státy světa, jedna ku 60 milionům
staty_sveta <- gisco_get_countries(resolution = "60")

# řeka Nil, jedna ku 50 milionům
reka_nil <- st_read("./data/ne_50m_rivers_lake_centerlines.shp") %>% 
   filter(name_en %in% c("Nile", "White Nile")) %>% 
   summarise() # spojení do jednoho objektu (jeden Nil!)

# nápověda:pozor na falešného přítele!:
# - sf::st_intersection() vrací geometrii / průsečík
# - sf::st_intersects() vrací potvrzení geometrie (logickou hodnotu nebo pořadí)

pruseciky <- reka_nil %>% 
  st_intersection(staty_sveta)

pruseciky %>% 
  mutate(delka = st_length(.)) %>% 
  st_drop_geometry() %>% 
  select(stat = NAME_ENGL, delka)


