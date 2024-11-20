# vysvětlení 

source("./R/7-digest-data-prez.R") 

clean_data <- clean_data %>% 
  st_transform(5514) # ve světě ing. Křováka je výpočet svižnější

# 330 soudních okresů První republiky jako geojson
census <- RCzechia::historie("okresy_1930") %>% 
  select(nemci = 47,
         vsichni = `počet obyvatel přítomných`) %>% 
  st_transform(5514)

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
         pct_nemci = nemci / vsichni) %>% 
  st_drop_geometry() 

# podat zprávu...
model_babis_nemci <- lm(data = podklad_regrese, pct_babis ~ pct_nemci)

summary(model_babis_nemci)

census$rezidua <- model_babis_nemci$residuals

plot(census["rezidua"])

library(spdep)

vahy <- census %>% 
  poly2nb(queen = F) %>% 
  nb2listw(zero.policy = T)

moran.test(census$rezidua, listw = vahy, alternative = "two.sided")