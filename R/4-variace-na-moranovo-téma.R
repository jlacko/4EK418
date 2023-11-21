library(sf)
library(dplyr)
library(spdep)

pocet <- 484 # 484 = 25^2

objekt <- RCzechia::republika() %>% 
  st_make_grid(n = sqrt(pocet)) %>% # čtverec o hraně sqrt(n) = n buněk celkem
  st_as_sf() %>% 
  mutate(id = 1:pocet) 

# nízké idčka - polovina tak, polovina onak
objekt$nizke <- as.numeric(objekt$id <= nrow(objekt)/2)

plot(objekt["nizke"])

# střídání sudá / lichá - s xorem na to samé po řádkách, aby vyšla šachovnice (a ne sloupky / řádky)
objekt$liche <- as.numeric(xor(objekt$id %% 2, rep(c(rep(1, sqrt(pocet)), rep(0,sqrt(pocet))), sqrt(pocet)/2)))

plot(objekt["liche"])

# skutečně náhodné rozložení
objekt$nahodne <- runif(n = nrow(objekt))

plot(objekt["nahodne"])

# matice vah
wahy <- objekt %>% 
  st_geometry() %>% 
  poly2nb(queen = F) %>% # ne monarchii!! / dotyky přes roh neuznávám jako sousedství
  nb2listw()

# kontrola součtů...
sum(objekt$nizke)
sum(objekt$liche)
sum(objekt$nahodne)

# Moranův test pro nízká čísla
moran.test(objekt$nizke, wahy, alternative = "two.sided")

# Moranův test pro lichá čísla
moran.test(objekt$liche, wahy, alternative = "two.sided")

# Moranův test pro skutečně náhodná čísla
moran.test(objekt$nahodne, wahy, alternative = "two.sided")