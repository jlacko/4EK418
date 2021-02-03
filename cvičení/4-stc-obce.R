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