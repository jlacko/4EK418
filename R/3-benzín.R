# je na dálnici benzín dražší?

library(RCzechia)
library(dplyr)
library(sf)

benzin <- readRDS("./data/czech-oil-gc.rds") 

dalnice <- RCzechia::silnice() %>% 
   filter(TRIDA == "dálnice")

# vizuální kontrola
mapview::mapview(dalnice)

okoli_dalnic <- dalnice %>% 
   st_transform(5514) %>% # křovák, protože buffer v metrech
   st_union() %>% 
   st_buffer(2500) %>% 
   st_transform(4326) # zpět do bezpečí WGS84

# vizuální kontrola
mapview::mapview(okoli_dalnic)

# doplnění benzínu o info o dálnici
benzin$blizko <- st_intersects(benzin, okoli_dalnic, sparse = F)[, 1]

# vizuální kontrola
mapview::mapview(benzin, zcol = "blizko")

# mám data - dál už "jenom statistika" :)
model <- lm(data = benzin, formula = cena ~ blizko)

summary(model)