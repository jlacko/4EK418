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
  select(duchodci_80)

plot(okresy_1980["duchodci_80"])


# census 1930
okresy_1930 <- RCzechia::historie("okresy_1930") %>% 
  mutate(nemci_30 = `národnost německá` / `počet obyvatel přítomných`,
         duchodci_30 = `obyvatelstvo celkem věk 65+` / `počet obyvatel přítomných` ) %>% 
  select(nemci_30, duchodci_30)

plot(okresy_1930[c("nemci_30", "duchodci_30")])

# pro přenos metrik uvažujte sf::st_interpolate_aw(); věnujte pozornost argumentu extensive