# optimalizace sítě pražských hospod
# krok 1 - stažení hospod, vytvoření mřížky

library(terra) 
library(exactextractr) # pro sečtení rastru přes vektorové polygony
library(RCzechia)
library(osmdata)
library(ggplot2)
library(dplyr) # přetluče raster::select a stats::filter
library(czso)
library(sf)

# hranice Prahy
obrys <- RCzechia::kraje("high") %>% # all the Czech NUTS3 entities ...
   filter(KOD_CZNUTS3 == 'CZ010') %>% #  ... just Prague
   st_geometry() 

# pražské hospody (opakování :)
search_res <- opq(bbox = "Praha") %>%
   add_osm_feature(key = "amenity", 
                   value = c("bar", "restaurant", "pub")) %>%
   osmdata_sf(quiet = F)  # ukáže průběh

# z výsledku vybere data frame bodů / ještě jsou polygony & lines
hopsody <- search_res$osm_points %>%  
   filter(!is.na(amenity)) %>%  # pouze platné
   select(name) %>% 
   subset(st_intersects(., obrys, sparse = F)) # jen ty uvnitř hranic / ne jen bboxu


# vizuální overview
ggplot() +
   geom_sf(data = obrys, fill = NA, color = "gray40") +
   geom_sf(data = reky("Praha"), color = "steelblue") +
   geom_sf(data = hopsody, color = "red", pch = 4, alpha = 1/3) +
   theme_void() +
   labs(title = "Pražské hospody")


# objekt mřížka
plocha <- 2.5e6 # plocha mřížky (v metrech čtverečných)
grid_spacing <- sqrt(2*plocha/sqrt(3)) # tj. plocha šestiúhelníku = cíl

grid <- obrys %>% 
   st_transform(5514) %>% 
   st_make_grid(square = F, cellsize = c(grid_spacing, grid_spacing)) %>% # make the grid
   st_transform(4326) %>% # convert to WGS84
   st_intersection(obrys) %>% # crop the inside part, as a sfc object
   st_sf() %>% # make the sfc a sf object, capable of holding data
   mutate(id = row_number()) # create id of the grid cell


pruseciky <- st_join(hopsody, grid) %>%
   st_drop_geometry() %>%
   group_by(id) %>%
   tally() %>%
   dplyr::select(id, barcount = n)

grid <- left_join(grid, pruseciky, by = 'id') %>%
   mutate(barcount = ifelse(is.na(barcount), 0, barcount)) # replace NAs with zero

# vizuální overview
ggplot() +
   geom_sf(data = grid, aes(fill = barcount), color = "gray40") +
   geom_sf(data = reky("Praha"), color = "steelblue") +
   theme_void() +
   labs(title = "Počty hospod")
