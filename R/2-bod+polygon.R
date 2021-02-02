# volební okrsek, do kterého spadá VŠE
library(sf)
library(dplyr)
library(RCzechia)

# raw verze z ČUZK; rozbalená by byla moc velká pro GitHub
if(!file.exists("./data/20201003_ST_UVOH.xml")) {
  unzip("./data/20201003_ST_UVOH.xml.zip",
         exdir = "./data")
} 

okrsky <- st_read("./data/20201003_ST_UVOH.xml") %>% 
   st_set_geometry("OriginalniHranice") %>% 
   select(-DefinicniBod) %>%  # okrsky mají dvě geometrie, tato se nehodí
   st_transform(4326)

ekonomka <- RCzechia::geocode("náměstí Winstona Churchilla 1938, Praha 3")

# na pořadí záleží!
st_join(okrsky, ekonomka) # ke všem okrskům doplí informace o ekonomce
st_join(ekonomka, okrsky) # k jedné ekonomce doplní informace o okrsku

# varianta s filtrací / join, který *není* levý (not left = inner; don't ask why)
vysledek <- st_join(okrsky, ekonomka, left = F)

# ukázaná platí...
mapview::mapview(vysledek)