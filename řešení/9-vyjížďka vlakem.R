# vyjížďka do školy či práce v ČR vlakem
# pro zjednodušení abstrahujme od toho, že populace ORP není srovnatelná (Praha vs. Králíky...)

library(sf)      # prostorová data jako základ
library(dplyr)   # datová manipulace
library(ggplot2) # kreslení
library(spdep)   # prostorová statistika

# vyjížďka do školy či práce vlakem - jako absolutní číslo a jako podíl z vyjížděk
train_commute <- readr::read_csv("data/sldb2021_vyjizdka_vsichni_prostredek_pohlavi.csv",
                            locale = readr::locale(decimal_mark = ",",
                                                   grouping_mark = " ")) %>% 
  filter(uzemi_cis == 65 & is.na(pohlavi_txt)) %>% 
  group_by(uzemi_kod) %>% 
  mutate(podil = hodnota / sum(hodnota)) %>% # vyjížďka typu x jako podíl všech vyjížděk v obci
  ungroup() %>% 
  filter(prostredek_txt == "Vlak" ) %>% # jen vlak!
  mutate(uzemi_kod = as.character(uzemi_kod)) %>% # klíče v RCzechia jsou stringy, ne čísla
  select(uzemi_kod, uzemi_txt, podil, hodnota)

orpecka <- RCzechia::orp_polygony() %>% 
  left_join(train_commute, by = c("KOD_ORP" = "uzemi_kod"))


# 1) zakreslit vyjížďku do školy či práce vlakem jako kartogram (= choropleth)

plot(orpecka["podil"])

# 2) je vyjížďka náhodně rozložena v ČR jako celku (= globální test)

vahy <- orpecka %>% 
  poly2nb() %>% 
  nb2listw()

moran.test(orpecka$podil, vahy)

# 3) jsou v ČR oblasti, kde se jezdí vlakem víc a kde méně? (= lokální test / LISA clusters)

lokalni_moran <- localmoran(orpecka$podil, vahy) %>% 
  data.frame() 

orpecka$zscore <- lokalni_moran$Z.Ii

plot(orpecka["zscore"])

# rozšířený pohled: vyhodnocení materiality z-score přes kvantil normálního rozdělení
# + identifikace "zajímavých" clusterů
zajimava_orp <- orpecka %>% 
  # spočíst zajímavost přes kvantily / oba "ocásky"
  mutate(zajimave = ifelse(zscore < qnorm(.05) | zscore > qnorm(.95), T, F)) %>% 
  filter(zajimave) %>% # vybrat jen zajímavé
  summarise() # sloučit do jednoho celku

plot(st_geometry(orpecka), border = "gray75")
plot(zajimava_orp, col = "red", add = T)