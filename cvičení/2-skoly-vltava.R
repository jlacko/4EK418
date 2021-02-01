# úkol = tři pražské vysoké školy
# 1) zaměřit na mapě / ogeokódovat
# 2) najít tu nich, která je nejbližší k Vltavě
# 3) ukázat na mapě

library(dplyr)

vltava <- RCzechia::reky("Praha") 

skoly <- data.frame(
   skola = c("VŠE", "Matfyz", "Přfuk"),
   adresa = c(
      "náměstí Winstona Churchilla 1938/4, Praha 3",
      "Malostranské náměstí 2, Malá Strana",
      "Albertov 6, Praha 2"
   )) 

# nápověda:
# - geocode z tidygeocoder potřebuje konverzi st_as_sf
# - za bonusové body: sf::st_nearest_points :)