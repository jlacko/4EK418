# Máte dva censy: 1980 a 1930, padesát let od sebe
# posuďte závislost podílu obyvatel věkové kategorie 65+ v roce 1980
# - na podílu obyvatel 65+ v roce 1930 / hypotéza "zdravý kraj"
# - na podílu obyvatel německé národnosti v roce 1930 / hypotéza "Postupim"
# výběr zdůvodněte :)


library(RCzechia)
library(ggplot2)
library(dplyr)

# census 1980
okresy_1980 <- RCzechia::historie("okresy_1980") %>% 
  mutate(duchodci_80 = `obyvatelstvo celkem 65+`,
         obyvatele_80 = `počet obyvatel přítomných`) %>% 
  st_transform(5514)

ggplot(data = okresy_1980) +
  geom_sf(aes(fill = duchodci_80 / obyvatele_80)) +
  labs(title = "Důchodci v roce 1980") +
  scale_fill_viridis_c("podíl z celku") +
  theme_void() +
  theme(legend.position="bottom")
  

# census 1930
okresy_1930 <- RCzechia::historie("okresy_1930") %>% 
  mutate(nemci_30 = `národnost německá`,
         obyvatele_30 = `počet obyvatel přítomných`,
         duchodci_30 = `obyvatelstvo celkem věk 65+`) %>% 
  st_transform(5514)

ggplot(data = okresy_1930) +
  geom_sf(aes(fill = duchodci_30 / obyvatele_30)) +
  labs(title = "Důchodci v roce 1930") +
  scale_fill_viridis_c("podíl z celku") +
  theme_void() +
  theme(legend.position="bottom")

ggplot(data = okresy_1930) +
  geom_sf(aes(fill = nemci_30 / obyvatele_30)) +
  labs(title = "Němci v roce 1930") +
  scale_fill_viridis_c("podíl z celku") +
  theme_void() +
  theme(legend.position="bottom")

# pro přenos metrik uvažujte sf::st_interpolate_aw()

okresy_1930$duchodci_80 <- st_interpolate_aw(okresy_1980["duchodci_80"],
                                             st_geometry(okresy_1930),
                                             extensive = T)$duchodci_80

# numerická kontrola součtů
sum(okresy_1930$duchodci_80)
sum(okresy_1980$duchodci_80)
 
okresy_1930$obyvatele_80 <- st_interpolate_aw(okresy_1980["obyvatele_80"],
                                             st_geometry(okresy_1930),
                                             extensive = T)$obyvatele_80

# numerická kontrola součtů
sum(okresy_1930$obyvatele_80)
sum(okresy_1980$obyvatele_80)

# podklad regrese
reg_src <- okresy_1930 %>% 
  mutate(pod_duch_30 = duchodci_30 / obyvatele_30,
         pod_duch_80 = duchodci_80 / obyvatele_80,
         pod_nemcu = nemci_30 / obyvatele_30) 

# vlastní akce!
model_ovzdzusi <- lm(data = reg_src,
                     formula = pod_duch_80 ~ pod_duch_30)

model_postupim <- lm(data = reg_src,
                     formula = pod_duch_80 ~ pod_nemcu)

# který z modelů mám radši?
summary(model_ovzdzusi)["r.squared"]
summary(model_postupim)["r.squared"]