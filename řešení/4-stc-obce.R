# STČ volby - z okrsků na obce
# & obce do grafu

library(RCzechia)
library(dplyr)
library(ggplot2)
library(sf)

# uvažujte hodnoty výsledků po okrscích
source("./R/4-okrsky-viz.R")

# přeneste hodnoty na obce středočeského kraje
stc_obce <- obce_polygony() %>% 
   filter(KOD_CZNUTS3 == "CZ020") 

# a podejte zprávu / analogicky jako grafy absolutně & relativně po okrscích

stc_obce_abs <- sf::st_interpolate_aw(stc_okrsky["STAN"],
                                      st_geometry(st_transform(stc_obce, 5514)),
                                      extensive = T)

# přepočet relativních hodnot - věnujte pozornost extensive = F
# (přenáším relativní, ne absolutní hodnoty)
stc_okrsky <- stc_okrsky %>% 
  mutate(relativne = STAN / celkem)

stc_obce_rel <- sf::st_interpolate_aw(stc_okrsky["relativne"],
                                      st_geometry(st_transform(stc_obce, 5514)),
                                      extensive = F) # pozor!
# absolutní hodnoty / viz
ggplot() +
  geom_sf(data = stc_obce_abs, aes(fill = STAN), color = NA, alpha = 2/3) +
  geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
  geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
  geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
  geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
  scale_fill_continuous(low = "white",
                        high = scales::muted("red"),
                 #       limits = c(0, 800),
                        labels = scales::label_comma()) +
  labs(fill = "hlasy\nSTAN",
       title = "Středočeské volby 2020") +
  theme_void() +
  theme(legend.text.align = 1,
        legend.title.align = 1/2)

# relativní hodnoty / viz
ggplot() +
  geom_sf(data = stc_obce_rel, aes(fill = relativne), color = NA, alpha = 2/3) +
  geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
  geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
  geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
  geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
  scale_fill_continuous(low = "white",
                        high = scales::muted("red"),
                        #       limits = c(0, 800),
                        labels = scales::label_comma()) +
  labs(fill = "podíl\nSTAN",
       title = "Středočeské volby 2020") +
  theme_void() +
  theme(legend.text.align = 1,
        legend.title.align = 1/2)