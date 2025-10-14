library(sf)
library(dplyr)
library(giscoR)

# všechny státy světa, na hrubo stačí
svet <- gisco_get_countries(resolution = "60") %>% 
  st_transform("ESRI:53009") # systém pana Mollweida

# vizuální overview
plot(st_geometry(svet))

# jeden ze států...
lafrance <- svet %>% 
   filter(CNTR_ID == "FR") # Vive La France!

# logický vektor: sousedí s Francií?
sousedi <- sf::st_touches(lafrance,
                          svet, sparse = F)

# zde je akce!
sf::st_intersection(lafrance, svet[sousedi, ]) %>% # průsečík jako čára
   mutate(delka = st_length(.)) %>% # nový sloupec: délka (hranice)
   select(soused = CNTR_NAME.1, delka) %>%  # výběr relevantních sloupců
   st_drop_geometry() %>% # již jí nepotřebuji...
   arrange(desc(delka)) # pro přehled setřídit