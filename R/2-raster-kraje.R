library(terra) # jinak konflikt s dplyr...
library(dplyr)
library(ggplot2)

# zastavěná střední Evropa z Copernicusu - https://lcviewer.vito.be
cesta <- "https://s3-eu-west-1.amazonaws.com/vito.landcover.global/v3.0.1/2019/E000N60/E000N60_PROBAV_LC100_global_v3.0.1_2019-nrt_BuiltUp-CoverFraction-layer_EPSG-4326.tif"
           
# cílový soubor včetně cesty (z důvodu velikosti není v gitu)
stazeny_rastr <- "./data/builtup_2019.tif"

# stažení právě jednou = pokud soubor existuje, download se přeskočí; pokud ne tak se stahne do /data
if(!file.exists(stazeny_rastr)) curl::curl_download(url = cesta, destfile = stazeny_rastr)

rok_2019 <- rast(stazeny_rastr)

# statický náhled / base plot
plot(rok_2019)

cesko <- rok_2019 %>% # vezmu raster...
  crop(RCzechia::republika()) %>%  # oříznu (nahrubo kolem republiky)
  mask(RCzechia::republika()) # vymaskuju sousední státy

# dynamický náhled / {mapview}
mapview::mapview(cesko, maxBytes = 5 * 1024^2)

# pomocný objekt / kraje
kraje <- RCzechia::kraje()

# přenos hodnoty z rasterového na vektorový objekt
kraje$zastavenost <- exactextractr::exact_extract(
  x = rok_2019, # zdrojový rastr
  y = kraje, # cílové polygony
  fun = "mean" # transformační funkce (normalizuje nestejné plochy)
) 

# náhled na transformované hodnoty
ggplot(data = kraje, aes(fill = zastavenost, label = signif(zastavenost, 2))) +
  geom_sf(lwd = 1/3) +
  scale_fill_viridis_c(name = "zastavěná plocha\n(v % z celkové)") +
  geom_sf_text(color = ifelse(kraje$KOD_CZNUTS3 == "CZ010", "#440154FF", "white")) +
  labs(title = "Zastavěnost krajů ČR v roce 2019",
       caption = "© Copernicus Service Information 2019") +
  theme(axis.title = element_blank(),
        legend.title.align = 1/2,
        plot.caption = element_text(face = "italic"))