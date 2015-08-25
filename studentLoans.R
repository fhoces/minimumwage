# Gonna see how many hours I'd have to work at minimum wage each week to afford
# my student load payments.

library("rgeos")
library("rgdal")
library("maptools")
library("ggplot2")
library("dplyr")

# This is really personal
monthlyPayment <- 524.75          # dollars/month

# A lazy coder would just use '4'. Not this guy.
weeksPerMonth <- 365.252 / 12 / 7 # days/year * year/month * weeks/day

# Load the map, project the coordinates, and convert to a data.frame
# TODO: Figure out how ids map to state abbrieviations
stateMap <- readOGR("times-approximate/shp", "Admin1_Polygons")
stateMapProj <- spTransform(stateMap, CRS("+proj=merc"))
stateMapDF <- fortify(stateMapProj)

# Draw the map
# TODO: actual fill data
p1 <- ggplot(stateMapDF, aes(long, lat, group=group, fill=as.factor(id))) + 
  geom_polygon() + 
  geom_path(color="black", size=0.3) + 
  coord_equal() + 
  list(theme(panel.grid.minor = element_blank(),
             panel.grid.major = element_blank(),
             panel.background = element_blank(),
             plot.background = element_rect(fill="white"),
             panel.border = element_blank(),
             axis.line = element_blank(),
             axis.text.x = element_blank(),
             axis.text.y = element_blank(),
             axis.ticks = element_blank(),
             axis.title.x = element_blank(),
             axis.title.y = element_blank()))
print(p1)
