# dohledání souřadnic a zakreslení na mapě
# přístup:
# - tidygeocoder nad data framem
# - tidygeocoder nad vektrorem adres
# - API ČUZK via RCzechia
 
library(sf)
library(dplyr)

# prostý data frame - dva slouce
skoly <- data.frame(
   skola = c("VŠE", "Matfyz", "Přfuk"),
   adresa = c(
      "nám. Winstona Churchilla 1938/4, Praha",
      "Malostranské náměstí 2, Malá Strana",
      "Albertov 6, Praha 2"
   ))

# geocoding nad data framem (fce geocode očekává vstup jako data frame)
skoly_souradnice <- skoly %>% 
   tidygeocoder::geocode(address = adresa, # jméno sloupce s adresou
                         method = "osm")

skoly_sf <- skoly_souradnice %>% 
   sf::st_as_sf(coords = c("long", "lat"), crs = 4326) 

# rychlá vizuální kontrola
mapview::mapview(skoly_sf)

# adresa s jistotou v zahraničí / geo_osm bere jako vstup textový vektor
zahranici <- tidygeocoder::geo("1600 Pennsylvania Avenue NW, Washington DC") %>% 
   sf::st_as_sf(coords = c("long", "lat"), crs = 4326)

mapview::mapview(zahranici)

# proti API ČUZK / očekává se vstup jako vektor adres (textový vektor)
ekonomka <- RCzechia::geocode("náměstí Winstona Churchilla 1938, Praha 3")

# rychlá vizuální kontrola
mapview::mapview(ekonomka)
