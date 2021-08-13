# digest volební výsledky středočeský kraj za krajské volby 2020
library(tidyverse)
library(sf)

# středočeské obce jako vektor
stredni_cechy <- RCzechia::obce_body() %>% 
   filter(KOD_CZNUTS3 == "CZ020") %>% 
   pull(KOD_OBEC) %>% 
   as.numeric()
   
# načíst výsledky, zafiltrovat na STC kraj + vysčítat do 3 stran + zbytku světa
stc_vysledky <- read_csv2("./data/kzt6p.csv") %>% 
   filter(OBEC %in% stredni_cechy) %>% 
   mutate(ObecKod = as.character(OBEC), # klíče v RCzechia jsou vždy text
          Cislo = as.character(OKRSEK),
          strana = case_when(KSTRANA == 7 ~ "STAN",
                             KSTRANA == 50 ~ "ANO",
                             KSTRANA == 33 ~ "ODS",
                             TRUE ~ "zbytek")) %>% 
   group_by(ObecKod, Cislo, strana) %>% 
   summarise(hlasu = sum(POC_HLASU)) %>% 
   pivot_wider(names_from = strana, values_from = hlasu, values_fill = 0) %>% 
   mutate(celkem = STAN + ANO + ODS + zbytek)

# načíst relevantní shapefile + připojit data frame výsledků
stc_okrsky <- RCzechia::volebni_okrsky() %>% 
   inner_join(stc_vysledky, by = c("ObecKod", "Cislo")) %>% 
   select(Kod, ANO, ODS, STAN, zbytek, celkem)

# už není potřeba...
rm(stc_vysledky) # už je nepotřebujeme....
