rm(list = ls())

library(httr)
library(jsonlite)
library(rvest) #Para scrapear

setwd("/Users/afernandez/Desktop/Trabajando con APIs/Ejercicios Prácticos/")

# Mapa en tiempo real de la posición de los Aviones -----------------------
# Página: https://opensky-network.org/apidoc/rest.html
url = "https://opensky-network.org/api/states/all"
datos <- GET(url)
datos

datos <- fromJSON(content(datos, type = "text"))
datos <- datos[["states"]]


# Extraer datos de columnas para saber qué es cada cosa
url = "https://opensky-network.org/apidoc/rest.html"
nombres <- read_html(url) %>% html_nodes("#all-state-vectors")  %>% html_nodes("#response")  %>% html_nodes('.docutils') %>% html_table()
colnames(datos) <- nombres[[2]]$Property
datos <- as.data.frame(datos, stringsAsFactors = FALSE)

# write.csv(datos, "aviones.csv", row.names = FALSE)
# datos <- read.csv("aviones.csv")

# Visualizamos los datos
library(leaflet)

# Convertirmos la latitud y longitud en número, ya que vienen en string (texto)
datos$longitude <- as.numeric(datos$longitude)
datos$latitude <- as.numeric(datos$latitude)

# Creamos el mapa
leaflet() %>%
  addTiles() %>%
  addCircles(lng = datos$longitude, lat = datos$latitude, color = "#ff5733", opacity = 0.3) 

## ¿Y si automatizaramos el proceso para guardar los datos cada minuto?

# Extracción del histórico de dividendos de una empreesa  -------------------------------------------------------
rm(list = ls())

# Api: Finnhub 

url = "https://finnhub.io/api/v1/stock/dividend"

querystring = list(
  symbol= "AAPL",
  from="1900-01-01",
  to="2020-03-31",
  token = "bq8922frh5rc96c0gnfg"
  )

datos <- GET(url, query = querystring)
datos

datos <- fromJSON(content(datos, type = "text"))

datos

datos$date <- as.Date(datos$date)

library(ggplot2)

datos %>%
  ggplot(aes(date, amount)) + geom_line()+ theme_minimal()


# Todos los partidos de la NBA desde sus orígenes --------------------------------------------------------
rm(list = ls())

# Url: https://rapidapi.com/theapiguy/api/free-nba?endpoint=apiendpoint_5d8ecb72-3e4a-41ff-bc58-45757799acb0

# Paginación:
# Algunas APis ofrecen un número máximo de filas por petición. Por tanto, si quieres sacar todos los datos
# tienes que hacer varias llamadas


# Vamos a la url y copiamos los valores de la derecha

url = "https://free-nba.p.rapidapi.com/games"

querystring = list(page ="0", per_page ="500")

headers = add_headers(
  'x-rapidapi-host'= "free-nba.p.rapidapi.com",
  'x-rapidapi-key'= "37ea1efa59msh10649d0be9494bep13ab17jsne5b541fcd3ec"
)

datos <- GET(url, query = querystring,  headers)

datos

datos <- fromJSON(content(datos, type = "text"))

total_paginas <- datos[["meta"]][["total_pages"]]
datos <- datos[[1]]

datos <- data.frame()
for(i in 1:total_paginas){
  querystring <- list(page=i, per_page="100")
  x <- GET(url, query = querystring,  headers)
  x <- fromJSON(content(x, type = "text"))
  x <- x[["data"]]
  x <- t(apply(x, 1, unlist)) # Esto hace un unlist de todas las  listas dentro del dataframe
  datos <- rbind(datos,x)
  print(i)
  Sys.sleep(1)
}

write.csv(datos,"historico_nba.csv", row.names = FALSE)

datos <- read.csv("historico_nba.csv", stringsAsFactors =  FALSE)

# ¿Qué podríamos hacer con acceso a todos los datos de todos los partidos de la NBA?
# ¿Y si tuviésemos acceso a todos los datos de cada partido jugada a jugada?
# Ejemplo: https://community.rstudio.com/t/nba-18-19-analytics-app-kobe-bryant-tribute-2020-shiny-contest-submission/55740
# API (gratuita para uso no comercial): https://www.mysportsfeeds.com/


