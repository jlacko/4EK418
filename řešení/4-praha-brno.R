# úkol = procvičit vzdálenost a plochu v kontextu různých CRS

library(sf)
library(dplyr)

# uvažujte objekt dvou českých měst; v jakém je souřadnicovém systému?
mesta <- RCzechia::obce_polygony() %>% 
   filter(NAZ_OBEC %in% c("Praha", "Brno")) %>% 
   arrange(NAZ_OBEC)

# spočtěte vzdálenost mezi prvním a druhým prvkem objektu mesta
st_distance(x = mesta[1,],
            y = mesta[2 ])

# založte nový objekt, v souřadnicovém systému inž. Křováka (EPSG::5514)
mesta_krovak <- st_transform(mesta,
                             crs = 5514)

# spočtěte vzdálenost mezi prvním a druhým objektu mesta_krovak
st_distance(mesta_krovak[1, ],
            mesta_krovak[2, ])

# založte třetí objekt, v souřadnicovém systému Web Mercator (EPSG:3857)
mesta_mercator <- st_transform(mesta, 3857)

# spočtěte vzdálenost mezi prvním a druhým objektu mesta_mercator
st_distance(mesta_mercator[1, ],
            mesta_mercator[2, ])

# založe čtvrtý objekt, v souřadnicovém systému Washington State North (EPSG:2285)
# pozn: hranice mezi USA a Kanadou probíhá na 49 rovnoběžce (mezi Břeclaví a Brnem)
mesta_usa <- st_transform(mesta, 2285)

# spočtěte vzdálenost mezi prvním a druhým objektu mesta_usa
st_distance(mesta_usa[1,],
            mesta_usa[2, ]) %>% 
  units::set_units("km")

# za bonusové body: uplatněte na feetový výsledek units::set_units() do kilometrů
# a porovnejte se vzdáleností podle Křováka :)


