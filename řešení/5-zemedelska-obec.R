# máte dataset zemědělství ve střední Evropě
# najděte obci ČR která je nejvíce zemědělská / má největší podíl zemědělské plochy na celkové

library(terra)

# středoevropské polelány za rok 2019 - Copernicus to schoval, náhradní řešení tedy...
cesta <- "https://jla-unsecure.s3.eu-central-1.amazonaws.com/raster-data/cropland.tif"

# cílový soubor včetně cesty (z důvodu velikosti není v gitu)
stazeny_rastr <- "./data/cropland.tif"

# stažení právě jednou = pokud soubor existuje, download se přeskočí; pokud ne tak se stahne do /data
if(!file.exists(stazeny_rastr)) curl::curl_download(url = cesta, destfile = stazeny_rastr)

# pracovní objekty
polelany <- rast(stazeny_rastr)

# vizuální overview
plot(polelany)

obce <- RCzechia::obce_polygony()

# varianta součet - více pixelů dohromady je víc
obce$soucet_px <- exactextractr::exact_extract(x = polelany,
                                               y = obce,
                                               fun = "sum")

mapview::mapview(obce[which.max(obce$soucet_px),]) # je to Praha, protože největší!

# varianta průměr - více pixelů vztažených k celku je víc
obce$soucet_px <- exactextractr::exact_extract(x = polelany,
                                               y = obce,
                                               fun = "mean")

mapview::mapview(obce[which.max(obce$soucet_px),]) # Kmetiněves u Velvar, protože proč ne...

