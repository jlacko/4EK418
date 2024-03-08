library(sf)
library(dplyr)
library(RCzechia)

# plocha Česka 4x jinak...
# aneb proč na projekci záleží :)

cesko <- republika()

# sférický výpočet / globus; nedává smysl na ploše (mapě, monitoru...)
wgs84 <- st_transform(cesko, 4326)
st_area(wgs84) %>% 
  units::set_units("km2")

# inž. Křovák / ČUZK - toto je pravda!
krovak <- st_transform(cesko, 5514) 
st_area(krovak) %>% 
  units::set_units("km2")
 
# equal area globální
mollweide <- st_transform(cesko, "ESRI:53009")
st_area(mollweide) %>% 
  units::set_units("km2")

# google maps & IT svět...
web_mercator <- st_transform(cesko, 3857)
st_area(web_mercator) %>% 
  units::set_units("km2")

# zpráva o krizovém vývoji (jako named vector)
vysledek <- c("wgs84" = st_area(wgs84),
              "krovak" = st_area(krovak),
              "mollweide" = st_area(mollweide),
              "web_mercator" = st_area(web_mercator))

sort(vysledek) %>% 
  units::set_units("km2")

sort(vysledek) / vysledek["krovak"]