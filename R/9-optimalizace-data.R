# optimalizace sítě pražských hospod
# krok 2 - obohacení mřížky daty


# obyvatelé pražských částí (opakování :)

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
   geom_sf(data = prazske_pocty, aes(fill = obyvatel))

# interpolace obyvatel přes plochu městských částí do gridu
grid$obyvatel <- st_interpolate_aw(x = prazske_pocty["obyvatel"],
                                to = st_geometry(grid),
                                extensive = T) %>% 
   pull(obyvatel)

# vizuální kontrola
ggplot() +
   geom_sf(data = grid, aes(fill = obyvatel))

# hotelová lůžka
luzka <- readr::read_csv('./data/CRU02_2012_2017.csv') %>%
   filter(rok == 2017 
          & uzemi_kod %in% casti$KOD
          & stapro_kod == 2658 # hotelová lůžka
          & !is.na(hodnota)) %>%
   group_by(uzemi_kod, uzemi_txt) %>%
   summarise(kapacita = sum(hodnota))

prazska_luzka <- left_join(casti, luzka, by = c("KOD" = "uzemi_kod")) %>% 
   mutate(kapacita = coalesce(kapacita, 0))

# vizuální kontrola
ggplot() +
  geom_sf(data = prazska_luzka, aes(fill = kapacita))

# interpolace lůžek přes plochu městskáých částí do gridu
grid$luzka <- st_interpolate_aw(x = prazska_luzka["kapacita"],
                                to = st_geometry(grid),
                                extensive = T) %>% 
   pull(kapacita)

# vizuální kontrola
ggplot() +
  geom_sf(data = grid, aes(fill = luzka))


# vegetace jako raster
red <- rast("./data/red_prg-2018-06-30.tif") # červený kanál
nir <- rast("./data/nir_prg-2018-06-30.tif") # near infrared kanál

ndvi <- (nir - red) / (nir + red) # standardní index

# vizuální kontrola / ggplot nemá rád rastry!
plot(ndvi) # base R plot / metoda z {terra}

# vlastní nápočet
grid$vegetation <- exactextractr::exact_extract(
   x = ndvi, # zdrojový rastr
   y = grid, # cílové polygony
   fun = "mean" # transformační funkce (normalizuje nestejné plochy)
   ) 

# vizuální kontrola
ggplot() + # plot vegetation index
   geom_sf(data = grid, aes(fill = vegetation), color = 'gray66', lwd = .5) +
   geom_sf(data = reky("Praha"), color = "steelblue", lwd = 1.25, alpha = .5) +
   scale_fill_gradientn(colors = rev(terrain.colors(7)),
                        limits = c(0, 1),
                        name = 'NDVI (avg.)') +
   geom_sf(data = obrys, fill = NA, color = 'gray75', lwd = 1, alpha = 0.6)