# úkol: připravit matici vah a sousedství pro hrabství v Severní Karolnině
# 1) technikou královny
# 2) technikou věže
# 3) identifikovat hrabství s největším rozdílem mezi věží a královnou
# 4) vypsat sousedy hrabství Mecklenburg (jako Šarlota z Meckleburg-Strelitz, manželka krále Jiřího)

library(sf)      # obecná manipulace s prostorovými daty + soubor nc.shp
library(dplyr)   # manipulace s data frames
library(spdep)   # prostorová analytika, včetně sousedství
library(leaflet) # protože interaktivita :)

# soubor s hrabstvími (counties)
karolina <- st_read(system.file("shape/nc.shp", package="sf")) # included with sf package

# základní orientace
leaflet() %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  # hrabství, co se NEjmenují po manželce krále Jiřího
  addPolygons(data = subset(karolina, NAME != "Mecklenburg"),
              label = ~ NAME) %>% 
  # hrabství, co se jmenují po manželce krále Jiřího
  addPolygons(data = subset(karolina, NAME == "Mecklenburg"),
              label = ~ NAME,
              color = "red") 

# pro porovnání sousedství uvažujte setdiff.nb() + objekt s nejvíce rozdíly má největší hodnotu lengths()

sousedi_veze <- poly2nb(st_geometry(karolina), queen = F)
sousedi_kralovny <- poly2nb(st_geometry(karolina), queen = T)

delta <- setdiff.nb(sousedi_kralovny, sousedi_veze)

karolina$NAME[which.max(lengths(delta))]

karolina$NAME[sousedi_kralovny[which(karolina$NAME == "Mecklenburg")][[1]]]

