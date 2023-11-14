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




