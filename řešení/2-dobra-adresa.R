# úkol = tři pražské banky
# 1) zaměřit na mapě / ogeokódovat
# 2) prostorově spojit s cenovou mapou
# 3) zjistit nejdražší pozemek

library(sf)
library(dplyr)
library(leaflet)

# tři headofficy tří bank
banky <- data.frame(
   banka = c("ČSOB", "KB", "ČS"),
   adresa = c(
      "Radlická 333, Praha",
      "Náměstí Junkových 1, Praha",
      "Olbrachtova 62, Praha"
   )) 

# oficiální cenová mapa města Prahy
ceny <- st_read("./data/SED_CenovaMapa_p.shp") %>% 
  st_make_valid() # univerzální opravovač chybné geometrie !!!

banky_geo <- banky %>% 
  tidygeocoder::geocode(address = "adresa") %>% 
  st_as_sf(coords = c("long", "lat"), crs = 4326)

st_join(banky_geo,
        st_transform(ceny, st_crs(banky_geo)))


# nápověda:
# - věnujte pozornost CRS (oba objekty musí mít stejný)
# - při volání sf::st_join věnujte pozornost argumentu left


# za bonusové body: zvažte v leafletu callu použít icon = ~ favicons[banka] :)
favicons <- iconList(
   "ČSOB" = makeIcon(
      iconUrl = "https://www.csob.cz/pui-theme-psp/images/pui/csob/favicons/favicon.ico",
      iconWidth = 25,
      iconHeight = 25
   ),
   "KB" = makeIcon(
      iconUrl = "https://www.kb.cz/favicon.ico",
      iconWidth = 25,
      iconHeight = 25
   ),
   "ČS" = makeIcon(
      iconUrl = "https://www.csas.cz/favicon.ico",
      iconWidth = 25,
      iconHeight = 25
   )
)

leaflet(banky_geo) %>% 
  addProviderTiles("Stamen.Toner") %>% 
  addMarkers(icon = ~ favicons[banka])

