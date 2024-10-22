# tři školy v jedné Praze

library(RCzechia)
library(tidyverse)
library(tidygeocoder)

praha <- kraje() %>% 
   filter(KOD_CZNUTS3 == "CZ010") %>% 
   st_transform(5514)

vltava <- reky("Praha") %>% 
   st_transform(5514)

skoly <- data.frame(
   skola = c("VŠE", "Matfyz", "Přfuk"),
   adresa = c(
      "náměstí Winstona Churchilla 1938/4, Praha",
      "Malostranské náměstí 2, Malá Strana",
      "Albertov 6, Praha 2"
   )) %>%
   tidygeocoder::geocode(address = adresa,
                         method = "osm") %>%
   sf::st_as_sf(coords = c("long", "lat"), crs = 4326) %>% 
   st_transform(5514)

# uložíme pro budoucí použití
obrazek <- ggplot() +
   geom_sf(data = praha, 
           fill = NA, 
           color = "gray30",
           linewidth = 1) +
   geom_sf(data = skoly, 
           aes(shape = skola), 
           color = "goldenrod2", size = 4) +
   geom_sf(data = vltava, 
           color = "steelblue",
           linewidth = 2) +
   theme_void() +
   theme(legend.position = "bottom") +
   labs(shape = "Univerzita:")

# ukážeme obrázek, když jsme si ho uložili...
obrazek 

#1) buffer okolo škol ("kolečka" o průměru x metrů)

buffer <- skoly %>% 
   st_buffer(dist = 1000) # Křovák je v metrech = 1 kilometřík

obrazek +
   geom_sf(data = buffer, 
           fill = NA, 
           color = "red")


# 2) convex hull okolo škol

hull <- skoly %>% 
   st_union() %>% 
   st_convex_hull() 
 
# spojíme s obrázkem
obrazek +
   geom_sf(data = hull, 
           fill = NA, 
           color = "red") 

# alternativa
alt_hull <- buffer %>% 
   st_union() %>% 
   st_convex_hull() %>% 
   st_as_sf()

obrazek +
   geom_sf(data = alt_hull, 
           fill = NA, 
           color = "red") 


# 3) centroidy (od polygonů k bodům)

stred_prahy <- st_centroid(praha)
stred_hullu <- st_centroid(hull)

obrazek +
   geom_sf(data = stred_prahy, 
           color = "red", 
           pch = 3, 
           size = 3) +
   geom_sf(data = stred_hullu, 
           color = "blue", 
           pch = 3, 
           size = 3)


# 4) voroného polygony kolem bodů (od bodů ke ploše)
voronoi <- skoly %>% 
   st_union() %>% 
   st_voronoi(envelope = st_geometry(praha)) %>% 
   st_collection_extract(type = "POLYGON") %>% # vytahnout objekty typu polygon
   st_intersection(st_geometry(praha)) %>% # oříznout zvnějšku na Prahu
   st_as_sf()

obrazek +
   geom_sf(data = voronoi, 
           fill = NA, 
           color = "red") 

# 5) grid - mřížka očekávané velikosti přes Prahu

grid <- st_make_grid(st_bbox(praha),
                     cellsize = c(1000, 1000)) %>% # tj. 1 × 1 kilometr
   st_as_sf()

obrazek +
   geom_sf(data = grid, 
           fill = NA, 
           color = "gray60")

# alternativa

alt_grid <- st_make_grid(st_bbox(praha), 
                         cellsize = rep(1000, 2),
                         square = F) %>% # ne čtverec = hexagon
   st_as_sf()

obrazek +
   geom_sf(data = alt_grid, 
           fill = NA, 
           color = "gray50")


# síla gridu: sousedství / nástroj pro modelování "přetékání" veličiny mezi sousedy

bunka <- alt_grid[248, ] # vcelku náhodně vybraná buňka

sousedi <- bunka %>% # sousedi buňky buňky
  st_touches(alt_grid) %>% 
  unlist()   

obrazek +
   geom_sf(data = alt_grid, 
           fill = NA, 
           color = "gray60") +
   geom_sf(data = bunka, 
           fill = "red", 
           color = "gray60") +
   geom_sf(data = alt_grid[sousedi, ], 
           fill = "cornflowerblue", 
           color = "gray60", 
           alpha = 4/5)
