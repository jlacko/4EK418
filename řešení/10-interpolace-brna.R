# úkol:
# - interpolovat kvalitu vzduchu na náměstí Svobody (u Orloje)
# - odhadnout míru znečištění na Brnu jako celku


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

# metoda gravitace
library(gstat)

model <- gstat(formula = pm10_1h~1, 
               data = brno_data, 
               nmax = Inf, 
               set = list(idp = 2))

model_svobodak <- predict(model, svobodak)$var1.pred
model_brno <- predict(model, brno_stars)

library(ggplot2)

ggplot() +
  geom_stars(data = model_brno) +
  geom_sf(data = brno_mesto, fill = NA, color = "red")

# metoda Krige
vgram_brno_raw <- variogram(pm10_1h~1, brno_data)

vgram_brno_fit <- fit.variogram(vgram_brno_raw, vgm(model = "Exp"))

plot(vgram_brno_raw, model = vgram_brno_fit)

krige_svobodak <- krige(pm10_1h~1,  # vzoreček - hodnota podle konstanty
                        brno_data,  # odkuď krieguju - vstupy
                        svobodak, # kde předpovídám? - kde chci výstup
                        vgram_brno_fit # modelový variogram
                        )$var1.pred

krige_brno <- krige(pm10_1h~1,  # vzoreček - hodnota podle konstanty
                    brno_data,  # odkuď krieguju - vstupy
                    brno_stars, # kde předpovídám? - kde chci výstup
                    vgram_brno_fit # modelový variogram
                    )

ggplot() +
  geom_stars(data = krige_brno) +
  geom_sf(data = brno_mesto, fill = NA, color = "red") +
  theme_void()