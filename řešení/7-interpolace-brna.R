# úkol:
# - interpolovat kvalitu vzduchu na náměstí Svobody (u Orloje)
# - odhadnout míru znečisřění na Brnu jako celku


library(sf)
library(dplyr)
library(stars)
library(gstat)
library(ggplot2)

# loni v Brně...
brno_stanice <- st_read("./data/brno-AQ.gpkg")

# náš cíl - tady stojí Orloj
svobodak <- tidygeocoder::geo("náměstí Svobody, Brno") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) 

# celé Brno
brno <- RCzechia::obce_polygony() %>% 
  filter(NAZ_OBEC == "Brno")

# KNN model Brna - tři sousedé
model_brna <- gstat(formula = pm10_1h~1, data = brno_stanice, nmax = 3)
predict(model_brna, svobodak)

# variogram Brna
vgram_raw <- variogram(pm10_1h~1, brno_stanice) # sample variogram

plot(vgram_raw, plot.numbers = T)

vgram_fit <- fit.variogram(vgram_raw, vgm("Exp")) # fitted variogram

plot(vgram_raw, vgram_fit) # oba variogramy přes sebe

# kriging model pm 10 na Svoboďáku
krige(pm10_1h ~ 1, brno_stanice, svobodak, vgram_fit)


# kriging na rastr
library(stars)
brno_stars <- st_bbox(brno) %>% 
  st_as_stars(n = 1000) # počet buněk rasteru / dx byla vzdálenost, nedávala smysl pro stupňový CRS

# vlastní kriging
stanice_stars <- krige(pm10_1h ~ 1, brno_stanice, brno_stars, vgram_fit)

# podat zprávu o výsledku
ggplot() +
  geom_stars(data = stanice_stars) +
  geom_sf(data = brno, fill = NA, color = "red", lwd = 2) +
  labs(fill = "Predikce PM₁₀")
