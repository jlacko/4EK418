# úkol = zakreslit na mapě Středočeského kraje
# 1) muzeum Škodovek v Mladé Boleslavi
# 2) Hornické muzeum Příbram 

library(dplyr)
library(sf)
library(ggplot2)

muzea <- data.frame(
   mesto = c("Boleslav", "Příbram"),
   adresa = c("Václava Klementa 294, Mladá Boleslav",
              "Husova 29, Příbram")) %>% 
  tidygeocoder::geocode(address = adresa, # jméno sloupce s adresou
                        method = "osm") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326)


stc <- RCzechia::kraje() %>% 
  filter(KOD_CZNUTS3 == "CZ020")

ggplot() +
  geom_sf(data = stc) +
  geom_sf(data = muzea, aes(color = mesto)) +
  theme_void() # bez rozptylování okolo...

# nápověda:
# - všechny kraje jsou v RCzechia::kraje()
# - geocode z tidygeocoder potřebuje konverzi st_as_sf
# - při kreslení polygonu nezapomeňte zakázat výplň / fill = NA
 