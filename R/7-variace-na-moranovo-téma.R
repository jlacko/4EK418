library(sf)
library(dplyr)
library(spdep)

pocet <- 484 # 484 = 22^2

set.seed(1234) # opakovatelnost runifů

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

# fake autokorelované - simulace podle variogramu
fake_model <- gstat::gstat(formula = z ~ 1, dummy = TRUE, beta = 1/2,
                           model = gstat::vgm(1/5,"Exp", 6.5), nmax = 3) 

objekt$autokorelovane <- predict(fake_model, st_centroid(objekt), nsim = 1) %>% 
  pull(sim1) 

plot(objekt["autokorelovane"])


# reálně autokorelované - nadmořská výška
objekt$nad_morem <- exactextractr::exact_extract(
  x = terra::scale(RCzechia::vyskopis(format = 'actual', cropped = F), center = 545),
  y = objekt, 
  fun = "max" 
) 

plot(objekt["nad_morem"])

# matice vah
wahy <- objekt %>% 
  st_geometry() %>% 
  poly2nb(queen = F) %>% # ne monarchii!! / dotyky přes roh neuznávám jako sousedství
  nb2listw()

# kontrola součtů...
sum(objekt$nizke)
sum(objekt$liche)
sum(objekt$nahodne)
sum(objekt$autokorelovane)
sum(objekt$nad_morem) 

# Moranův test pro nízká vs. vysoká čísla
moran.test(objekt$nizke, wahy, alternative = "two.sided")

# Moranův test pro lichá vs. sudá čísla
moran.test(objekt$liche, wahy, alternative = "two.sided")

# Moranův test pro skutečně náhodná čísla
moran.test(objekt$nahodne, wahy, alternative = "two.sided")

# Moranův test pro fake korelovaná čísla
moran.test(objekt$autokorelovane, wahy, alternative = "two.sided")

# Moranův test pro reálně autokorelovaná čísla
moran.test(objekt$nad_morem, wahy, alternative = "two.sided")

# Monte Carlo nad náhodnými čísly
mc_random <- moran.mc(objekt$nahodne, wahy, nsim = 9999, alternative = "two.sided")

mc_random

hist(mc_random$res)
abline(v = mc_random$statistic, col = "red")

# Monte Carlo nad fake autokorelovanými čísly
mc_fake <- moran.mc(objekt$autokorelovane, wahy, nsim = 9999, alternative = "two.sided")

mc_fake

hist(mc_fake$res)
abline(v = mc_fake$statistic, col = "red")

# Monte Carlo nad reálnými čísly
mc_sudety <- moran.mc(objekt$nad_morem, wahy, nsim = 9999, alternative = "two.sided")

mc_sudety

hist(mc_sudety$res)
abline(v = mc_sudety$statistic, col = "red")


