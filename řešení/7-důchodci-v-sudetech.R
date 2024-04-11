# Máte dva censy: 1980 a 1930, padesát let od sebe
# posuďte závislost podílu obyvatel věkové kategorie 75+ v roce 1980
# na podílu obyvatelstva německé národnosti v roce 1930
# zkuste vysvětlit :)


library(RCzechia)
library(dplyr)

# census 1980
okresy_1980 <- RCzechia::historie("okresy_1980") %>% 
  mutate(metrika_vysvetlovana = `obyvatelstvo celkem věk 75+` / `počet obyvatel přítomných`) %>% 
  select(metrika_vysvetlovana)

plot(okresy_1980["metrika_vysvetlovana"])


# census 1930
okresy_1930 <- RCzechia::historie("okresy_1930") %>% 
  mutate(metrika_vysvetlujici = `národnost německá` / `počet obyvatel přítomných`) %>% 
  select(metrika_vysvetlujici)

plot(okresy_1930["metrika_vysvetlujici"])

# pro přenos metrik uvažujte sf::st_interpolate_aw(); věnujte pozornost argumentu extensive

okresy_1980$metrika_vysvetlujici <- st_interpolate_aw(
  x = okresy_1930["metrika_vysvetlujici"],
  to = st_geometry(okresy_1980),
  extensive = F) %>% 
  pull(metrika_vysvetlujici)

model_jednoduchy <- lm(data = okresy_1980, metrika_vysvetlovana ~ metrika_vysvetlujici)

summary(model_jednoduchy)