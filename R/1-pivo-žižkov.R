# Hospody na Žižkově jako body
library(sf)
library(dplyr)
library(osmdata)
library(leaflet)

# bbox = http://bboxfinder.com - "core" Žižkov
search_res <- opq(bbox = c(14.439726, 50.080642,
                           14.452257, 50.085413)) %>%
  add_osm_feature(key = "amenity", 
                  value = c("bar", "restaurant", "pub")) %>%
  osmdata_sf(quiet = F)  # ukáže průběh

# z výsledku vybere data frame bodů / ještě jsou polygony & lines
hopsody <- search_res$osm_points %>%  
  filter(!is.na(amenity)) # pouze platné

# protože ukázaná platí...
leaflet(hopsody) %>% 
  addProviderTiles("Stamen.Toner") %>% 
  addCircleMarkers(fillColor = "red",
                   radius = 5,
                   stroke = F,
                   fillOpacity = .75,
                   label = ~ name)


# univerzity v Praze jako polygony
library(sf)
library(dplyr)
library(osmdata)
library(leaflet)


search_res <- opq(bbox = "Praha") %>%
  add_osm_feature(key = "amenity", 
                  value = c("university")) %>%
  osmdata_sf(quiet = F) 

# data frame z výsledků
vejsky <- search_res$osm_polygons

# protože ukázaná platí...
leaflet(vejsky) %>% 
  addProviderTiles("Stamen.Toner") %>% 
  addPolygons(fillColor = "red",
              stroke = F,
              fillOpacity = .75,
              label = ~ name)
