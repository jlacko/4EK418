# úkol = změřit, jakou délku má tok řeky Nilu v jednotlivých státech světa

library(sf)
library(dplyr)
library(giscoR)
library(ggplot2)

# všechny státy světa, jedna ku 60 milionům
staty_sveta <- gisco_get_countries(resolution = "60")

# řeka Nil, jedna ku 50 milionům
reka_nil <- st_read("./data/ne_50m_rivers_lake_centerlines.shp") %>% 
   filter(name_en %in% c("Nile", "White Nile")) %>% 
   summarise() # spojení do jednoho objektu (jeden Nil!)

# nápověda:pozor na falešného přítele!:
# - sf::st_intersection() vrací geometrii / průsečík
# - sf::st_intersects() vrací potvrzení geometrie (logickou hodnotu nebo pořadí)


st_intersection(reka_nil,
                staty_sveta) %>% 
  mutate(delka_nilu = st_length(.)) %>% 
  st_drop_geometry() %>% 
  arrange(desc(delka_nilu))


