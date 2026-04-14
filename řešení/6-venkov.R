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


hranice <- RCzechia::republika() %>% 
  st_transform(5514)

okoli_prahy <- RCzechia::obce_body() %>% 
  filter(NAZ_OBEC == "Praha") %>% 
  st_transform(5514) %>% 
  st_buffer(50000)

okoli_brna <- RCzechia::obce_body() %>% 
  filter(NAZ_OBEC == "Brno") %>% 
  st_transform(5514) %>% 
  st_buffer(25000)

venkov <- hranice %>% 
  st_difference(okoli_prahy) %>% 
  st_difference(okoli_brna)

mapview::mapview(venkov)

obce_s_obyvateli <- RCzechia::obce_polygony() %>% 
  inner_join(obyvatele_obci) %>% 
  st_transform(st_crs(venkov))

st_interpolate_aw(obce_s_obyvateli["obyvatel"],
                  st_geometry(venkov),
                  extensive = T)