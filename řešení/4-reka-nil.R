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
  filter(name_en %in% c("Nile", "White Nile", "Rosetta Branch")) %>% 
  summarise() # spojení do jednoho objektu (jeden Nil!)

# nápověda:
# - při volání sf::st_intersects věnujte pozornost argumentu sparse


# řidký index = sparse = T
cisla <- st_intersects(reka_nil, staty_sveta) %>% 
  unlist()

staty_sveta[cisla,]

# hustý vektor = sparse = F

staty_sveta$ma_nil <- st_intersects(reka_nil, staty_sveta, sparse = F)[1, ]

ggplot() +
  geom_sf(data = staty_sveta, aes(fill = ma_nil)) +
  geom_sf(data = reka_nil, color = "steelblue")

# za bonusové body: pokuste se o zajímavější CRS nežli 4326!

ggplot() +
  geom_sf(data = staty_sveta, aes(fill = ma_nil)) +
  geom_sf(data = reka_nil, color = "steelblue") +
  coord_sf(crs = st_crs("ESRI:53009"))
