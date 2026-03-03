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
      "náměstí Junkových 2772, Praha",
      "Olbrachtova 62, Praha"
   )) 

# oficiální cenová mapa města Prahy
ceny <- st_read("./data/SED_CenovaMapa_p.shp") %>% 
  st_make_valid() %>% 
  st_transform(4326)


banky_geokodovane <- banky  %>% 
  tidygeocoder::geocode(address = adresa, # jméno sloupce s adresou
                        method = "osm") %>% 
  sf::st_as_sf(coords = c("long", "lat"), crs = 4326) 


banky_ocenene <- banky_geokodovane %>% 
  st_join(ceny) 

# nápověda:
# - věnujte pozornost CRS (oba objekty musí mít stejný)
# - při volání sf::st_join věnujte pozornost argumentu left


# za bonusové body: zvažte v leafletu callu použít icon = ~ favicons[banka] :)
favicons <- iconList(
   "ČSOB" = makeIcon(
      iconUrl = "https://www.csob.cz/o/pui-theme-pw-ng/images/pui/csob/favicons/favicon.ico",
      iconWidth = 25,
      iconHeight = 25
   ),
   "KB" = makeIcon(
      iconUrl = "https://www.kb.cz/img/favicon/favicon-32x32.png",
      iconWidth = 25,
      iconHeight = 25
   ),
   "ČS" = makeIcon(
      iconUrl = "https://www.csas.cz/favicon.ico",
      iconWidth = 25,
      iconHeight = 25
   )
)

library(leaflet)

leaflet(data = banky_ocenene) %>% 
  addTiles() %>% 
  addMarkers(icon = ~ favicons[banka],
             popup = ~ CENA)
