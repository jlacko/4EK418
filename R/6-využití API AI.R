# využití Gemini API ke geokódování textu

library(gemini.R)  # připojení na Gemini API
library(dplyr)     # práce s dataframem
library(jsonlite)  # pro porozumění JSON výstupům
library(leaflet)   # pro interaktivní vizualizaci

# úvodní prompt
prompt_header <- "you are an experienced geographer; analyze this text and 
                  give me all the location mentioned as a name, together with 
                  its relation to the overall message in the format of a POINT in 
                  simple features WKT format, and state your confidence
                  about the geocoding accuracy on a scale from 0 to 100 \n\n"

# vlastní text pro analýzu
text_input <- "Jedu takhle tábořit Škodou 100 na Oravu
               Spěchám, proto riskuji, projíždím přes Moravu
               Řádí tam to strašidlo, vystupuje z bažin
               Žere hlavně Pražáky, jmenuje se Jožin
               
               Jožin z bažin močálem se plíží
               Jožin z bažin k vesnici se blíží
               Jožin z bažin už si zuby brousí
               Jožin z bažin kouše, saje, rdousí
               
               Na Jožina z bažin, koho by to napadlo
               Platí jen a pouze práškovací letadlo
               
               Projížděl jsem dědinou cestou na Vizovice
               Přivítal mě předseda, řek' mi u slivovice
               'Živého či mrtvého Jožina kdo přivede'
               'Tomu já dám za ženu, dceru a půl JZD'
               
               Jožin z bažin močálem se plíží
               Jožin z bažin k vesnici se blíží
               Jožin z bažin už si zuby brousí
               Jožin z bažin kouše, saje, rdousí
               
               Na Jožina z bažin, koho by to napadlo
               Platí jen a pouze práškovací letadlo
               Říkám: 'Dej mi, předsedo, letadlo a prášek'
               
               'Jožina ti přivedu, nevidím v tom háček'
               Předseda mi vyhověl, ráno jsem se vznesl
               Na Jožina z letadla prášek pěkně klesl
               
               Jožin z bažin už je celý bílý
               Jožin z bažin z močálu ven pílí
               Jožin z bažin dostal se na kámen
               Jožin z bažin, tady je s ním amen
               
               Jožina jsem dohnal, už ho držím, jo-ho-hó
               Dobré každé love, prodám já ho do ZOO"

# schema pro svázání výstupu do pevného formátu
schema <- list(
  type = "ARRAY",
  items = list(
    type = "OBJECT",
    properties = list(
      name = list(type = "STRING"),
      relation = list(type = "STRING"),
      location = list(type = "STRING"),
      confidence = list(type = "NUMBER")
    ),
    propertyOrdering = c("name", "relation", "location",  "confidence")
  )
)

tictoc::tic() # stopky spuštěny

# ať Gemini API předvede svojí magii...
location <- gemini_structured(prompt = paste(prompt_header, text_input),
#                              model = "3-flash-preview", # our most balanced model built for speed, scale, and frontier intelligence.
                              model = "2.5-flash-lite", # for the cheapskates...
                              schema = schema)

tictoc::toc() # stopky odečet :)

# náhled na výstup jako JSON
prettify(location)

# z ošklivého JSONu do hezkého sf dataframe
sf_vystup <- location %>% 
  jsonlite::fromJSON() %>% # json >> data.frame
  filter(location != "UNKNOWN") %>% 
  sf::st_as_sf(wkt = "location", crs = 4326)


# datový overview
leaflet(data = sf_vystup) %>% 
  addTiles() %>% 
  addPopups(popup = ~ paste("<b>", name, "</b>:", 
                            relation, "<br> confidence", 
                            confidence, "of 100"))

