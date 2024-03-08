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

staty_sveta <- staty_sveta %>% 
  mutate(obsahuje_nil = st_intersects(., reka_nil, sparse = F))

ggplot() +
  geom_sf(data = staty_sveta, aes(fill = obsahuje_nil)) +
  geom_sf(data = reka_nil, color = "steelblue") +
  # systém pana Mollweida za bonusové body :)
  coord_sf(crs = "ESRI:53009") 


# za bonusové body: pokuste se o zajímavější CRS nežli 4326!

