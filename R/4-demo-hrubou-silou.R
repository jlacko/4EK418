# hrubou silou spočítat optimální místo demonstrace
# definované jako střed kruhu s maximálním součtem příznivců strany

# vyjdeme z vizualizace (která sama vychází z digest data)

source("./R/4-okrsky-viz.R")

# definovat funkci šelmostroj ---

selmostroj <- function(okruh, strana) {
   
   stc_okrsky <- st_set_geometry(stc_okrsky, "stredobod") # z polygonů na středobody
   
   stc_okrsky$vysledek <- 0 # init sloupce s výsledkem
   
   for (i in seq_along(stc_okrsky$Kod)) { # tj. postupně všech 2064 okrsků
      
      # buffer kolem i-tého prvku s průměrem okruh + součet hodnot za stranu
      stc_okrsky$vysledek[i] <- stc_okrsky %>% 
         st_join(st_buffer(stc_okrsky[i, ], okruh) %>% st_geometry() %>% st_as_sf(), left = F) %>% 
         summarise_if(is.numeric, sum) %>% # sečte číselné sloupce (všechny strany)
         pull(strana) # vrátí ze všech stran jednu požadovanou
      
      # každý stý cyklus podat zprávu že se něco děje...
      if(i %% 100 == 0) message(paste(i, "hotovo,", nrow(stc_okrsky) - i, "zbývá")) 
      
   }
   
   # najde kód okrsku s největším počtem voličů v okolí
   nejvic <- stc_okrsky$Kod[which.max(stc_okrsky$vysledek)]
   
   
   nejvic # vrátí hodnotu okrsku s nejpočetnějším okolím
}

# uplatnit funkci šelmostroj ----

okoli <- 2500 # v metrech; použijeme 2x - při volání šelmostroje a kreslení grafu = jedna pravda!

# uplatněný šelmostroj vrací id okrsku, běží dlouho (čím větší okolí, tím hůř...)
demo <- selmostroj(okruh = okoli, strana = "STAN") # viz uvažuje STAN; jiné strany možné / ale graf absolutně nebude ladit...

# dohledáme adresu
adresa <- stc_okrsky %>% 
   filter(Kod == demo) %>% 
   st_set_geometry("stredobod") %>% 
   RCzechia::revgeo() %>% 
   pull(revgeocoded) # sloupec vrácený funkcí reverzního geokódování

#ukážeme na mapě / recyklace objektu absolutne
absolutne +
   geom_sf(data = st_set_geometry(filter(stc_okrsky, Kod == demo), "stredobod"),
           pch = 4, color = "red") +
   geom_sf(data = st_set_geometry(filter(stc_okrsky, Kod == demo), "stredobod") %>% st_buffer(okoli),
           color = "red", alpha = 1/2) +
   labs(title = paste("Optimální sraz pro voliče z okolí", okoli /1000, "kilometrů"),
        subtitle = adresa) +
   theme(plot.margin = unit(rep(.5, 4), "cm"))


