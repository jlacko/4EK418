# najít nejdražší pražský pozemek
# zdroj dat: cenová mapa města Prahy

library(sf)
library(dplyr)
library(leaflet)

# aktuální data = https://geoportalpraha.cz/data-a-sluzby/ee452049c59740f7b797ca9263b99847_0
mapa <- sf::st_read("./data/SED_CenovaMapa_p.shp") %>% # načíst data
   sf::st_transform(4326) %>%  # transformovat z Křováka do WGS84
   sf::st_zm() # zahodit výškovou dimenzi shapefilu

# nejdražší pozemek / zpracování technikami {dplyr}
nejdrazsi <- mapa %>% 
   filter(CENA != "N") %>% # N = neoceněné pozemky / komplikují převod na číslo
   mutate(CENA = as.numeric(CENA)) %>% # číslo z textu
   arrange(desc(CENA)) %>% # seřadit sestupně 
   slice(1) # vybrat první řádek

# podat zprávu (interaktivně)
leaflet(data = nejdrazsi) %>% 
   addProviderTiles("CartoDB.Positron") %>% 
   addPolygons(fillColor = "goldenrod",
               stroke = F,
               fillOpacity = 1/2,
               popup = ~paste(rank(-nejdrazsi$CENA, ,"min"),
                              ". nejdražší<br>cena: ", nejdrazsi$CENA,"Kč / m2"))

# kontrola - "oficiální" aplikace: https://app.iprpraha.cz/apl/app/cenova-mapa/