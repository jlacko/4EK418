# uvažujte pražské hospody - definováno jako amenities typu "bar", "restaurant", "pub"
# zjistěte, zda je více takových co se jmenují U (jako U Sedmi Švábů) či Na (jako Na Mělníku)
# při hledání začátku stringu si pomoci funkcí stringr::str_starts()

library(sf)
library(dplyr)
library(osmdata)


search_res <- opq(bbox = "Praha") %>%
  add_osm_feature(key = "amenity", 
                  value = c("bar", "restaurant", "pub")) %>%
  osmdata_sf(quiet = F) 


hospody <- search_res$osm_points

library(leaflet)

# protože ukázaná platí...
leaflet(hospody) %>% 
  addProviderTiles("Stadia.AlidadeSmooth") %>% 
  addCircleMarkers(fillColor = "red",
                   radius = 5,
                   stroke = F,
                   fillOpacity = .75,
                   label = ~ name)

stringr::str_detect(hospody$name, "U ") %>% 
  sum( na.rm = T)

stringr::str_detect(hospody$name, "Na ") %>% 
  sum( na.rm = T)