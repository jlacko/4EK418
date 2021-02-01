library(sf)
library(dplyr)
library(giscoR)
library(ggplot2)

# celý svět, 1: 20M
svet <- gisco_get_countries(resolution = "20")

# Grónsko a Kongo
glmd <- svet %>% 
   filter(CNTR_ID %in% c('GL', 'CD'))

# web mercator = default na google maps
ggplot() +
   geom_sf(data = glmd, fill = "red", color = NA) +
   geom_sf(data = svet, fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("EPSG:3857"),
            ylim = c(-20e6, 20e6))

# podíl plochy Grónska a Konga
st_area(glmd[glmd$CNTR_ID=="GL",]) / st_area(glmd[glmd$CNTR_ID=="CD",])

# Mollweide - equal area
ggplot() +
   geom_sf(data = glmd, fill = "red", color = NA) +
   geom_sf(data = svet, fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("ESRI:53009"))

# Gall Peters - nejlepší PR... https://youtu.be/H3Xyz9MgDWA :)
ggplot() +
   geom_sf(data = glmd, fill = "red", color = NA) +
   geom_sf(data = svet, fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("+proj=cea +lon_0=0 +x_0=0 +y_0=0 +lat_ts=44 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))

# Winkel tripel - kompromisní řešení...
ggplot() +
   geom_sf(data = glmd, fill = "red", color = NA) +
   geom_sf(data = svet, fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("ESRI:54019"))

# Albers - specializováno na USA (lower 48)
ggplot() +
   geom_sf(data = glmd, fill = "red", color = NA) +
   geom_sf(data = svet, fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("EPSG:5070"))

# Albers - detail lower 48
ggplot() +
   geom_sf(data = filter(svet, CNTR_ID == "US"), fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("EPSG:5070"),
            ylim = c(-5000,  3300000),
            xlim = c(-2500000, 2200000))

# Mercator - detail lower 48
ggplot() +
   geom_sf(data = filter(svet, CNTR_ID == "US"), fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("EPSG:3857"),
            ylim = c(2800000,  6500000),
            xlim = c(-14000000, -7500000))

# inž. Křovák - specializováno na Československo
ggplot() +
   geom_sf(data = glmd, fill = "red", color = NA) +
   geom_sf(data = svet, fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("EPSG:5514"))

# inž. Křovák - detail Československa
ggplot() +
   geom_sf(data = filter(svet, CNTR_ID %in% c("CZ", "SK")), fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("EPSG:5514"))

# Mercator - detail Československa
ggplot() +
   geom_sf(data = filter(svet, CNTR_ID %in% c("CZ", "SK")), fill = NA, color = "gray45") +
   coord_sf(crs = st_crs("EPSG:3857"))

