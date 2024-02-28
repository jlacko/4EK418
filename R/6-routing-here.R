# techniky práce s HERE API

library(hereR)
library(dplyr)
library(sf)

hereR::set_key(Sys.getenv("HERE_API_KEY")) # sem dáte vlastní :)

lokalita <- c("Úřad vlády České republiky, nábřeží Edvarda Beneše 4, Praha 1",
              "Soudní 1, Praha 4") %>% 
   iconv(to = "UTF-8") # HERE API striktně vyžaduje UTF-8 (CP-1250 nerozumí) 

# geokódování metodou HERE
mista <- hereR::geocode(lokalita)

View(mista)

# vizuální kontrola
mapview::mapview(mista, label = "address")


#cesta pěšky
pesky <- hereR::route(origin = mista[1, ],
                      destination = mista[2, ],
                      transport_mode = "pedestrian")

pesky # pozor na Z rozměr (nadmořskou výšku)

mapview::mapview(sf::st_zm(pesky))

#cesta autem
autem <- hereR::route(origin = mista[1, ],
                      destination = mista[2, ],
                      transport_mode = "car")

autem # pozor na Z rozměr (nadmořskou výšku)

# vizuální kontrola
mapview::mapview(sf::st_zm(autem))
