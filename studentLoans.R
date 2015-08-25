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

# Load the map
stateMap <- readOGR("times-approximate/shp", "Admin1_Polygons")
# Pull out state codes
stateMap@data$id <- rownames(stateMap@data)
stateMap.data <- select(stateMap@data, id, ISO3166_2)
# Calculate the projection
stateMapProj <- spTransform(stateMap, CRS("+proj=merc"))
# Create data.frame and join in state codes
stateMapDF <- fortify(stateMapProj, region = "id")
stateMapDF <- left_join(stateMapDF, stateMap.data, by="id")

# Draw the map
# TODO: actual fill data
p1 <- ggplot(stateMapDF, aes(long, lat, group=group, fill=ISO3166_2)) + 
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
