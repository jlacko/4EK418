# tři základní kameny - bod, čára, polygon

library(RCzechia)
library(tidyverse)
library(tidygeocoder)

praha <- kraje() %>% 
   filter(KOD_CZNUTS3 == "CZ010") 

reka <- reky("Praha")

ekonomka <- geo(address = "náměstí Winstona Churchilla 1938/4, 130 00 Praha") %>% 
   st_as_sf(coords = c("long", "lat"), crs = 4326)

ggplot() +
   geom_sf(data = reka, color = "steelblue", size = 1.25) +
   geom_sf(data = praha, color = "grey40", fill = NA, size = 1) + 
   geom_sf(data = ekonomka, color = "red", pch = 4, size = 2) +
   theme_void()

# VŠE v systému inž. Křováka / SJSTK
krovakova_ekonomka <- st_transform(ekonomka, 5514)

ekonomka
krovakova_ekonomka

st_coordinates(ekonomka) 
st_coordinates(krovakova_ekonomka) 
st_length(reka)
st_area(praha)

st_distance(ekonomka, reka)