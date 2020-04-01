rm(list = ls())
library(datasets)
library(ggplot2)

data(airquality)
airquality$Month <- factor(airquality$Month,
                           labels = c("May", "Jun", "Jul", "Aug", "Sep"))
aq               <- airquality[!is.na(airquality$Ozone),] 

p10 <- ggplot(aq, aes(x = Month, y = Ozone)) +
  geom_boxplot()
p10


#### if used tradition plot
data(airquality)
par(mar = c(5,5,1,0.5))
plot(x=NA,y=NA,xlim = c(0.5,5.5),ylim = c(0,170), 
     yaxt="n",
     xaxt = "n",
     xlab = '', 
     ylab = '',#bty = 'n',
     cex.lab=1.2, cex.axis=1, cex.main=1, cex.sub=1)
axis(1, at = seq(from = 1, to = 5, by = 01),
     las = 1,cex.axis=1.5, labels = c('May', 'Jun', 'Jul','Aug', 'Sep'))
axis(2, at = seq(from = 0, to = 170, by = 20),las = 1,cex.axis=1.5)
for (i in unique(airquality$Month)) 
{
     pos <- i - 4 
     boxplot(airquality$Ozone[which(airquality$Month == i)], at = pos,
             col = 'navy', medcol = 'white',add = T, yaxt = 'n',
             width = 1.2)
}



fill <- "#4271AE" # give the color filled in box
line <- "#1F3552" # give the color for the line in box
p10 <- ggplot(aq, aes(x = Month, y = Ozone)) +
  geom_boxplot(fill = fill, colour = line) +
  scale_y_continuous(name = "Mean ozone in\nparts per billion",
                     breaks = seq(0, 175, 25),
                     limits=c(0, 175)) +
  scale_x_discrete(name = "Month") +
  ggtitle("Boxplot of mean ozone by month")
p10


#change the data format, only extract data in July, Aug and Sep
airquality_trimmed <- airquality[which(airquality$Month == "Jul" |
                                         airquality$Month == "Aug" |
                                         airquality$Month == "Sep"), ]
#return two factors with 1, 0 and replace with 'low' or 'high' temp
airquality_trimmed$Temp.f <- factor(ifelse(airquality_trimmed$Temp > 
                                             mean(airquality_trimmed$Temp), 1, 0),
                                    labels = c("Low temp", "High temp"))
aq  <- airquality_trimmed[!is.na(airquality_trimmed$Ozone),] 
p10 <- ggplot(aq, aes(x = Month, y = Ozone)) +
  geom_boxplot(fill = fill, colour = line,
               alpha = 0.7) +
  scale_y_continuous(name = "Mean ozone in\nparts per billion",
                     breaks = seq(0, 175, 50),
                     limits=c(0, 175)) +
  scale_x_discrete(name = "Month") +
  ggtitle("Boxplot of mean ozone by month") +
  theme_bw() +
  theme(plot.title = element_text(size = 14, family = "Tahoma", face = "bold"),
        text = element_text(size = 12, family = "Tahoma"),
        axis.title = element_text(face="bold"),
        axis.text.x=element_text(size = 11)) +
  facet_grid(. ~ Temp.f)   ## two plot based on Temp.f 
p10
