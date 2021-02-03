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
   

# Nápověda:
# - obce jsou v RCzechia::obce_polygony()
# - střed je sf::st_centroid()
# - rozdíl je difference / sf::st_difference()
# - interpolace plochou je sf::st_interpolate_aw()

obce <- obce_polygony() %>% 
  st_transform(5514)

hranice <- republika("low") %>% 
  st_transform(5514)

praha <- obce_body() %>% 
  filter(NAZ_OBEC == "Praha") %>% 
  st_transform(5514) %>% 
  st_buffer(50*1000)

brno <- obce_body() %>% 
  filter(NAZ_OBEC == "Brno") %>% 
  st_transform(5514) %>% 
  st_buffer(25*1000)

venkov <- hranice %>% 
  st_difference(praha) %>% 
  st_difference(brno)

# vizuální kontrola
mapview::mapview(venkov)

obce_lidi <- obce %>% 
  inner_join(obyvatele_obci)

emental <- st_interpolate_aw(x = obce_lidi["obyvatel"],
                             st_geometry(venkov),
                             extensive = T)

emental