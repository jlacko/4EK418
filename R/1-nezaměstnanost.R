# problém k řešení:
# zakreslit v mapě nezaměstnanost po obcích ČR 

library(sf)
library(czso)
library(RCzechia)
library(tidyverse)

# Obce. Toto jsou obce. Je jich 6258 
obce <- RCzechia::obce_polygony()

# přehled tabulek dostupných z CZSO
prehled <- czso::czso_get_catalogue()

# ty z přehledu, které se týkají nezaměstnanosti
prehled %>% 
   filter(str_detect(title, "nezam")) %>% 
   select(dataset_id, title)

# tabulka po obcích za rok 2024
nezam_24 <- readr::read_csv("./data/OD_NEZ01_2024090911065306.CSV")

# orientace podle období
nezam_24 %>% 
   group_by(rok, mesic, obdobi) %>% 
   tally()

# orientace podle typu metriky
nezam_24 %>% 
   group_by(vuk, vuk_text) %>% 
   tally()

# metrika pro mapování - uchazeči za srpen
metrika <- nezam_24 %>% 
  filter(obdobi == "20240831" & vuk == "NEZ0004") %>% 
  mutate(uzemi_kod = as.character(uzemi_kod))

# podklad pro mapu - propojení prostorové a datové složky
chrt_src <- obce %>% 
   left_join(metrika, by = c("KOD_OBEC" = "uzemi_kod"))

# base plot - hodně jednoduchý, málo elegantní
plot(chrt_src["hodnota"])

# ggplot - elegantnější, více proměnných k ladění
ggplot(chrt_src) +
   geom_sf(aes(fill = hodnota), color = NA) +
   geom_sf(data = RCzechia::republika(), fill = NA) +
   scale_fill_gradient() +
   labs(title = "Podíl nezaměstnaných osob (%)",
        subtitle = "stav k srpnu 2024")

# mapview - jednoduchý interaktivní
library(mapview)

mapview::mapview(chrt_src, zcol = "hodnota")

# leaflet - sofistikovaný interaktivní
library(leaflet)

# definice palety / mapování hodnot na barvy
pal <- leaflet::colorBin(palette = "RdYlBu",
                         domain = log10(chrt_src$hodnota),
                         bins = 7)

leaflet::leaflet(data = chrt_src) %>% 
  leaflet::addProviderTiles("CartoDB.Positron") %>% 
  leaflet::addPolygons(fillColor = ~pal(log10(chrt_src$hodnota)),
                       stroke = NA,
                       fillOpacity = 2/3,
                       label = ~hodnota) 

# poznámka: když chci leaflet uložit, tak htmlwidgets::saveWidget(leaflet, "soubor", selfcontained = T)

