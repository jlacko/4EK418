# vysvětlení 

source("./R/4-digest-data-prez.R") 

clean_data <- clean_data %>% 
  st_transform(5514) # ve světě ing. Křováka je výpočet svižnější

# 330 soudních okresů První republiky jako geojson
census <- st_read("./data/1930_census.gpkg") 

# přenést aktuální volební výsledky na historická data
census$babis <- st_interpolate_aw(x = clean_data["babis"],
                                  to = st_geometry(census),
                                  extensive = T) %>% 
  pull(babis)

census$celkem <- st_interpolate_aw(x = clean_data["celkem"],
                                   to = st_geometry(census),
                                   extensive = T) %>% 
  pull(celkem)

# spočítat regresi / podíl Babiše odvislý od podílu Německé národnosti
podklad_regrese <- census %>% 
  mutate(pct_babis = babis / celkem,
         pct_nemci = o_nar_nem / o_po) %>% 
  st_drop_geometry() 

# podat zprávu...
lm(data = podklad_regrese, pct_babis ~ pct_nemci) %>% 
  summary()
