# úkol:
# - interpolovat kvalitu vzduchu na náměstí Svobody (u Orloje)
# - odhadnout míru znečištění na Brnu jako celku


library(sf)
library(dplyr)
library(stars)
library(ggplot2)
library(gstat)

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


# základní overview
ggplot() +
  geom_sf(data = brno_mesto) +
  geom_sf(data = RCzechia::reky("Brno"), color = "steelblue") +
  geom_sf(data = brno_data, aes(color = pm10_1h)) +
  geom_sf(data = svobodak, pch = 4, color = "red") +
  scale_color_viridis_c()

# IDW pohled / bodový odhad
model_pm10 <-  gstat(formula = pm10_1h~1, data = brno_data, 
                     nmax = Inf, set = list(idp = 2))

predikce_svobodak <- predict(model_pm10, svobodak)
predikce_brno <- predict(model_pm10, brno_stars)

mapview::mapview(predikce_brno)

# statický pohled
ggplot() +
  geom_sf(data = brno_mesto) +
  geom_sf(data = RCzechia::reky("Brno"), color = "steelblue") +
  geom_stars(data = predikce_brno, alpha = 1/2,
             aes(fill = var1.pred, x = x, y = y)) +
  geom_sf(data = svobodak, pch = 4, color = "red") +
  scale_fill_viridis_c("PM10 pred") +
  labs(title = "technika IDW")

# kriging pohled / včetně rozptylu

vgram_raw <- variogram(pm10_1h~1, brno_data) # sample variogram

plot(vgram_raw, plot.numbers = T)

vgram_fit <- fit.variogram(vgram_raw, vgm("Exp")) # fitted variogram

plot(vgram_raw, vgram_fit) # oba variogramy přes sebe

# vlastní model svoboďák
krige_svobodak <- krige(pm10_1h~1,  # vzoreček - hodnota podle konstanty
                        brno_data,  # odkuď krieguju - vstupy
                        svobodak, # kde předpovídám? - kde chci výstup
                        vgram_fit # modelový variogram
                        )

# vlastní model Brno jako celek
krige_brno <- krige(pm10_1h~1,  # vzoreček - hodnota podle konstanty
                    brno_data,  # odkuď krieguju - vstupy
                    brno_stars, # kde předpovídám? - kde chci výstup
                    vgram_fit # modelový variogram
                    )

# dynamický pohled
mapview::mapview(krige_brno)

# statický pohled
ggplot() +
  geom_sf(data = brno_mesto) +
  geom_sf(data = RCzechia::reky("Brno"), color = "steelblue") +
  geom_stars(data = krige_brno, alpha = 1/2,
             aes(fill = var1.pred, x = x, y = y)) +
  geom_sf(data = svobodak, pch = 4, color = "red") +
  scale_fill_viridis_c("PM10 pred") +
  labs(title = "technika Krige")