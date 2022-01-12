library(raster, exclude = "select") # rasterová objekty; před dplyr, kolize na select
library(sf) # vektorové objekty
library(exactextractr) # pro sečtení rastru přes vektorové polygony
library(dplyr)
library(ggplot2)

# středoevropské polelány za rok 2019 (poslední známý) - https://lcviewer.vito.be/download
cesta <- "https://s3-eu-west-1.amazonaws.com/vito.landcover.global/v3.0.1/2019/E000N60/E000N60_PROBAV_LC100_global_v3.0.1_2019-nrt_Crops-CoverFraction-layer_EPSG-4326.tif"

# cílový soubor včetně cesty (z důvodu velikosti není v gitu)
stazeny_rastr <- "./data/cropland.tif"

# stažení právě jednou = pokud soubor existuje, download se přeskočí; pokud ne tak se stahne do /data
if(!file.exists(stazeny_rastr)) curl::curl_download(url = cesta, destfile = stazeny_rastr)

# pracovní objekty
polelany <- raster(stazeny_rastr)
obce <- RCzechia::obce_polygony()

# úvodní orientace / ggplot2 s rasterem moc nekamarádí; base R je jistější
plot(polelany)

# nový sloupec v objektu obce - podíl zemědělské plochy
obce$polelany <- exactextractr::exact_extract(
  x = polelany, # zdrojový rastr
  y = obce, # cílové polygony
  fun = "mean" # transformační funkce (normalizuje nestejné plochy)
) 

# vizuální kontrola
ggplot(data = obce, aes(fill = polelany)) +
  geom_sf(color = NA) +
  scale_fill_gradientn(colours = rev(terrain.colors(7)),
                       name = "zemědělská plocha\n(v % z celkové)")

# načtení registru + srovnání češtiny
obce_vozidla <- readr::read_csv2("./data/obec_dr.csv") %>% 
  mutate(obec = stringi::stri_encode(obec, from = "Windows-1250", to = "UTF-8"),
         pou = stringi::stri_encode(pou, from = "Windows-1250", to = "UTF-8"),
         # srovnání terminologie s RCzechia::obce_polygony / aby se obce potkaly...
         pou = ifelse(pou == "Hlavní město Praha", "Praha", pou), 
         pou = ifelse(pou == "Jesenice (okres Rakovník)", "Jesenice", pou),
         pou = ifelse(pou == "Jesenice (okres Praha-západ)", "Jesenice", pou))

# kompletní číselník druhů strojů
ciselnik_druhu <- readxl::read_excel("./data/ciselnikyrzdruh.xls", sheet = "Druh")

# traktory = název obsahuje traktor, ale nejde o přívěs či návěs
traktory <- ciselnik_druhu %>% 
  filter(grepl("traktor", tolower(Nazev)) 
         & !grepl("návěs", tolower(Nazev))
         & !grepl("přívěs", tolower(Nazev))) %>% 
  pull(Zkratka)

obce_vozidla <- obce_vozidla %>% 
  dplyr::select(obec, pou, any_of(traktory)) %>% # vybereme proměnné v traktorech
  rowwise() %>%  # otočíme dplyr na řádkové operace
  mutate(traktory = sum(c_across(where(is.numeric)))) %>%  # sečenem číselné hodnoty
  dplyr::select(NAZ_OBEC = obec, NAZ_POU = pou, traktory) # srovnání na sloupce z RCzechia::obce_polygony

# připojíme k obcím počty traktorů traktory
obce <- obce %>% 
  left_join(obce_vozidla, by = c("NAZ_OBEC", "NAZ_POU")) %>% 
  mutate(zelena_plocha = polelany / 100 * st_area(.))

# konečně akce! :)
model <- lm(traktory ~ zelena_plocha,
   data = obce)

summary(model)

# rezidua do objektu obcí / aby šly mapovat
obce$resids <- model$residuals

ggplot(data = obce) +
  geom_sf(aes(fill = resids), color = NA) +
  scale_fill_viridis_c()
  
# deset největších úletů...
obce %>% 
  st_drop_geometry() %>% 
  select(NAZ_OBEC, traktory, resids) %>% 
  arrange(desc(resids)) %>% 
  top_n(10)