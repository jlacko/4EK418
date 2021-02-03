# rozdělit kraje ČR na dvě části / Čechy a Moravu
# 1) podle krajů
# 2) podle řeky Moravy

library(tidyverse)
library(RCzechia)

# toto jsou kraje
kraje <- kraje("low") # nízké rozlišení je elegantnější

# toto je řeka morava
reka_morava <- reky() %>% 
   filter(NAZEV == "Morava") %>% 
   summarize()

# nápověda:
# - potřebujete 2 části / bude se hodit dplyr::group_by & dplyr::summarize
# - Moravské kraje mají kód vyšší jak 3110 (Vysočina je divná, uznám jí v obojím...)

ggplot() +
   geom_sf(data = kraje) +
   geom_sf(data = reka_morava, color = "steelblue") +
   geom_sf_label(data = kraje, aes(label = KOD_KRAJ)) 


kraje_dve <- kraje %>% 
  mutate(morava_kod = ifelse(as.numeric(KOD_KRAJ) > 3110, "morava", "zbytek světa"),
         morava_reka = ifelse(st_intersects(., reka_morava, sparse = F), "morava", "zbytek světa"))

morava_cislem <- kraje_dve %>% 
  group_by(morava_kod) %>% 
  summarise()

# vizuální kontrola 
plot(morava_cislem)

morava_rekou <- kraje_dve %>% 
  group_by(morava_reka) %>% 
  summarise()

# vizuální kontrola
plot(morava_rekou)