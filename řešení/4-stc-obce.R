# STČ volby - z okrsků na obce
# & obce do grafu

library(sf)
library(dplyr)
library(RCzechia)
library(ggplot2)

# uvažujte hodnoty výsledků po okrscích
source("./R/4-okrsky-viz.R")

# přeneste hodnoty na obce středočeského kraje
stc_obce <- obce_polygony() %>% 
  filter(KOD_CZNUTS3 == "CZ020") %>% 
  st_transform(5514) # do Křováka, aby se obce potkaly s okrsky

# a podejte zprávu po obcích / analogicky jako grafy absolutně & relativně po okrscích
# (okrasný prvek řek není poviný)

# přenesu výsledky z okrsků na obce podílem na ploše
podklad <- st_interpolate_aw(stc_okrsky["STAN"],
                             stc_obce,
                             extensive = T)

# numerická kontrola
sum(stc_okrsky$STAN, na.rm = T) 
sum(podklad$STAN, na.rm = T)


# kopie kódu pro graf "absolutně"
ggplot() +
  geom_sf(data = podklad, aes(fill = STAN), color = NA, alpha = 2/3) +
  geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
  geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
  geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
  geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
  scale_fill_continuous(low = "white",
                        high = scales::muted("red"),
                 #       limits = c(0, 800), # tady byl problém!!! :)
                        labels = scales::label_comma()) +
  labs(fill = "hlasy\nSTAN",
       title = "Středočeské volby 2020") +
  theme_void() +
  theme(legend.text.align = 1,
        legend.title.align = 1/2)