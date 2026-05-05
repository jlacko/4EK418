# úkol:
# - interpolovat kvalitu vzduchu na náměstí Svobody (u Orloje)
# - odhadnout míru znečištění na Brnu jako celku


library(sf)
library(dplyr)
library(stars)

# jak bylo v Brně?
brno_data <- st_read("./data/brno-AQ.gpkg") %>% 
  st_transform(5514)

# náhled vizuálně...
mapview::mapview(brno_data, zcol = "pm10_1h")

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

# varianta gravitace = IDW
model <- gstat(formula = pm10_1h~1, 
               data = brno_data, 
               nmax = Inf, 
               set = list(idp = 2))

# uplatnění modelu gravitace na Svoboďák
svobodak_gravi <- predict(model, svobodak)$var1.pred

# uplatnění modelu gravitace na Brno jako celek
brno_gravi <- predict(model, brno_stars)

# ukázaná platí
mapview::mapview(brno_gravi)

# varianta krige
vgram_raw <- variogram(pm10_1h ~ 1, brno_data)
vgram_fit <- fit.variogram(vgram_raw, vgm(model = "Exp"))

plot(vgram_raw, vgram_fit)

# uplatnění metody krige na Svoboďák
svobodak_krige <- krige(pm10_1h ~ 1,
                        brno_data,
                        svobodak,
                        vgram_fit)$var1.pred

# dtto. na Brno jako celek...
brno_krige <- krige(pm10_1h ~ 1,
                    brno_data,
                    brno_stars,
                    vgram_fit)

# rozdíl proti IDW těžko poznatelný (je jinde než v bodovém odhadu!)
mapview::mapview(brno_krige)