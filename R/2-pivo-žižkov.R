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

# alternativa bez Overpass API: lokální extrakt OSM dat Prahy (Geofabrik k 2026-10-24)
cesta <- "https://jla-unsecure.s3.eu-central-1.amazonaws.com/osm-data/praha.osm.pbf"
stazene_osm <- "./data/praha.osm.pbf" # z důvodu velikosti není v gitu

# stažení právě jednou = pokud soubor existuje, download se přeskočí
if(!file.exists(stazene_osm)) curl::curl_download(url = cesta, destfile = stazene_osm)

# amenity není mezi výchozími sloupci vrstvy points => extra_tags
hopsody <- osmextract::oe_read(stazene_osm,
                               layer = "points",
                               extra_tags = "amenity",
                               query = "SELECT * FROM points WHERE amenity IN ('bar', 'restaurant', 'pub')") %>%
  st_filter(st_as_sfc(st_bbox(c(xmin = 14.439726, ymin = 50.080642,
                                xmax = 14.452257, ymax = 50.085413), crs = 4326)))

# protože ukázaná platí...
leaflet(hopsody) %>% 
  addProviderTiles("Stadia.AlidadeSmooth") %>% 
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

# alternativa bez Overpass API / amenity je ve vrstvě multipolygons výchozí sloupec
vejsky <- osmextract::oe_read(stazene_osm,
                              layer = "multipolygons",
                              query = "SELECT * FROM multipolygons WHERE amenity = 'university'")

# protože ukázaná platí...
leaflet(vejsky) %>% 
  addProviderTiles("Stadia.AlidadeSmooth") %>% 
  addPolygons(fillColor = "red",
              stroke = F,
              fillOpacity = .75,
              label = ~ name)
