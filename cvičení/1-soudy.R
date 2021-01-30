# úkol = zakreslit na mapě města Brna
# 1) ústavní soud
# 2) nejvyšší soud
# 3) řeky pro orientaci

soudy <- data.frame(
   druh = c("ústavní", "nejvyšší"),
   adresa = c("Joštova 625, Brno",
              "Burešova 20, Brno"))


# nápověda:
# - všechny obce jsou v RCzechia::obce_polygony()
# - Svitava & Svratka jsou v RCzechia::reky("Brno)
# - při kreslení polygonu nezapomeňte zakázat výplň / fill = NA
