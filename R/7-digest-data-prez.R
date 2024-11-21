# digest volební výsledky 2. kola prezidentské volby 2023
library(tidyverse)
library(sf)


# načíst výsledky, zafiltrovat na STC kraj + vysčítat do 3 stran + zbytku světa
raw_data <- read_csv2("./data/pet1.csv",
                      col_types = cols(OBEC = col_character(),
                                       OKRSEK = col_character())) %>%
  filter(OPRAVA == "0") %>% 
  mutate(OBEC = as.character(OBEC), # klíče v RCzechia jsou vždy text
         OKRSEK = as.character(OKRSEK),
         pavel = HLASY_04,
         nerudova = HLASY_06,
         babis = HLASY_07,
         zbytek = PL_HL_CELK - pavel - nerudova - babis,
         celkem = PL_HL_CELK) %>% 
  filter(KOLO == 2)

# načíst relevantní shapefile + připojit data frame výsledků
clean_data <- RCzechia::volebni_okrsky("low") %>% 
  mutate(OBEC = coalesce(MomcKod, ObecKod)) %>% # mor na ty vaše rody!!!
  rename(OKRSEK = Cislo) %>% 
  inner_join(raw_data, by = c("OBEC", "OKRSEK")) %>% 
  select(Kod, pavel, babis, nerudova, zbytek, celkem)

# už není potřeba...
rm(raw_data) # už je nepotřebujeme....
