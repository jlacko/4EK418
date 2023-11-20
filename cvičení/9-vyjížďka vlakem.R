# vyjížďka do školy či práce v ČR vlakem
# pro zjednodušení abstrahujme od toho, že populace ORP není srovnatelná (Praha vs. Králíky...)

library(sf)      # prostorová data jako základ
library(dplyr)   # datová manipulace
library(ggplot2) # kreslení
library(spdep)   # prostorová statistika

# vyjížďka do školy či práce vlakem
train_commute <- readr::read_csv("data/sldb2021_vyjizdka_vsichni_prostredek_pohlavi.csv",
                            locale = readr::locale(decimal_mark = ",",
                                                   grouping_mark = " ")) %>% 
  filter(uzemi_cis == 65 & prostredek_txt == "Vlak" & is.na(pohlavi_txt)) %>% 
  mutate(uzemi_kod = as.character(uzemi_kod)) # klíče v RCzechia jsou stringy, ne čísla

orpecka <- RCzechia::orp_polygony() %>% 
  left_join(train_commute, by = c("KOD_ORP" = "uzemi_kod"))


# 1) zakreslit vyjížďku do školy či práce vlakem jako kartogram (= choropleth)

# 2) je vyjížďka náhodně rozložena v ČR jako celku (= globální test)

# 3) jsou v ČR oblasti, kde se jezdí vlakem víc a kde méně? (= lokální test / LISA clusters)

