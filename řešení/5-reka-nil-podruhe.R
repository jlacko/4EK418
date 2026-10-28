# úkol = změřit, jakou délku má tok řeky Nilu v jednotlivých státech světa
# setřídit podle délky uvnitř států

library(sf)
library(dplyr)
library(giscoR)
library(ggplot2)

# všechny státy světa, jedna ku 60 milionům
staty_sveta <- gisco_get_countries(resolution = "60") %>% 
  filter(st_is_valid(.))

# řeka Nil, jedna ku 50 milionům
reka_nil <- st_read("./data/ne_50m_rivers_lake_centerlines.shp") %>% 
  filter(name_en %in% c("Nile", "White Nile", "Rosetta Branch")) %>% 
  summarise() # spojení do jednoho objektu (jeden Nil!)

# nápověda:pozor na falešného přítele!:
# - sf::st_intersection() vrací geometrii / průsečík
# - sf::st_intersects() vrací potvrzení geometrie (logickou hodnotu nebo pořadí)

reka_nil %>% 
  st_length() %>% 
  units::set_units("km")

st_intersection(staty_sveta, reka_nil) %>% 
  mutate(delka_nilu = st_length(.)) %>% 
  select(CNTR_NAME, delka_nilu) %>% 
  st_drop_geometry() 
