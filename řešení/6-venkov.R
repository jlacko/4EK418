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
  st_transform(5514) %>%  # do Křováka, ať jsou metry jasnější a výpočty rychlejší...
  left_join(obyvatele_obci, by = "KOD_OBEC")

# díra jménem Praha / 50 Km
dira_praha <- obce %>% 
  filter(NAZ_OBEC == "Praha") %>% 
  st_geometry() %>%  # bez dat, jenom hranice obce
  st_centroid() %>%  # střed jako bod místo polygonu
  st_buffer(50000) # hranice 50 kilometrů

# díra jménem Brno / 25 Km
dira_brno <- obce %>% 
  filter(NAZ_OBEC == "Brno") %>% 
  st_geometry() %>%  # bez dat, jenom hranice obce
  st_centroid() %>%  # střed jako bod místo polygonu
  st_buffer(25000) # hranice 25 kilometrů

# výsledný objekt republiky s dírami - pouze geometrie, zatím bez dat
venkov <- RCzechia::republika() %>% 
  st_transform(5514) %>% 
  st_difference(dira_praha) %>% 
  st_difference(dira_brno)

# vizuální kontrola
mapview::mapview(venkov)

vysledek <- st_interpolate_aw(x = obce["obyvatel"],
                              to = venkov,
                              na.rm = T, # pro eliminaci NAček vyvolaných left joinem místo inner
                              extensive = T)

# kontrola
vysledek$obyvatel

# sanity chech - dává podíl obyvatel venkova z celku smysl?
vysledek$obyvatel / sum(obce$obyvatel, na.rm = T)

# 30% republiky v sensu lato Praze a Brně? může být...