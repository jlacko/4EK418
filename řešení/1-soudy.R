# úkol = zakreslit na mapě města Brna
# 1) ústavní soud
# 2) nejvyšší soud
# 3) řeky pro orientaci

library(dplyr)
library(ggplot2)
library(RCzechia)
library(tidygeocoder)

soudy <- data.frame(
   druh = c("ústavní", "nejvyšší"),
   adresa = c("Joštova 625, Brno",
              "Burešova 20, Brno"))


# nápověda:
# - všechny obce jsou v RCzechia::obce_polygony()
# - Svitava & Svratka jsou v RCzechia::reky("Brno")
# - při kreslení polygonu nezapomeňte zakázat výplň / fill = NA

# data frame soudů, s dohledanými souřadnicemi
soudy_geo <- soudy %>% 
  tidygeocoder::geocode(address = adresa, # jméno sloupce s adresou
                        method = "osm") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) 

# hranic města Brna
brno <- RCzechia::obce_polygony() %>% 
  filter(NAZ_OBEC %in% c("Brno"))

# Svitava & Svratka = řeky města Brna 
SaS <- reky("Brno")

ggplot() +
  geom_sf(data = brno, fill = NA, color = "gray45") +
  geom_sf(data = SaS, color = "steelblue", size = 1) +
  geom_sf(data = soudy_geo, aes(color = druh), size = 3) +
  # vlastní barevná škála pro ozvláštěnění :)
  scale_color_manual(values = c("ústavní" = "cornflowerblue",
                                "nejvyšší" = "firebrick")) +
  theme_void() + 
  labs(title = "Soudy v Brně",
       color = "druh soudu")