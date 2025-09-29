# úkol = zakreslit na mapě města Brna
# 1) ústavní soud
# 2) nejvyšší soud
# 3) řeky pro orientaci

library(dplyr)
library(sf)
library(ggplot2)

soudy <- data.frame(
   druh = c("ústavní", "nejvyšší"),
   adresa = c("Joštova 625, Brno",
              "Burešova 20, Brno")) %>% 
  tidygeocoder::geocode(address = adresa, # jméno sloupce s adresou
                        method = "osm") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326)

mesto_brno <- RCzechia::obce_polygony() %>% 
  filter(NAZ_OBEC == "Brno")

ggplot() +
  geom_sf(data = soudy, aes(color = druh)) +
  geom_sf(data = mesto_brno) +
  geom_sf(data = RCzechia::reky("Brno"), color = "steelblue") +
  theme_void()


# nápověda:
# - všechny obce jsou v RCzechia::obce_polygony()
# - Svitava & Svratka jsou v RCzechia::reky("Brno")
# - při kreslení polygonu nezapomeňte zakázat výplň / fill = NA
