# prezidentské volební výsledky - grafické overview

library(RCzechia)
library(tidyverse)

# načíst data o STČ ----
source("./R/4-digest-data-prez.R")

clean_data <- clean_data %>% 
   st_transform(crs = 5514) %>% # systém inž. Křováka
   mutate(stredobod = st_geometry(.) %>% sf::st_centroid())

# připravit podklady pro hezčí graf ----
podklad <- okresy() %>% # pro tenké okresy
   st_transform(crs = 5514) # systém inž. Křováka

obrysKraje <- kraje() %>% # pro tlustou čáru kolem kraje na mapě
   st_transform(crs = 5514) # systém inž. Křováka


# vizuální overview
pavel_relativne <- ggplot() +
   geom_sf(data = clean_data, aes(fill = pavel / celkem), color = NA, alpha = 2/3) +
   geom_sf(data = podklad, fill = NA, color = "gray60", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   scale_fill_gradient2(low = scales::muted("red"),
                        high = scales::muted("green"),
                        mid = "white",
                        midpoint = 1/2,
                        limits = c(0, 1),
                        labels = scales::label_percent()) +
   labs(fill = "podíl\nPetra Pavla",
        title = "Prezidentské volby 2022") +
   theme_void() +
   theme(legend.text.align = 1,
         legend.title.align = 1/2)

pavel_relativne

babis_relativne <- ggplot() +
  geom_sf(data = clean_data, aes(fill = babis / celkem), color = NA, alpha = 2/3) +
  geom_sf(data = podklad, fill = NA, color = "gray60", size = .25) +
  geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
  scale_fill_gradient2(low = scales::muted("red"),
                       high = scales::muted("green"),
                       mid = "white",
                       midpoint = 1/2,
                       limits = c(0, 1),
                       labels = scales::label_percent()) +
  labs(fill = "podíl\nAndreje Babiše",
       title = "Prezidentské volby 2022") +
  theme_void() +
  theme(legend.text.align = 1,
        legend.title.align = 1/2)

babis_relativne


pavel_absolutne <- ggplot() +
   geom_sf(data = clean_data, aes(fill = pavel), color = NA, alpha = 2/3) +
   geom_sf(data = podklad, fill = NA, color = "gray60", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   scale_fill_continuous(low = "white",
                         high = scales::muted("blue"),
                         limits = c(0, 800),
                         labels = scales::label_comma()) +
   labs(fill = "hlasy pro\nPetra Pavla",
        title = "Prezidentské volby 2022") +
   theme_void() +
   theme(legend.text.align = 1,
         legend.title.align = 1/2)

pavel_absolutne

stredobody <- ggplot() +
   geom_sf(data = st_set_geometry(clean_data, "stredobod"), pch = 4, color = "red", alpha = 1/2) +
   geom_sf(data = podklad, fill = NA, color = "gray60", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   labs(title = "Prezidentské volby 2022",
        subtitle = "středové body okrsků") +
   theme_void() 

stredobody
