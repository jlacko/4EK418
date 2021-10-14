library(raster) # rasterová objekty; před dplyr, kolize na select
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