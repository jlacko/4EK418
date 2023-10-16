# úkol = optimalizace velikosti mapy pro použití na webu

library(RCzechia)
library(leaflet)
library(dplyr)

obce <- obce_polygony() # obce, prostě obce

listek <- leaflet() %>% 
   addTiles() %>% 
   addPolygons(data = obce,
               color = "red")

# objekt má 20 mega, plus - to je na web moc; optimalizujte pod deset!
print(object.size(listek), units = "Mb")

# výsledek uložte pro další použití jako html soubor
