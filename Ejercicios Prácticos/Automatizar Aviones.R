
# Tutorial de automatización de scripts
# https://anderfernandez.com/automatizar-scripts-de-r-en-windows-y-mac/

setwd("/Users/afernandez/Desktop/Trabajando con APIs/Ejercicios Prácticos/Automatizacion")

library(httr)
library(jsonlite)

nombre <- paste0(Sys.time(),".csv")
url = "https://opensky-network.org/api/states/all"
datos <- GET(url)
datos <- fromJSON(content(datos, type = "text"))
datos <- datos[["states"]]

write.csv(datos, file = nombre, row.names = FALSE)
