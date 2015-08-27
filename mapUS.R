# Here I'll eventually write code to draw a choropleth of the US.

#Here's a code snippet that will help me remember how to inset AK and HI on a
#map of the US from http://stackoverflow.com/a/5220641 
#Any old plot
a_plot <- ggplot(cars, aes(speed, dist)) + geom_line()

#A viewport taking up a fraction of the plot area
vp <- viewport(width = 0.4, height = 0.4, x = 0.8, y = 0.2)

#Just draw the plot twice
png("test.png")
print(a_plot)
print(a_plot, vp = vp)
dev.off()
