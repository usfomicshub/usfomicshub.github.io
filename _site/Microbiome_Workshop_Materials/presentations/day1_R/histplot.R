rm(list = ls())
library(datasets)
library(ggplot2)

data(airquality)
aq               <- airquality[!is.na(airquality$Ozone),] 

p7 <- ggplot(aq, aes(x = Ozone)) +
  geom_histogram(binwidth = 5)
p7

barfill <- "gold1"
barlines <- "goldenrod2"

p7 <- ggplot(aq, aes(x = Ozone)) +
  geom_histogram(aes(y = ..count..), binwidth = 5,
                 colour = barlines, fill = barfill) +
  scale_x_continuous(name = "Mean ozone in\nparts per billion",
                     
                     breaks = seq(0, 175, 25), 
                     # for the number, from = 0, to 175, by = 25
                     limits=c(0, 175)
                     # give the scale of x-axis , from = 0 to 175
                     ) +
  scale_y_continuous(name = "Count") +
  ggtitle("Frequency histogram of mean ozone")
p7


### tradition
par(mar = c(5,5,1,0.5))
plot(x=NA,y=NA,xlim = c(0, 175),ylim = c(0,16), 
     yaxt="n",
     xaxt = "n",
     xlab = 'Mean ozone in parts per billion', 
     ylab = 'Conts',#bty = 'n',
     cex.lab=1.2, cex.axis=1, cex.main=1, cex.sub=1)
axis(1, at = seq(from = 0, to = 175, by = 25))
axis(2, at = seq(from = 0, to = 15, by = 5), las = 1)

hist(aq$Ozone, breaks = 30, add = T, col = 'gold')
