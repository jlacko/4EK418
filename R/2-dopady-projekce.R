library(sf)
library(dplyr)
library(RCzechia)

# plocha Česka 4x jinak...
# aneb proč na projekci záleží :)

cesko <- republika()

# sférický výpočet
wgs84 <- st_transform(cesko, 4326)
st_area(wgs84)

# inž. Křovák / ČUZK - toto je pravda!
krovak <- st_transform(cesko, 5514) 
st_area(krovak)
 
# equal area globální
mollweide <- st_transform(cesko, "ESRI:53009")
st_area(mollweide)

# google maps & IT svět...
web_mercator <- st_transform(cesko, 3857)
st_area(web_mercator)

# zpráva o krizovém vývoji (jako named vector)
vysledek <- c("wgs84" = st_area(wgs84),
              "krovak" = st_area(krovak),
              "mollweide" = st_area(mollweide),
              "web_mercator" = st_area(web_mercator))

sort(vysledek)

sort(vysledek) / vysledek["krovak"]