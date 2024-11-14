# Máte dva censy: 1980 a 1930, padesát let od sebe
# posuďte závislost podílu obyvatel věkové kategorie 65+ v roce 1980
# - na podílu obyvatel 65+ v roce 1930 / hypotéza "zdravý kraj"
# - na podílu obyvatel německé národnosti v roce 1930 / hypotéza "Postupim"
# výběr zdůvodněte :)


library(RCzechia)
library(dplyr)

# census 1980
okresy_1980 <- RCzechia::historie("okresy_1980") %>% 
  mutate(duchodci_80 = `obyvatelstvo celkem 65+` / `počet obyvatel přítomných`) %>% 
  select(duchodci_80) %>% 
  st_transform(5514)

plot(okresy_1980["duchodci_80"])


# census 1930
okresy_1930 <- RCzechia::historie("okresy_1930") %>% 
  mutate(nemci_30 = `národnost německá` / `počet obyvatel přítomných`,
         duchodci_30 = `obyvatelstvo celkem věk 65+` / `počet obyvatel přítomných` ) %>% 
  select(nemci_30, duchodci_30) %>% 
  st_transform(5514)

plot(okresy_1930[c("nemci_30", "duchodci_30")])


# pro přenos metrik uvažujte sf::st_interpolate_aw(); věnujte pozornost argumentu extensive

okresy_1930$duchodci_80 <- st_interpolate_aw(okresy_1980["duchodci_80"],
                                             st_geometry(okresy_1930),
                                             extensive = F) %>% 
  pull(duchodci_80)

model_zdrave_ovzdusi <- lm(data = okresy_1930,
                           formula = duchodci_80 ~ duchodci_30)

model_postupim <- lm(data = okresy_1930,
                     formula = duchodci_80 ~ nemci_30)

summary(model_zdrave_ovzdusi)
summary(model_postupim)

summary(model_zdrave_ovzdusi)['r.squared']
summary(model_postupim)['r.squared']