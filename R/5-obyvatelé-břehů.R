# úkol: spočítat obyvatele levobřežní a pravobřežní Prahy
# když znám hodnoty pro 57 městských částí / 11 z nich jde přes Vltavu

library(RCzechia)
library(ggplot2)
library(dplyr)
library(czso)
library(sf)
library(lwgeom)

# polygon Praha
praha <- kraje() %>% 
   filter(KOD_CZNUTS3 == "CZ010") 

# řeka Vltava
reka <- reky("Praha")

# Praha říznutá na půlky
pulky <- praha %>% 
   st_geometry() %>% 
   lwgeom::st_split(reka) %>% # polygon říznutý čárou
   st_cast() %>%  # z geometrycollection na polygony
   st_as_sf() %>%  # z sfc na sf objekt
   mutate(breh = c("pravy", "levy")) # idčka polygonů

# vizuální kontrola
ggplot() +
   geom_sf(data = pulky, aes(fill = breh))

# prostorová data pražských částí
casti <- RCzechia::casti() %>% 
   filter(NAZ_OBEC == "Praha")

# datová část = výsledky Sčítání lidu 2010
# struktura tabulky = https:/www.czso.cz/documents/10180/25233177/sldb2011_vou.xls
pocty <- czso::czso_get_table("SLDB-VYBER") %>% 
   filter(uzcis == "44") %>% # městské části
   select(uzkod, obyvatel = vse1111) %>% 
   mutate(obyvatel = as.numeric(obyvatel)) 

# propojení prostoru a dat
prazske_pocty <- inner_join(casti, pocty, by = c("KOD" = "uzkod")) 

# vizuální kontrola
ggplot() +
   geom_sf(data = prazske_pocty, aes(fill = obyvatel)) +
   geom_sf(data = reka, color = "red")

# interpolace obyvatel přes plochu městskáých částí
prusecik <- st_interpolate_aw(x = prazske_pocty["obyvatel"],
                              to = st_geometry(pulky),
                              extensive = T)

# výsledek:
prusecik

# vizuální kontrola podruhé
ggplot() +
   geom_sf(data = prusecik, aes(fill = obyvatel))

# početní kontrola
sum(prazske_pocty$obyvatel) 
sum(prusecik$obyvatel)

sum(prazske_pocty$obyvatel) / sum(prusecik$obyvatel) -1



