# úkol:
# - interpolovat kvalitu vzduchu na náměstí Svobody (u Orloje)
# - odhadnout míru znečisřění na Brnu jako celku


# poznámka pro kolegy z 1. běhu: variogramu nechutnal zeměpisný souřadnicový systém (stupně na kouli)
# v okamžiku kdy jsem to překlopil do rovinného (metry na ploše) tak šlape jak hodinky. Mea culpa.

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

library(gstat)

# model pro KNN
model_knn <- gstat(formula = pm10_1h ~ 1,
                   data = brno_data,
                   nmin = 3)

# náměstí Svobody KNN - pouze bodově
predict(model_knn, svobodak)



# kriging
vgram_brno_raw <- variogram(pm10_1h ~ 1, brno_data)

vgram_brno_fit <- fit.variogram(vgram_brno_raw, vgm(model = "Exp", sill = 80))

plot(vgram_brno_raw, model = vgram_brno_fit)


# náměstí Svobody krige - včetně rozptylu pro intervalový odhad
krige(pm10_1h ~ 1, brno_data, svobodak, vgram_brno_fit)


# mapa za brno jako celek...

brno_knn <- predict(model_knn, brno_stars)

mapview::mapview(brno_knn)

brno_krige <- krige(pm10_1h ~ 1, brno_data, brno_stars, vgram_brno_fit)

mapview::mapview(brno_krige)

