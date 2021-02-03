# STČ volební výsledky - grafické overview

library(RCzechia)
library(tidyverse)

# načíst data o STČ ----
source("./R/4-digest-data-STČ.R")

stc_okrsky <- stc_okrsky %>% 
   st_transform(crs = 5514) %>% # systém inž. Křováka
   mutate(stredobod = st_geometry(.) %>% sf::st_centroid())

# připravit podklady pro hezčí graf ----
podklad <- okresy() %>% # pro tenké okresy
   filter(KOD_CZNUTS3 == 'CZ020') %>% # Středočeský kraj
   st_transform(crs = 5514) # systém inž. Křováka

obrysKraje <- kraje() %>% # pro tlustou čáru kolem kraje na mapě
   filter(KOD_CZNUTS3 == 'CZ020')  %>% # Středočeský kraj
   st_transform(crs = 5514) # systém inž. Křováka

bbox <- obrysKraje %>% # hranice
   nngeo::st_remove_holes() %>% # dobrý den, Praha ven!
   st_buffer(2000)  # pěk Km okolo kraje

reky <- reky() # řeky české republiky

mala_voda <- reky %>%
   filter(NAZEV %in% c('Berounka', 'Sázava', 'Jizera')) %>% # méně významné řeky
   st_transform(crs = 5514) %>% # systém inž. Křováka
   st_geometry() %>% # pouze geometrii (bez dat)
   st_intersection(bbox) # oříznout pouze na středočeský kraj

velka_voda <- reky %>%
   filter(NAZEV %in% c('Vltava', 'Labe')) %>% # více významné řeky
   st_transform(crs = 5514) %>% # systém inž. Křováka
   st_geometry() %>% # pouze geometrii (bez dat)
   st_intersection(bbox) # oříznout pouze na středočeský kraj

rm(reky) # už je nepotřebuju...

# vizuální overview
relativne <- ggplot() +
   geom_sf(data = stc_okrsky, aes(fill = STAN / celkem), color = NA, alpha = 2/3) +
   geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
   geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
   geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   scale_fill_continuous(low = "white",
                         high = scales::muted("red"),
                         limits = c(0, 1),
                         labels = scales::label_percent()) +
   labs(fill = "podíl\nSTAN",
        title = "Středočeské volby 2020") +
   theme_void() +
   theme(legend.text.align = 1,
         legend.title.align = 1/2)

relativne

absolutne <- ggplot() +
   geom_sf(data = stc_okrsky, aes(fill = STAN), color = NA, alpha = 2/3) +
   geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
   geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
   geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   scale_fill_continuous(low = "white",
                         high = scales::muted("red"),
                         limits = c(0, 800),
                         labels = scales::label_comma()) +
   labs(fill = "hlasy\nSTAN",
        title = "Středočeské volby 2020") +
   theme_void() +
   theme(legend.text.align = 1,
         legend.title.align = 1/2)

relativne

stredobody <- ggplot() +
   geom_sf(data = st_set_geometry(stc_okrsky, "stredobod"), pch = 4, color = "red", alpha = 1/2) +
   geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
   geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
   geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   labs(title = "Středočeské volby 2020",
        subtitle = "středové body okrsků") +
   theme_void() 

stredobody
