# úkol = zakreslit na mapě Středočeského kraje
# 1) muzeum Škodovek v Mladé Boleslavi
# 2) Hornické muzeum Příbram 

muzea <- data.frame(
   mesto = c("Boleslav", "Příbram"),
   adresa = c("Václava Klementa 294, Mladá Boleslav",
              "Husova 29, Příbram"))

# nápověda:
# - všechny kraje jsou v RCzechia::kraje()
# - geocode z tidygeocoder potřebuje konverzi st_as_sf
# - při kreslení polygonu nezapomeňte zakázat výplň / fill = NA

library(dplyr)
library(sf)
library(tidygeocoder)
library(ggplot2)

stredocesky_kraj <- RCzechia::kraje() %>% 
  filter(KOD_CZNUTS3 == "CZ020")

muzea_sf <- muzea %>% 
  geocode(address = "adresa") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) 

ggplot() +
  geom_sf(data = stredocesky_kraj, fill = "cornflowerblue") +
  geom_sf(data = muzea_sf, color = "red", pch = 4)

