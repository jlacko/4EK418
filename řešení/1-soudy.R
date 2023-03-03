# úkol = zakreslit na mapě města Brna
# 1) ústavní soud
# 2) nejvyšší soud
# 3) řeky pro orientaci

soudy <- data.frame(
   druh = c("ústavní", "nejvyšší"),
   adresa = c("Joštova 625, Brno",
              "Burešova 20, Brno"))


# nápověda:
# - všechny obce jsou v RCzechia::obce_polygony()
# - Svitava & Svratka jsou v RCzechia::reky("Brno")
# - při kreslení polygonu nezapomeňte zakázat výplň / fill = NA


library(RCzechia)
library(sf)
library(tidyverse)

mesto_brno <- RCzechia::obce_polygony() %>% 
  filter(NAZ_OBEC == "Brno")

svitava_svratka <- RCzechia::reky("Brno")

soudy_geo <- soudy %>% 
  tidygeocoder::geocode(address = adresa) %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326)


ggplot() +
  geom_sf(data = mesto_brno) +
  geom_sf(data = svitava_svratka, color = "steelblue") +
  geom_sf(data = soudy_geo, color = "red", pch = 4) +
  geom_sf_text(data = soudy_geo, aes(label = druh), nudge_x = .05)
