# máte dataset zemědělství ve střední Evropě
# najděte obci ČR která je nejvíce zemědělská / má největší podíl zemědělské plochy na celkové

library(terra)

# středoevropské polelány za rok 2019 (poslední známý) - https://lcviewer.vito.be/download
cesta <- "https://s3-eu-west-1.amazonaws.com/vito.landcover.global/v3.0.1/2019/E000N60/E000N60_PROBAV_LC100_global_v3.0.1_2019-nrt_Crops-CoverFraction-layer_EPSG-4326.tif"

# cílový soubor včetně cesty (z důvodu velikosti není v gitu)
stazeny_rastr <- "./data/cropland.tif"

# vizuální overview
plot(stazeny_rastr)