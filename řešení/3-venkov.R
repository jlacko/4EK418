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

buffer_prahy <- obce_polygony() %>% 
  filter(NAZ_OBEC == "Praha") %>% 
  st_geometry() %>% # data už nepořebuju, stačí čistá geometrie
  st_transform(5514) %>% # křovák
  st_centroid() %>%  # středobod
  st_buffer(50000) %>%  # padesát kilometrů kolem středu
  st_transform(4326) # zpátky do bezpečí...

# jako Praha, ale menší...
buffer_brna <- obce_polygony() %>% 
  filter(NAZ_OBEC == "Brno") %>% 
  st_geometry() %>% 
  st_transform(5514) %>% 
  st_centroid() %>%  
  st_buffer(25000) %>% 
  st_transform(4326)

# objekt venkov jako polygon
venkov <- republika() %>% 
  st_difference(buffer_prahy) %>% 
  st_difference(buffer_brna)

# vizuální kontrola
plot(venkov)

# pomocný objekt obecní populace / obce s datovou a prostorovou složkou současně

obecni_populace <- obce_polygony() %>% 
  inner_join(obyvatele_obci, by = "KOD_OBEC")

# interpolace do objektu venkov
st_interpolate_aw(obecni_populace["obyvatel"], # zdroj
                  venkov, # cíl
                  extensive = T) # držím součet, ne vážený průměr

