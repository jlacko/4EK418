# úkol:
# - interpolovat kvalitu vzduchu na náměstí Svobody (u Orloje)
# - odhadnout míru znečištění na Brnu jako celku


library(sf)
library(dplyr)
library(stars)

# loni v Brně...
brno_data <- st_read("./data/brno-AQ.gpkg") %>% 
  st_transform(5514)

# náš cíl - tady stojí Orloj
svobodak <- tidygeocoder::geo("náměstí Svobody, Brno") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) %>% 
  st_transform(5514)

# cele Brno
brno_mesto <- RCzechia::obce_polygony() %>% 
  filter(NAZ_OBEC == "Brno") %>% 
  st_transform(5514)

# pixely po Brně
brno_stars <- brno_mesto %>% 
  st_bbox() %>% 
  st_as_stars(dx = 500)


