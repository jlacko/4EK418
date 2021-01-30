# Příklad stažení polygonů administrativních oblastí
# na úrovni EU jako celku / interface do GISCO z Eurostatu

library(giscoR)
library(ggplot2)
library(dplyr)
library(sf)


# nejčerstvější NUTS v rozlišení 1 ku milionu; kompletní (celá EU)
orisky <- gisco_get_nuts(
  year = "2021", # platnost dat
  epsg = "4326", # souřadnicový systém /4326 = WGS84 = dobrý default
  resolution = "01", # rozlišení
  nuts_level = "3" # úroveň NUTS; 3 = naše kraje
)

# Varšava v Polsku, Vídeň v Rakousku
mesta <- orisky %>% 
  filter(FID %in% c("PL911", "AT130"))

# vizuální kontrola
mapview::mapview(mesta)