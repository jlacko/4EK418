# tři školy v jedné Praze - u které dáme sraz na pivo?

library(RCzechia)
library(tidyverse)
library(tidygeocoder)
library(osmdata)
library(hereR)

# set up the secret key / mine is hidden in .Rprofile
hereR::set_key(Sys.getenv("HERE_API_KEY")) # sem dáte vlastní :)

# dohledání souřadnic tří pražských škol
skoly <- data.frame(
   skola = c("VŠE", "Matfyz", "Přfuk"),
   adresa = c(
      "náměstí Winstona Churchilla 1938/4, Praha 3",
      "Malostranské náměstí 2, Malá Strana",
      "Albertov 6, Praha 2"
   )) %>%
   tidygeocoder::geocode(address = adresa,
                         method = "here") %>%
   sf::st_as_sf(coords = c("long", "lat"), crs = 4326) 


# bbox = město Praha
search_res <- opq(bbox = "Praha") %>%
   add_osm_feature(key = "amenity", 
                   value = c("bar", "restaurant", "pub")) %>%
   osmdata_sf(quiet = F)  # ukáže průběh

# z výsledku vybere data frame bodů / ještě jsou polygony & lines
hopsody <- search_res$osm_points %>%  
   filter(!is.na(amenity)) # pouze platné

# vizuální kontrola
mapview::mapview(hopsody, label = "name")

# dochozí vzdálenost deset minut od školy - tři polygony
her_isolines <- hereR::isoline(poi = skoly,
                               transport_mode = "pedestrian",
                               range = 60 * 10, # jednotky = vteřiny!
                               range_type = "time")

# co jsme dostali? 
her_isolines

# vizuální kontrola
mapview::mapview(her_isolines)


# z jednoho polygonu za všechy >> 3 jednotlivé podle školy
iso_skoly <- her_isolines %>%
  st_geometry() %>%
  st_as_sf() %>% 
  st_join(skoly)
   
# vizuální kontrola
mapview::mapview(iso_skoly, zcol = "skola")

# propojení s hospodami / sečtení výsledků
iso_skoly %>% 
   st_join(hopsody) %>% 
   st_drop_geometry() %>%  # už jí nepotřebuju...
   group_by(skola) %>% 
   tally() %>%  # sečíst řádky
   arrange(desc(n)) 

