# najít nejdražší pražský pozemek
# zdroj dat: cenová mapa města Prahy

library(sf)
library(dplyr)
library(leaflet)

# metadata = https://www.geoportalpraha.cz/en/data/metadata/C4FE893C-81B9-4B4A-BDB4-292479C87E2D
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
   addProviderTiles("Stamen.Toner") %>% 
   addPolygons(fillColor = "goldenrod",
               stroke = F,
               fillOpacity = 1/2,
               popup = ~paste(rank(-nejdrazsi$CENA, ,"min"),
                              ". nejdražší<br>cena: ", nejdrazsi$CENA,"Kč / m2"))

# kontrola - "oficiální" aplikace: https://app.iprpraha.cz/apl/app/cenova-mapa/