# máte dataset zemědělství ve střední Evropě
# najděte obci ČR která je nejvíce zemědělská / má největší podíl zemědělské plochy na celkové
library(dplyr)
library(terra)

# středoevropské polelány za rok 2019 (poslední známý) - https://lcviewer.vito.be/download
cesta <- "https://s3-eu-west-1.amazonaws.com/vito.landcover.global/v3.0.1/2019/E000N60/E000N60_PROBAV_LC100_global_v3.0.1_2019-nrt_Crops-CoverFraction-layer_EPSG-4326.tif"

# cílový soubor včetně cesty (z důvodu velikosti není v gitu)
stazeny_rastr <- "./data/cropland.tif"

# stažení právě jednou = pokud soubor existuje, download se přeskočí; pokud ne tak se stahne do /data
if(!file.exists(stazeny_rastr)) curl::curl_download(url = cesta, destfile = stazeny_rastr)

# pracovní objekty
polelany <- rast(stazeny_rastr)

# vizuální overview
plot(polelany)

obce <- RCzechia::obce_polygony()

obce$polelany <- exactextractr::exact_extract(
  x = polelany,
  y = obce,
  fun = "mean"
)

plot(obce["polelany"])

obce %>% 
  slice_max(order_by = polelany) %>% 
  mapview::mapview()