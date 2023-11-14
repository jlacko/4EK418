# úkol: připravit matici vah a sousedství pro hrabství v Severní Karolnině
# 1) technikou královny
# 2) technikou věže
# 3) identifikovat hrabství s největším rozdílme mezi věží a královnou
# 4) vypsat soudedy hrabství Mecklenburg (jako Šarlota z Meckleburg-Strelitz, manželka krále Jiřího)

library(sf)      # obecná manipulace s prostorovými daty + soubor nc.shp
library(dplyr)   # manipulace s data frames
library(spdep)   # prostorová analytika, včetně sousedství
library(ggplot2) # protože obrázek :)

# soubor s hrabstvími (counties)
karolina <- st_read(system.file("shape/nc.shp", package="sf")) # included with sf package

# základní orientace:
ggplot() +
  geom_sf(data = karolina) +
  geom_sf(data = subset(karolina, NAME == "Mecklenburg"), fill = "red")


# pro porovnání sousedství uvažujte setdiff.nb() + objekt s nejvíce rozdíly má největší hodnotu lengths()

# sousedi královny
queen <- karolina %>% 
  poly2nb(queen = T)

# sousedi věže
rook <- karolina %>% 
  poly2nb(queen = F)

# rozdíl mezi sousedstvím věže a královny jako číslo (pořadí prvku)
qr_rozdil <- setdiff.nb(rook, queen) %>% 
  lengths() %>% 
  which.max()

# jméno okresu s největším rozdílem
karolina$NAME[qr_rozdil]

# vizuálně...
mapview::mapview(karolina[qr_rozdil,])

# sousedi hrabství Mecklenburg:
# 1) počadí mecklenburgu mezi 100 counties
sarlota <- which(karolina$NAME == "Mecklenburg")

# 2) jméno sousedů okresu mecklenburg = prvku v pořadí "sarlota" 
karolina$NAME[rook[sarlota][[1]]]