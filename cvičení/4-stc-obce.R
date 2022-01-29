# STČ volby - z okrsků na obce
# & obce do grafu

library(sf)
library(dplyr)
ABlibrary(RCzechia)
library(ggplot2)

# uvažujte hodnoty výsledků po okrscích
source("./R/4-okrsky-viz.R")

# přeneste hodnoty na obce středočeského kraje
stc_obce <- obce_polygony() %>% 
   filter(KOD_CZNUTS3 == "CZ020") 

# a podejte zprávu po obcích / analogicky jako grafy absolutně & relativně po okrscích
# (okrasný prvek řek není poviný)