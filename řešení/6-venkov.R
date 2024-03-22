# Vytvořte objekt "venkov", který bude představovat:
# - území České republiky, 
# - kromě! okruhu 50 kilometrů kolem středu Prahy
# - a současně okruhu 25 kilometrů kolem středu Brna
# (= jedna republika se dvěma dírama)
# - ukažte ho na mapě
# - extrapolujte počet obyvatel "venkova" z počtu obyvatel obcí

library(RCzechia)
library(dplyr)
library(sf)

obyvatele_obci <- czso::czso_get_table("SLDB-VYBER") %>% # výsledky Sčítání lidu 2010
   filter(uzcis == "43") %>% # hodnoty za obce / chybí obce vzniklé po roce 2010, to je OK
   select(KOD_OBEC = uzkod, obyvatel = vse1111) %>% # vse1111 = celkový počet obyvatel
   mutate(obyvatel = as.numeric(obyvatel))
   
obce <- obce_polygony() %>% 
  inner_join(obyvatele_obci, by = "KOD_OBEC")

dira_praha <- obce %>% 
  filter(NAZ_OBEC == "Praha") %>% 
  st_geometry() %>% 
  st_centroid() %>% 
  st_buffer(50000)

dira_brno <- obce %>% 
  filter(NAZ_OBEC == "Brno") %>% 
  st_geometry() %>% 
  st_centroid() %>% 
  st_buffer(25000)

venkov <- republika() %>% 
  st_geometry() %>% 
  st_difference(dira_praha) %>% 
  st_difference(dira_brno)


venkov_obyvatele <- st_interpolate_aw(obce["obyvatel"],
                                      venkov,
                                      extensive = T)

# Nápověda:
# - obce jsou v RCzechia::obce_polygony()
# - střed je sf::st_centroid()
# - rozdíl je difference / sf::st_difference()
# - interpolace plochou je sf::st_interpolate_aw()