# rozdělit kraje ČR na dvě části / Čechy a Moravu
# 1) podle krajů
# 2) podle řeky Moravy

library(sf)
library(dplyr)
library(ggplot2)
library(RCzechia)

# toto jsou kraje
kraje <- kraje("low") # nízké rozlišení je elegantnější

# toto je řeka morava
reka_morava <- reky(resolution = "low") %>% # nepotřebujeme každou kličku a meandr
  filter(NAZEV == "Morava") %>% 
  summarize() %>% 
  st_geometry()
  

# nápověda:
# - potřebujete 2 části / bude se hodit dplyr::group_by & dplyr::summarize
# - Moravské kraje mají kód vyšší jak 3110 (Vysočina je divná, uznám jí v obojím...)

ggplot() +
   geom_sf(data = kraje) +
   geom_sf(data = reka_morava, color = "steelblue") +
   geom_sf_label(data = kraje, aes(label = KOD_KRAJ)) 


morava_ciselne <- kraje %>% 
  mutate(je_morava = as.numeric(KOD_KRAJ) >= 3108) %>% 
  group_by(je_morava) %>% 
  summarize()

ggplot() +
  geom_sf(data = morava_ciselne, aes(fill = je_morava)) +
  geom_sf(data = reka_morava, color = "steelblue")  
  
morava_rekou <- kraje %>% 
  summarize() %>% 
  lwgeom::st_split(reka_morava) %>% 
  st_collection_extract("POLYGON") %>% 
  filter(st_area(.) > units::set_units(10, "km2"))

plot(morava_rekou)
