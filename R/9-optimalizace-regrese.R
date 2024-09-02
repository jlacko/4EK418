# optimalizace sítě pražských hospod
# krok 3 - vlastní výpočet

# baseline - jediná nezávislá veličina (populace)
bl_model <- lm(data = grid, barcount ~ obyvatel)

summary(bl_model)

# interpretace: 1 hospodu uživí
1 / bl_model$coefficients["obyvatel"]

# sofistikovanějíší model - dvě veličiny (místňáci + lufťáci)
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

# rozpracujme toho poissona trochu více! :)
library(DHARMa)
library(glmmTMB)

sim_poi <- simulateResiduals(fittedModel = poi_model, n = 10000)
testDispersion(sim_poi)
testZeroInflation(sim_poi)

## Zero-inflated negative binomial model
zinb_model <- glmmTMB(formula = barcount ~ obyvatel + luzka + vegetation,
                      zi= ~ obyvatel + luzka + vegetation,
                      family = nbinom2, data = grid)

summary(zinb_model)

sim_zinb <- simulateResiduals(fittedModel = zinb_model, n = 10000)
testDispersion(sim_zinb)
testZeroInflation(sim_zinb)

# srovnání modelů / poučení z krizového vývoje...
AIC(bl_model)
AIC(sof_model)
AIC(jsof_model)
AIC(poi_model)
AIC(zinb_model)

# příprava dat pro graf -----
resids <- residuals(jsof_model) # extract residuals from model
predikce <- fitted(jsof_model) # předpovědi z modelu

leaf_src <- grid %>% # ... attach them to grid
   cbind(resids) %>% 
   cbind(predikce)

# podat o všem zprávu (leafletem :) ----
library(leaflet)
library(htmltools)

# diverging palette - green is good, red is bad
pal <- colorBin(palette = "RdYlGn",  domain = leaf_src$resids,  bins = 5,  reverse = T)

leaf_src <- leaf_src %>% # create a HTML formatted popup label of grid cell
   mutate(label = paste0('Predikce ', round(predikce),' hospod, <br>',
                         'skutečnost ', barcount, ', ', 'rozdíl <b>',
                         ifelse(resids > 0, '+', '-'), abs(round(resids)), '</b>.'))

leaflet() %>%
   addProviderTiles(providers$CartoDB.Positron) %>%
   setView(lng = 14.46, lat = 50.07, zoom = 10) %>%
   addPolygons(data = leaf_src, 
               fillColor = ~pal(resids),
               fillOpacity = 0.5,
               stroke = F, 
               popup = ~label) 
