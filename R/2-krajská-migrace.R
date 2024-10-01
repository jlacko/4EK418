library(sf)
library(czso)
library(RCzechia)
library(tidyverse)

# datasety vztahující se k migraci
czso::czso_get_catalogue() %>% 
   filter(str_detect(keywords_all, "migrace")) %>% 
   arrange(desc(end)) 

# stahnout data
migrace <- czso::czso_get_table("130141r19")

# přehled metrik a jejich kódů
migrace %>% 
  group_by(vuk, vuk_text) %>% 
  summarise(pocet = n())

# přehled územního členění
migrace %>% 
  group_by(vuzemi_cis) %>% 
  summarise(pocet = n()/8) # dělím osmi, protože 8 metrik (VUK_TEXT)

# získat kraje a propojit s metrikou "Celkový přírůstek"
podklad <- RCzechia::kraje("low") %>% 
   inner_join(migrace %>% filter(vuk == "DEM0001" & vuzemi_cis == 100), # vybraná metrika
              by = c("KOD_KRAJ" = "vuzemi_kod")) %>%  # kód kraje = kód území
   arrange(KOD_CZNUTS3)

# podat zprávu hezkým obrázkem
ggplot() +
   geom_sf(data = podklad, aes(fill = hodnota), color = "gray40") +
   geom_sf(data = republika("low"), fill = NA, size = 1) +
   geom_sf_text(data = podklad, 
                aes(label = formatC(hodnota, big.mark = " ", format = "f", digits = 0)),
                # Středočeský a Olomoucký kraj často potřebují posunout
                nudge_x = c(0, .15, rep(0, 9), 0, 0, 0),
                nudge_y = c(0, -.2, rep(0, 9), -.15, 0, 0),
                fun.geometry = sf::st_centroid,
                size = 3,
                color = "gray25") + 
   scale_fill_gradient2(low = "red2",
                        mid = "white",
                        high = "green4",
                        midpoint = 0,
                        labels = scales::number_format()) +
   theme_void() +
   labs(title = "Migrace po krajích",
        subtitle = "za rok 2019",
        fill = "Migrační\nsaldo",
        caption = "zdroj dat: ČSÚ via {czso}") +
   theme(plot.title = element_text(hjust = 1/2,
                                   size = 20),
         plot.subtitle = element_text(hjust = 1/2,
                                      size = 15),
         plot.margin = unit(rep(.5, 4), "cm"),
         legend.text = element_text(hjust = 1),
         legend.title = element_text(hjust = 1/2))