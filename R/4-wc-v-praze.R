# záchody v Praze
# modelový příklad na point - in - polygon problém

library(sf)
library(dplyr)

zachody <- st_read('./data/zachodky.json')

mapview::mapview(zachody)

ctvrti <- RCzechia::casti() %>% 
   filter(NAZ_OBEC == 'Praha')

vysledek <- st_join(ctvrti, zachody, left = F) %>% 
   st_drop_geometry() %>%  # prostorovu složku už nepotřebuju
   group_by(NAZEV) %>% # podle názvů....
   tally() %>%  # ...sečtu řádky
   arrange(desc(n)) # a seřadím sestupně

vysledek