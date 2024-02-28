# optimalizace sítě pražských hospod
# krok 3 - vlastní výpočet

# baseline - jediná nezávislá veličina (populace)
bl_model <- lm(data = grid, barcount ~ obyvatel)

summary(bl_model)

# interpretace: 1 hospodu uživí
1 / bl_model$coefficients["obyvatel"]

# sofistikovanějíší model - dvě veličiny (místňáck + lufťáci)
sof_model <- lm(data = grid, barcount ~ obyvatel + luzka)

summary(sof_model)

# interpretace: 1 hospodu uživí
1 / sof_model$coefficients["obyvatel"]
1 / sof_model$coefficients["luzka"]

# ještě sofistikovanějíší model - tři veličiny (místňáci, lufťáci, parky)
jsof_model <- lm(data = grid, barcount ~ obyvatel + luzka + vegetation)

summary(jsof_model)

# poissonův model - co takhle zkusit něco jiného??
poi_model <- glm(data = grid, barcount ~ obyvatel + luzka + vegetation, 
                 family = "poisson")

summary(poi_model)

# srovnání modelů
AIC(bl_model)
AIC(sof_model)
AIC(jsof_model)
AIC(poi_model)

# příprava dat pro graf -----
resids <- jsof_model$residuals # extract residuals from model
predikce <- jsof_model$fitted.values # předpovědi z modelu

grid <- grid %>% # ... attach them to grid
   cbind(resids) %>% 
   cbind(predikce)

# podat o všem zprávu (leafletem :) ----
library(leaflet)
library(htmltools)

# diverging palette - green is good, red is bad
pal <- colorBin(palette = "RdYlGn",  domain = grid$resids,  bins = 5,  reverse = T)

grid <- grid %>% # create a HTML formatted popup label of grid cell
   mutate(label = paste0('Predikce ', round(predikce),' hospod, <br>',
                         'skutečnost ', barcount, ', ', 'rozdíl <b>',
                         ifelse(resids > 0, '+', '-'), abs(round(resids)), '</b>.'))

leaflet() %>%
   addProviderTiles(providers$CartoDB.Positron) %>%
   setView(lng = 14.46, lat = 50.07, zoom = 10) %>%
   addPolygons(data = grid, 
               fillColor = ~pal(resids),
               fillOpacity = 0.5,
               stroke = F, 
               popup = ~label) 
