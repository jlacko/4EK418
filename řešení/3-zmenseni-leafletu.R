# úkol = optimalizace velikosti mapy pro použití na webu

library(RCzechia)
library(leaflet)
library(dplyr)

obce <- obce_polygony() # obce, prostě obce

male_obce <- rmapshaper::ms_simplify(obce,
                                     keep = 1/5,
                                     keep_shapes = T)

listek <- leaflet() %>% 
   addTiles() %>% 
   addPolygons(data = male_obce,
               color = "red")

# objekt má 20 mega, plus - to je na web moc; optimalizujte pod deset!
print(object.size(listek), units = "Mb")