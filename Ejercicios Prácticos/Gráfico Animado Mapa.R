rm(list = ls())
library(ggplot2)
library(maps)
library(gganimate)
library(ggthemes)

setwd("/Users/afernandez/Desktop/Trabajando con APIs/Ejercicios Prácticos")
setwd("/Users/afernandez/Desktop/Trabajando con APIs/Ejercicios Prácticos/Automatizacion")

# Cargamos los datos
ficheros <- list.files()

datos <- data.frame()

for(i in 1:length(ficheros)){
  x <- read.csv(ficheros[i], stringsAsFactors = FALSE)
  x$fichero <- ficheros[i]
  x$posicion <- i
  datos <- rbind(datos,x)
  print(i)
}

rm(x)

# Extraer datos de columnas para saber qué es cada cosa
library(rvest)
url = "https://opensky-network.org/apidoc/rest.html"
nombres <- read_html(url) %>% html_nodes("#all-state-vectors")  %>% html_nodes("#response")  %>% html_nodes('.docutils') %>% html_table()
colnames(datos) <- c(nombres[[2]]$Property, "fichero","posicion")
datos <- as.data.frame(datos, stringsAsFactors = FALSE)

rm(nombres,ficheros,i,url)

# Convertirmos la variable fichero en date
library(lubridate)

datos$fichero <- gsub(".csv","",datos$fichero)
datos$fichero <- ymd_hms(datos$fichero)


# Creamos el mapa
worldmap <- map_data("world")#, region = europeanUnion)
wrld<-c(geom_polygon(aes(long,lat,group=group), 
                     size = 0.1, 
                     colour= "#090D2A", 
                     fill="#090D2A", alpha=0.8, data=worldmap))


ggplot() + 
  wrld + 
  theme(panel.background =   
          element_rect(fill='#00001C',colour='#00001C'),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) + 
  coord_cartesian(xlim = c(-25,45), ylim = c(32,70))+
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())

plot <- ggplot() +
  wrld +
  geom_point(aes(longitude,latitude, color= origin_country), alpha=0.3, 
            size=3, data= datos) +
  theme(axis.line=element_blank(),axis.text.x=element_blank(),
        axis.text.y=element_blank(),axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())+
  theme(panel.background =  element_rect(fill='#00001C', 
                                         colour='#00001C'), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank()) +
  theme(legend.position = "none")

anim <- plot + 
  transition_reveal(datos$fichero)

animate(anim, width = 1280, height = 737,  end_pause = 40)


