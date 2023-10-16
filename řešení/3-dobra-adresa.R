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
ceny <- st_read("./data/SED_CenovaMapa_p.shp") 


# nápověda:
# - věnujte pozornost CRS (oba objekty musí mít stejný)
# - při volání sf::st_join věnujte pozornost argumentu left


# krok první = geokódovat banky
banky_geocoded <- banky %>% 
  tidygeocoder::geocode(address = "adresa") %>% 
  st_as_sf(coords = c("long", "lat"), crs = 4326) %>% 
  st_transform(st_crs(ceny))

# krok druhý = propojit banky s cenami
banky_ceny <- banky_geocoded %>% 
  st_join(ceny)


# krok tři = nejdražší pozemek
banky_ceny %>% 
  st_drop_geometry() %>% # už prostorovu složku nepotřebuji, zahazuju
  arrange(desc(CENA)) %>% 
  select(banka, adresa, CENA) # pro přehednost pouze výběr sloupců

# za bonusové body: zvažte v leafletu callu použít icon = ~ favicons[banka] :)
favicons <- iconList(
   "ČSOB" = makeIcon(
      iconUrl = "https://www.csob.cz/o/pui-theme-pw-ng/images/pui/csob/favicons/favicon.ico",
      iconWidth = 25,
      iconHeight = 25
   ),
   "KB" = makeIcon(
      iconUrl = "https://www.kb.cz/img/favicon/favicon.ico",
      iconWidth = 25,
      iconHeight = 25
   ),
   "ČS" = makeIcon(
      iconUrl = "https://www.csas.cz/favicon.ico",
      iconWidth = 25,
      iconHeight = 25
   )
)

# za bonusové body leavlet s ikonami

leaflet(data = st_transform(banky_ceny, 4326)) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addMarkers(icon = ~ favicons[banka],
             popup = ~ paste("cena pozemku", CENA, "kč / m²"))