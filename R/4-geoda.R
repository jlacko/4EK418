# aplikuje geoda na středočeské volební výsledky
 
library(rgeoda)  # remotes::install_github("lixun910/rgeoda")
library(leaflet) # protože leaflet

source("./R/4-digest-data-STČ.R")

stc_okrsky <- stc_okrsky %>% 
   rmapshaper::ms_simplify(keep = 1/3)

queen_w <- queen_weights(stc_okrsky)

lisa <- local_moran(queen_w, stc_okrsky["STAN"] / stc_okrsky["celkem"])

stc_okrsky$cluster <- as.factor(lisa$GetClusterIndicators())
levels(stc_okrsky$cluster) <- lisa$GetLabels()

plot(stc_okrsky["cluster"])

# definice palety pro kreslení leafletu
palPwr <- colorFactor(palette = c("Not significant" = "gray", 
                                  "High-High" = "red", 
                                  "Low-Low" = "green",
                                  "High-Low" = "blue",
                                  "Low-High" = "yellow"),
                      domain = stc_okrsky$cluster)


# protože interaktivita je víc, jak 1000 slov...
listek <- leaflet(data = stc_okrsky) %>% 
   addProviderTiles("CartoDB.Positron") %>% 
   addPolygons(stroke = F,
               fillOpacity = .5,
               fillColor = palPwr(stc_okrsky$cluster)) %>% 
   addLegend(position = "bottomright",
             values = ~cluster,
             pal = palPwr,
             opacity = .5,
             title = "cluster")


listek

# kdybych chtěl uložit...
# htmlwidgets::saveWidget(listek, "listek.html")