# Gonna see how many hours I'd have to work at minimum wage each week to afford
# my student load payments.

library("rgeos")
library("rgdal")
library("maptools")
library("ggplot2")
library("dplyr")


# Money stuff -------------------------------------------------------------

# This is really personal!
monthlyPayment <- 524.75          # dollars/month

# A lazy coder would just use '4'. Not this guy.
weeksPerMonth <- 365.252 / 12 / 7 # days/year * year/month * weeks/day

# Read in state minimum wages.
minimumWage <- read.csv("minimum_wage.csv", stringsAsFactors = FALSE)
# Yes, GA and WY have state minimum wages set below the federal level.
# Also discretize the hours/week for pretty colorbrewer palettes. Should be <= 9
minimumWage <- minimumWage %>%
  mutate(real_minimum = pmax(federal_minimum, state_minimum, 
                             na.rm = TRUE),
         hours = monthlyPayment / weeksPerMonth / real_minimum,
         hours_cut = cut(hours, 6))


# Handle the map ----------------------------------------------------------

# Load the map
stateMap <- readOGR("times-approximate/shp", "Admin1_Polygons")
# Pull out state codes
stateMap@data$id <- rownames(stateMap@data)
stateMap.data <- select(stateMap@data, id, ISO3166_2)
# Calculate the projection
stateMapProj <- spTransform(stateMap, CRS("+proj=merc"))
# Create data.frame and join in state codes
stateMapDF <- fortify(stateMapProj, region = "id")
stateMapDF <- left_join(stateMapDF, stateMap.data, by = "id")

# Combine the money stuff with the map
stateMapDF <- left_join(stateMapDF, minimumWage, by = "ISO3166_2")


# Plotting ----------------------------------------------------------------

# Draw the map
p1 <- ggplot(stateMapDF, aes(long, lat, group=group, fill=hours_cut)) + 
  geom_polygon() + 
  geom_path(color="black", size=1) + 
  scale_fill_brewer(type = "seq", palette = "YlGn",
                    name = "Hours",
                    labels = sub("\\(([0-9\\.]+),([0-9\\.]+)\\]", "\\1 - \\2", 
                                 levels(stateMapDF$hours_cut))) + 
  coord_equal() + 
  ggtitle("Hours of work by state") + 
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
             axis.title.y = element_blank(),
             plot.title = element_text(size=32)))
print(p1)
ggsave("hours_per_state.png", plot = p1)