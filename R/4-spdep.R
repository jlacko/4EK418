# stč volby - Moranovo I & Getis-Ord 
# otázka: jsou volební výsledky po okrscích náhodné, či nikoliv?

library(spdep)

# načíst data o STČ, včetně pomocných grafických objektů ----
source("./R/4-okrsky-viz.R")


# vlastní moran
sousedi <- stc_okrsky %>% 
   poly2nb(queen = T) %>% 
   nb2listw()

moran.test(stc_okrsky$STAN, sousedi)

# plot - co je za sumárním číslem?

moran.plot(stc_okrsky$STAN, sousedi)

moran_mapa <- data.frame(localmoran(stc_okrsky$STAN, sousedi),
                         geometry = st_geometry(stc_okrsky)) %>% 
   st_as_sf() %>% 
   mutate(materialita = gtools::stars.pval(`Pr.z....E.Ii..`)) 
   

# vizuální přehled Moranova I
ggplot(data = moran_mapa) +
   geom_sf(aes(fill = Ii), color = NA) +
   geom_sf(data = st_transform(mala_voda, 4326), color = "steelblue", size = .8, alpha = .4) +
   geom_sf(data = st_transform(velka_voda, 4326), color = "steelblue", size = 1, alpha = .7) +
   geom_sf(data = st_transform(podklad, 4326), fill = NA, color = "gray40", size = .25) +
   geom_sf(data = st_transform(obrysKraje, 4326), fill = NA, color = "gray40", size = .75) +
   scale_fill_gradient2(low = scales::muted("red"),
                        mid = "white",
                        high = scales::muted("green")) +
   theme_void() +
   labs(title = "Lokální Moranovo I",
        subtitle = "kladná hodnota = okrsek je obklopen sobě podobnými") +
   theme(plot.margin = unit(rep(.5, 4), "cm"))

# Materialita lokálního Moranovo I
ggplot(data = moran_mapa) +
   geom_sf(aes(fill = materialita), color = NA, alpha = 4/5) + # 
   geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
   geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
   geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   scale_fill_brewer(type = "seq",
                     palette = 7) +
   theme_void() +
   labs(title = "Lokální Moranovo I",
        fill = "materialita\nLocal Moran") +
   theme(plot.margin = unit(rep(.5, 4), "cm"))


# Getis-Ord Gi*
gord_mapa <- data.frame(gstat = localG(stc_okrsky$STAN, sousedi) %>% as.matrix(),
                        geometry = st_geometry(stc_okrsky)) %>% 
   st_as_sf() %>% 
   mutate(pvalue = 2 * pnorm(-abs(gstat)),
          materialita = gtools::stars.pval(pvalue)) 
   

# vizuální přehled Gi*
ggplot(data = gord_mapa) +
   geom_sf(aes(fill = gstat), color = NA) + #
   geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
   geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
   geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   scale_fill_gradient2(low = scales::muted("red"),
                        mid = "white",
                        high = scales::muted("green")) +
   theme_void() +
   labs(title = "Lokální Getis-Ord",
        subtitle = "vysoká absolutní hodnota = cluster; znamínko = znamínko",
        fill = "Getis-Ord *") +
   theme(plot.margin = unit(rep(.5, 4), "cm"))


# Materialita Gi*
ggplot(data = gord_mapa) +
   geom_sf(aes(fill = materialita), color = NA, alpha = 4/5) + # 
   geom_sf(data = mala_voda, color = "steelblue", size = .8, alpha = .4) +
   geom_sf(data = velka_voda, color = "steelblue", size = 1, alpha = .7) +
   geom_sf(data = podklad, fill = NA, color = "gray40", size = .25) +
   geom_sf(data = obrysKraje, fill = NA, color = "gray40", size = .75) +
   scale_fill_brewer(type = "seq",
                     palette = 7) +
   theme_void() +
   labs(title = "Lokální Getis-Ord",
        fill = "materialita\nGetis-Ord *") +
   theme(plot.margin = unit(rep(.5, 4), "cm"))