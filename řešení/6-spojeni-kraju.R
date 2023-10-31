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


kraje_cislem <- kraje %>% 
  mutate(zeme = ifelse(KOD_KRAJ < "3100", "Čechy", "Morava")) %>% 
  group_by(zeme) %>% 
  summarise()
  
kraje_sekyrou <- kraje %>% 
  summarize() %>% 
  lwgeom::st_split(reka_morava)
