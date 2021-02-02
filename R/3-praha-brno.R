library(RCzechia)
library(dplyr)
library(sf)

hranice <- republika("low") 

mesta <- obce_body() %>% 
   filter(NAZ_OBEC %in% c("Praha", "Brno")) 

okoli <- mesta %>% 
   st_transform(5514) %>% # Křovák, protože metry
   st_buffer(125000) %>% # 125 kilometrů kolem obou měst
   st_transform(4326) # WGS84 kamarádí s IT světem

# výpočet průsečíku okolí Brna a Prahy
spolecne <- st_intersection(okoli[1, ],
                            okoli[2, ])

# vizuální přehled
mapview::mapview(spolecne)

# republika bez okolí Prahy
rozdily <- st_difference(hranice,
                         okoli[2, ])

# vizuální přehled
mapview::mapview(rozdily)