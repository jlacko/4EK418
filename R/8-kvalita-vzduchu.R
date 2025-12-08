# načte kvalitu vzduchu v Praze
# odhadne stav u VŠE

library(dplyr)
library(ggplot2)
library(sf)

# pomocné objekty...
praha <- RCzechia::kraje() %>% 
  filter(KOD_CZNUTS3 == "CZ010") %>% 
  st_transform(5514)

vltava <- RCzechia::reky("Praha") %>% 
  st_transform(5514)

# náš cíl - kolik zde bylo pm-10?
ekonomka <- tidygeocoder::geo("náměstí Winstona Churchilla 1938/4, Praha") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) %>%  
  st_transform(5514)

obrazek <- ggplot() +
  geom_sf(data = praha,
          fill = NA,
          color = "gray50",
          linewidth = 3/2) +
  geom_sf(data = vltava, color = "steelblue", linewidth = 2) +
  geom_sf(data = ekonomka, color = "red", pch = 4) +
  theme_minimal() +
  theme(axis.title = element_blank())

obrazek 

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
obrazek + 
  geom_sf_text(data = stanice,
               aes(label = value),
               nudge_x = 1000) +
  geom_sf(data = stanice, 
          aes(color = value),
          pch = 15,
          alpha = 1/2) +
  scale_color_viridis_c() +
  labs(title = "Znečištění vzduchu v Praze",
       color = "PM 10") 


# basic use case = voronoi polygony, hranice skokem

voronoi <- stanice %>% 
  st_union() %>% 
  st_voronoi(envelope = st_geometry(praha)) %>% 
  st_collection_extract(type = "POLYGON") %>% # vytahnout objekty typu polygon
  st_intersection(st_geometry(praha)) %>% # oříznout zvnějšku na Prahu
  st_as_sf() %>% 
  st_join(stanice)

obrazek +
  geom_sf(data = voronoi,
          aes(fill = value),
          color = NA,
          alpha = 1/2) +
  scale_fill_viridis_c() +
  labs(title = "Znečištění vzduchu v Praze",
       fill = "PM 10")

aq_voronoi <- st_join(ekonomka, voronoi, left = F)$value

# KNN - zprůměrovaní tři sousedé

library(gstat)

model <- gstat(formula = value~1, data = stanice, nmax = 3)

aq_knn <- predict(model, ekonomka)$var1.pred

# varianta gravitace - všechny stanice, vliv přímo úměrné vzdálenosti na druhou

model <- gstat(formula = value~1, data = stanice, 
               nmax = Inf, set = list(idp = 2))

aq_gravity <- predict(model, ekonomka)$var1.pred

# kriging 

vgram_raw <- variogram(value~1, stanice) # sample variogram

plot(vgram_raw, plot.numbers = T)

vgram_fit <- fit.variogram(vgram_raw, vgm("Exp")) # fitted variogram

plot(vgram_raw, vgram_fit) # oba variogramy přes sebe

# vlastní model
aq_krige <- krige(value~1,  # vzoreček - hodnota podle konstanty
                  stanice,  # odkuď krieguju - vstupy
                  ekonomka, # kde předpovídám? - kde chci výstup
                  vgram_fit # modelový variogram
                  )$var1.pred

# hlavní výhoda krigingu - rozptyl
krige(value~1, stanice, ekonomka, vgram_fit)

# srovnemjme - věnujme pozornost sloupci var1.var :)
predict(model, ekonomka)

# kriging v prostoru - na raster pokrývající Prahu s bboxem
library(stars)
praha_stars <- st_bbox(praha) %>% 
  st_as_stars(dx = 500)

stanice_stars <- krige(value~1, 
                       stanice, 
                       praha_stars, 
                       vgram_fit)

obrazek +
  geom_stars(data = stanice_stars,
             aes(fill = var1.pred, 
                 x = x, 
                 y = y),
             alpha = 1/2) +
  scale_fill_viridis_c() +
  labs(title = "Znečištění vzduchu v Praze - Krige",
       fill = "PM 10") 

# srovnemjme s tím samým podle modelu = IDW interpolace
stanice_stars <- predict(model, praha_stars)

obrazek +
  geom_stars(data = stanice_stars,
             aes(fill = var1.pred, 
                 x = x, 
                 y = y),
             alpha = 1/2) +
  scale_fill_viridis_c() +
  labs(title = "Znečištění vzduchu v Praze - IDW interpolace",
       fill = "PM 10") 


# pro ilustraci: variogram který se chová hezky :)
rnet_lnd <- readRDS(url("https://github.com/saferactive/saferactive/releases/download/0.1.1/rnet_lnd_1pcnt.Rds"))

# hezčí variogram už asi nebude...
vgram_kola_raw <- variogram(bicycle~1, rnet_lnd, cutoff = 7500)

vgram_kola_fit <- fit.variogram(vgram_kola_raw, vgm(model = "Exp", nuggett = 1000, range = 5000))

plot(vgram_kola_raw, model = vgram_kola_fit)

# obálka - touto ořízneme cílový raster
obalka <- st_convex_hull(st_union(rnet_lnd))

# grid - sem budeme modelovat
grid <- st_bbox(rnet_lnd) %>%
  st_as_stars(dx = 250, dy = 250) %>% 
  st_crop(obalka)

# vlastní kriging
rnet_krige <- krige(bicycle~1, rnet_lnd, grid, vgram_kola_fit, nmax = 30)

# o výsledku podat zprávu
mapview::mapview(rnet_krige)
  

