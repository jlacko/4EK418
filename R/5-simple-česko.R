# zjednodušení polygonu / hranic ČR

library(RCzechia)
library(dplyr)
library(rmapshaper)

# hranice ČR
hranice <- republika()

# vizuální kontrola
plot(st_geometry(hranice))

# zjednodušení / Fukov must go!
simple_hranice <- rmapshaper::ms_simplify(hranice,
                                          keep = 1/10,
                                          keep_shapes = T) # zachovat všechny části

# vizuální kontrola
plot(st_geometry(simple_hranice))

# početní kontrola / počet bodů v polygonu
length(st_cast(st_geometry(hranice), "POINT"))
length(st_cast(st_geometry(simple_hranice), "POINT"))

# poměr bodů vymezující polygon původních a jednoduchých hranic
length(st_cast(st_geometry(hranice), "POINT")) /
   length(st_cast(st_geometry(simple_hranice), "POINT"))
