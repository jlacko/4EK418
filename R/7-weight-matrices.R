library(spdep)
library(dplyr)
library(sf)
library(ggplot2)

# podklad okresů - společný všude
okresy <- RCzechia::okresy("low") %>% 
  st_transform(5514)

# obecná jednořádková vizualizační fce; očekává vstup ve formátu listw
celek <- function(sousedi) {
  
  plot(st_geometry(RCzechia::republika()) %>% st_transform(5514))
  plot(sousedi, st_geometry(okresy), col = "gray75", pch = 19, add = T)
   
}


detail <- function(sousedi) {
  
 chart_source <-  okresy %>%  
   # zafiltruje okresy na ty, které jsou sousedy města Brna v objektu sousedi
   slice(purrr::pluck(sousedi$neighbours, which(okresy$KOD_LAU1 == "CZ0642"))) %>%
   # doplní sloupec s vahou sousedství vůči městu Brnu
   mutate(vaha = purrr::pluck(sousedi$weights, which(okresy$KOD_LAU1 == "CZ0642"))) 
 
  ggplot(data = chart_source) +
    geom_sf() +
    geom_sf_label(aes(label = scales::percent(vaha, accuracy = 1))) +
    geom_sf(data = st_centroid(okresy[which(okresy$KOD_LAU1 == "CZ0642"), ]),
            color= "red",
            pch = 4) +
    theme_void()
  
}

# metoda královna - stačí 1 bod; očekává polygony

queen_hoods <- st_geometry(okresy) %>% 
  poly2nb(queen = T) %>% # queen váhy
  nb2listw(zero.policy = T) 

# vizualizace celku
celek(queen_hoods)
detail(queen_hoods)

# metoda věž - potřebuju 2 sousední body (1 je málo); očekává polygony

rook_hoods <- st_geometry(okresy) %>% 
  poly2nb(queen = F) %>% # rook weights / není queen
  nb2listw(zero.policy = T) 

celek(rook_hoods)
detail(rook_hoods)

# metoda nejbližší sousedé / pozor na parametr "kolik sousedů"; očekává body

knn_hoods <- st_geometry(okresy) %>% 
  st_centroid() %>% 
  knearneigh(k = 3) %>% # tři nejblizší body (vždy 3)
  knn2nb() %>% 
  nb2listw(zero.policy = T) 

celek(knn_hoods)
detail(knn_hoods)

# metoda sousedé vymezeni vzdáleností / pozor na parametry "od" a "do"; očekává body

distance_hoods <- st_geometry(okresy) %>% 
  st_centroid() %>%
  dnearneigh(d1 = 0, d2 = 50000) %>% # vzdálenost nula až 50 Km
  nb2listw(zero.policy = T) 

celek(distance_hoods)
detail(distance_hoods)

# technika úpravy vah / platí nezávisle na technice určení sousedství

# vstup = seznam sousedství; nemusí být nutně podle vzdáleností
nblist <- st_geometry(okresy) %>% 
  st_centroid() %>%
  dnearneigh(d1 = 0, d2 = 50) # vzdálenost nula až 50
  
idw_hoods <- nb2listw(nblist,
                      zero.policy = T)

# váhy jsou standardní součást listw objektu, ale já si jí přepíšu vlastní hodnotou (muhehe...)
idw_hoods$weights <- nbdists(nblist, st_coordinates(st_centroid(okresy))) %>% 
  lapply(function(x) 1/x)  %>% # převrácená hodnota vzdáleností
  lapply(function(x) x/sum(x)) # standardizovat matici na řádkový součet 1


detail(idw_hoods)

# alternativa - převážení královny podle pana Newtona

nblist <- st_geometry(okresy) %>%  
  poly2nb(queen = T) # seznam queen sousedství polygonů okresů

idwq_hoods <- nb2listw(nblist,
                       zero.policy = T)

# váhy jsou standardní součást, ale přepíšu jí novou hodnotou
idwq_hoods$weights <- nbdists(nblist, st_coordinates(st_centroid(okresy))) %>% 
  lapply(function(x) 1/(x^2)) %>%  # převrácená hodnota *druhé mocniny* vzdálenosti - jako gravitace...
  lapply(function(x) x/sum(x)) # standardizovat matici na řádkový součet 1

detail(idwq_hoods)


# technika úpravy vah poměrem délky společné hranice

# vstup - královna pro společnou hranici
nblist <- st_geometry(okresy) %>% 
  poly2nb(queen = TRUE) 

borderline_hoods <- nb2listw(nblist)

# předpřipravit objekt vzdáleností o stejné délce jako sousedi
distances <- vector("list", length(nblist))

# iterace pomocí i přes všechny vzdálenosti
for (i in seq_along(distances)) {
  
  # indexy sousedů i-tého prvku
  neighbor_ids <- purrr::pluck(nblist[[i]])
  
  # sdílená hranice obecně mnoha sousedů s i-tým prvkem jako čára
  distances[[i]] <- st_intersection(st_geometry(okresy)[neighbor_ids],
                                    st_geometry(okresy)[i],
                                    model = "closed") %>% # pozor na mršku s2!!!
    st_length() %>% # z čáry jako geometrie na délku čáry
    units::drop_units() # chceme bezrozměrné číslo / pracujeme s podílem
  
}

# standardizace do stylu W / součet řádku = 1
distances <- lapply(distances, function(x) x/sum(x)) 

# přepsat původní váhy upravenými  
borderline_hoods$weights <- distances 

zprava(borderline_hoods)
