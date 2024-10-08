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

# řidká číslíčka / sparse na defaultu
indexy <- st_intersects(reka_nil, staty_sveta)

# hustý boolean / sparse explictně zmíněno, a prohozeno pořadí čeho s čím
staty_sveta$ma_nil <- st_intersects(staty_sveta, reka_nil, sparse = F)

# alternativní výběr:
staty_sveta[indexy[[1]], ]  # subsetem přes indexy
staty_sveta[staty_sveta$ma_nil, ] # subsetem přes boolean vektor; musí vyjít stejně 

# ukázaná platí...
ggplot() +
  geom_sf(data = staty_sveta, aes(fill = ma_nil)) + # výhoda boolean proměnné = jde namapovat na estetiku "barva výplně"
  geom_sf(data = reka_nil, color = "steelblue") +
  coord_sf(crs = "ESRI:54009") # projekce pana Molleweide za bonusové body...

# za bonusové body: pokuste se o zajímavější CRS nežli 4326!

