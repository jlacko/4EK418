# úkol volí malé obce stejně jako velké?

library(tidyverse)
library(sf)

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


clean_data <- RCzechia::volebni_okrsky("low") %>% 
  mutate(OBEC = coalesce(MomcKod, ObecKod)) %>% # mor na ty vaše rody!!!
  rename(OKRSEK = Cislo) %>% 
  inner_join(raw_data, by = c("OBEC", "OKRSEK")) %>% 
  group_by(OBEC) %>%  # tj. okres
  summarize(pct_babis = sum(babis, na.rm = T) / sum(celkem),
            celkem = sum(celkem)) 

rm(raw_data) # už nejsou potřeba...

# úkol no. 1 - závisí podíl hlasů pro AB na počtu hlasů v obci?

model_ab <- lm(data = clean_data, formula = pct_babis ~ celkem)

summary(model_ab)

# úkol no. 2 - jak vypadají rezidua? obrázek v mapě

clean_data$rezidua <- model_ab$residuals

plot(clean_data["rezidua"])

# úkol no. 3 - jsou splněny podmínky OLS?

library(spdep)

sousedi <- poly2nb(clean_data) %>% 
  nb2listw()

moran.test(clean_data$rezidua, listw = sousedi)

