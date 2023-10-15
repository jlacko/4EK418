# načte kvalitu vzduchu v Praze
# odhadne stav u VŠE

library(dplyr)
library(ggplot2)
library(sf)

# načtení nevstřícného geojsonu do R
stanice <- geojsonsf::geojson_sf("./data/golemio-AQ.geojson",
                      expand_geometries = T) %>% 
  mutate(measurement = purrr::map(measurement, ~ jsonlite::fromJSON(.) %>% as.data.frame())) %>% 
  tidyr::unnest(measurement) %>% 
  filter(components.type == "PM10") %>% 
  mutate(value = components.averaged_time[,"value"]) %>% 
  select(id, name, value, updated_at) %>% 
  st_transform(5514)

# základní orientace - kde jsme, kolik jsme naměřili?
ggplot(data = stanice) +
  geom_sf(data = praha,
          fill = NA,
          color = "gray50",
          linewidth = 3/2) +
  geom_sf(aes(color = value)) +
  geom_sf_text(aes(label = value),
               nudge_x = 1250) +
  geom_sf(data = ekonomka, color = "red", pch = 4) +
  labs(title = "Znečištění vzduchu v Praze",
       fill = "PM 10") +
  theme_minimal()


# náš cíl - kolik zde bylo pm-10?
ekonomka <- tidygeocoder::geo("náměstí Winstona Churchilla 1938/4, Praha") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) %>%  
  st_transform(5514)

# basic use case = voronoi polygony, hranice skokem
praha <- RCzechia::kraje() %>% 
  filter(KOD_CZNUTS3 == "CZ010") %>% 
  st_transform(5514)

voronoi <- stanice %>% 
  st_union() %>% 
  st_voronoi(envelope = st_geometry(praha)) %>% 
  st_collection_extract(type = "POLYGON") %>% # vytahnout objekty typu polygon
  st_intersection(st_geometry(praha)) %>% # oříznout zvnějšku na Prahu
  st_as_sf() %>% 
  st_join(stanice)

ggplot() +
  geom_sf(data = voronoi,
          aes(fill = value),
          color = NA) +
  geom_sf(data = praha,
          fill = NA,
          color = "gray50",
          linewidth = 3/2) +
  geom_sf(data = ekonomka, color = "red", pch = 4) +
  labs(title = "Znečištění vzduchu v Praze",
       fill = "PM 10") +
  theme_minimal()

(aq_voronoi <- st_join(ekonomka, voronoi, left = F)$value)

# KNN - zprůměrovaní tři sousedé

library(gstat)

model <- gstat(formula = value~1, data = stanice, nmax = 3)

(aq_knn <- predict(model, ekonomka)$var1.pred)

# varianta gravitace - všechny stanice, vliv přímo úměrné vzdálenosti na druhou

model <- gstat(formula = value~1, data = stanice, nmax = Inf, set = list(idp = 2))

(aq_gravity <- predict(model, ekonomka)$var1.pred)

# kriging 

(v <- variogram(value~1, stanice)) # sample variogram
plot(v, plot.numbers = T)

vfit <- fit.variogram(v, vgm("Exp")) # fitted variogram

plot(v, vfit) 

# vlastní model
(aq_krige <- krige(value~1, stanice, ekonomka, vfit)$var1.pred)

# hlavní výhoda krigingu - rozptyl
krige(value~1, stanice, ekonomka, vfit)


# kriging v prostoru - na raster pokrývající Prahu s bboxem
library(stars)
praha_stars <- st_bbox(praha) %>% 
  st_as_stars(dx = 1000)

stanice_stars <- krige(value~1, stanice, praha_stars, vfit)

ggplot() +
  geom_stars(data = stanice_stars,
             aes(fill = var1.pred, 
                 x = x, 
                 y = y)) +
  geom_sf(data = praha,
          fill = NA,
          color = "gray50",
          linewidth = 3/2) +
  geom_sf(data = ekonomka, color = "red", pch = 4) +
  labs(title = "Znečištění vzduchu v Praze",
       fill = "PM 10") +
  theme_minimal()