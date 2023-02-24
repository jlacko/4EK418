# úkol = zakreslit na mapě Středočeského kraje
# 1) muzeum Škodovek v Mladé Boleslavi
# 2) Hornické muzeum Příbram 

muzea <- data.frame(
   mesto = c("Boleslav", "Příbram"),
   adresa = c("Václava Klementa 294, Mladá Boleslav",
              "Husova 29, Příbram"))

# nápověda:
# - všechny kraje jsou v RCzechia::kraje()
# - geocode z tidygeocoder potřebuje konverzi st_as_sf
# - při kreslení polygonu nezapomeňte zakázat výplň / fill = NA
