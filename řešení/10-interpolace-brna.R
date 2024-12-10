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

library(ggplot2)

ggplot() +
  geom_sf(data = brno_mesto, fill = NA) +
  geom_sf(data = brno_data, aes(color = pm10_1h)) +
  geom_sf(data = svobodak, color = "red", pch = 4)


library(gstat)

model <- gstat(formula = pm10_1h~1, data = brno_data, nmax = Inf, set = list(idp = 2))

aq_gravity <- predict(model, svobodak)$var1.pred

# kriging 

vgram_raw <- variogram(pm10_1h~1, brno_data) # sample variogram

plot(vgram_raw, plot.numbers = T)

vgram_fit <- fit.variogram(vgram_raw, vgm("Exp")) # fitted variogram

plot(vgram_raw, vgram_fit) # oba variogramy přes sebe

# vlastní model
aq_krige <- krige(pm10_1h~1,  # vzoreček - hodnota podle konstanty
                  brno_data,  # odkuď krieguju - vstupy
                  svobodak, # kde předpovídám? - kde chci výstup
                  vgram_fit # modelový variogram
)$var1.pred

brno_gravitace <- predict(model, brno_stars)

ggplot() +
  geom_stars(data = brno_gravitace) +
  geom_sf(data = brno_mesto, fill = NA, color = "red")

brno_krige <- krige(pm10_1h~1,  # vzoreček - hodnota podle konstanty
                    brno_data,  # odkuď krieguju - vstupy
                    brno_stars, # kde předpovídám? - kde chci výstup
                    vgram_fit # modelový variogram
)

ggplot() +
  geom_stars(data = brno_krige) +
  geom_sf(data = brno_mesto, fill = NA, color = "red")