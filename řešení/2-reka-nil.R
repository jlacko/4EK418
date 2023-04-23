# úkol = řeka Nil a státy světa
# 1) zjistit státy světa, kterými protéká řeka Nil
# 2) ukázat je na mapě barevně

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

# nápověda:
# - při volání sf::st_intersects věnujte pozornost argumentu sparse

staty_sveta$ma_nil <- st_intersects(staty_sveta,
                                    reka_nil, sparse = F)

# za bonusové body: pokuste se o zajímavější CRS nežli 4326!

ggplot(data = staty_sveta) +
  geom_sf(aes(fill = ma_nil)) +
  coord_sf(crs = st_crs("ESRI:54019"))