# úkol:
# - interpolovat kvalitu vzduchu na náměstí Svobody (u Orloje)
# - odhadnout míru znečisřění na Brnu jako celku


library(sf)
library(dplyr)
library(stars)

# loni v Brně...
brno <- st_read("./data/brno-AQ.gpkg")

# náš cíl - tady stojí Orloj
svobodak <- tidygeocoder::geo("náměstí Svobody, Brno") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) 

# cele brno
brno_stars <- RCzechia::obce_polygony() %>% 
  filter(NAZ_OBEC == "Brno") %>% 
  st_bbox() %>% 
  st_as_stars(dx = 500)