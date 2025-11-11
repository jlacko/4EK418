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


# varianta podle krajů

kraje %>% 
  mutate(morava = as.numeric(kraje$KOD_KRAJ > 3110)) %>% 
  group_by(morava) %>% 
  summarise() %>% 
  ggplot(aes(fill = morava)) +
    geom_sf()

# varianta rozseknout podle řeky Moravy
kraje %>% 
  summarise() %>% # rozpuštění vnitřních hranic podle "ničeho"
  lwgeom::st_split(reka_morava) %>% 
  st_collection_extract("POLYGON") %>% # polygony z kolekce
  ggplot() +
    geom_sf()

