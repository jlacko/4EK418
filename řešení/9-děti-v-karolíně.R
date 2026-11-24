# úkol: porovnat prostorovou autokorelaci dvou metrik v hrabstvích Severní Karolíny
# data: porody a úmrtí na syndrom náhlého úmrtí kojence (SIDS) v letech 1974 až 1978
# - BIR74 = všechny porody
# - NWBIR74 = porody barevných dětí (non-white births)
# - SID74 = úmrtí na SIDS (sudden infant death syndrome)
# 
# otázka zní: 
# 1) jsou metriky náhodně rozložené, nebo autokorelované? 
# 2) pokud jsou obě autokorelované, tak která víc?


library(sf)      # obecná manipulace s prostorovými daty + soubor nc.shp
library(dplyr)   # manipulace s data frames
library(spdep)   # prostorová statistika

# soubor s hrabstvími (counties)
karolina <- st_read(system.file("shape/nc.shp", package="sf")) %>%  # included with sf package
  transmute(nebile = NWBIR74 / BIR74,
            sidy = SID74 / BIR74 * 1000)

# základní orientace
glimpse(karolina)


# Nápověda:
# - sousedství je spdep::poly2nb(), matice vah z něj spdep::nb2listw()
# - Moranův test je spdep::moran.test()

# vizuální přehled = do čeho jdu?
plot(karolina)

# sousedské váhy, vše v defaultu z výroby...
vahy <- karolina %>% 
  poly2nb() %>% 
  nb2listw()

# test podle předpokladů
moran.test(karolina$nebile, vahy)
moran.test(karolina$sidy, vahy)

# test uvařených bramboraček
moran.mc(karolina$nebile, vahy, 9999)
moran.mc(karolina$sidy, vahy, 9999)