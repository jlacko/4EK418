# volební okrsek, do kterého spadá VŠE
library(sf)
library(dplyr)
library(RCzechia)

okrsky <- RCzechia::volebni_okrsky("low") # low resolution objekty jsou svižnější...

ekonomka <- RCzechia::geocode("náměstí Winstona Churchilla 1938, Praha 3")

# na pořadí záleží!
st_join(okrsky, ekonomka) # ke všem okrskům doplní informace o ekonomce
st_join(ekonomka, okrsky) # k jedné ekonomce doplní informace o okrsku

# varianta s filtrací / ten join, který *není* levý (not left = inner; don't ask me why)
vysledek <- st_join(okrsky, ekonomka, left = F)

# ukázaná platí...
mapview::mapview(vysledek)

# alternativa: prostorový filtr - sf::st_filter()

st_filter(okrsky, ekonomka) %>% 
  mapview::mapview()