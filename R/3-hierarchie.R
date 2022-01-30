# sf × sfc × sfg - uchopení konceptu
library(sf)
library(dplyr)
library(RCzechia)
library(ggplot2)

# sf objekt = data + geometrie
sf_objekt <- kraje("low")

sf_objekt

class(sf_objekt)

# sfc objekt = prostá geometrie (včetně CRS)
sfc_objekt <- st_geometry(sf_objekt)

sfc_objekt

class(sfc_objekt)

# sfg objekt = pouze geometrie (už bez CRS)
sfg_objekt <- sfc_objekt[[6]]

sfg_objekt

class(sfg_objekt)

# nakreslit všechno....
plot(sf_objekt)
plot(sfc_objekt)
plot(sfg_objekt, col = "red")

# zpátky nahoru...
coll <- st_sfc(sfg_objekt, sfc_objekt[[1]],
               crs = 4326)

coll

class(coll)

coll_data <- coll %>% 
   st_as_sf() %>% 
   mutate(kraj = c("liberecký",
                   "středočeský"))

coll_data

class(coll_data)

plot(coll_data)

# něco úplně jiného...

st_drop_geometry(sf_objekt)