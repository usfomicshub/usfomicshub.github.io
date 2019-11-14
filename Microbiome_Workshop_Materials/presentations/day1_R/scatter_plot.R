
## show summary of mtcars
head(mtcars)
# check the data type of cyl
head(mtcars$cyl)

# Convert cyl column from a numeric to a factor variable
mtcars$cyl <- as.factor(mtcars$cyl)
# check the data type of cyl after factor convertion
head(mtcars$cyl)

### basic scatter plots
library('ggplot2')
ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()

## change the point size and shape
ggplot(mtcars, aes(x=wt, y=mpg)) +
  geom_point(size=2, shape=23)

## Change the point size
ggplot(mtcars, aes(x=wt, y=mpg)) + 
  geom_point(aes(size=qsec))

## Label points in the scatter plot
ggplot(mtcars, aes(x=wt, y=mpg)) +
  geom_point() + 
  geom_text(label=rownames(mtcars))

#### if used tradition plot
par(mar = c(5,5,1,0.5))
plot(x=NA,y=NA,xlim = c(1,6),ylim = c(10,34), 
     yaxt="n",
     xaxt = "n",
     xlab = '', 
     ylab = '',#bty = 'n',
     cex.lab=1.2, cex.axis=1, cex.main=1, cex.sub=1)
axis(1, at = seq(from = 1, to = 6, by = 01),las = 1,cex.axis=1.5)
axis(2, at = seq(from = 10, to = 35, by = 5),las = 1,cex.axis=1.5)

points( mtcars$wt, mtcars$mpg, pch = 19, col = 'blue', cex = 2)
mm <- lm(mtcars$mpg~ mtcars$wt)
abline(a = mm$coefficients[1], b = mm$coefficients[2])
###########################


### ggplot with correlation line
# Add the regression line
ggplot(mtcars, aes(x=wt, y=mpg)) + 
  geom_point()+
  geom_smooth(
              method=lm,
              se = F #confidence interval remove
              )
# Add the smooth line
ggplot(mtcars, aes(x=wt, y=mpg)) + 
  geom_point()+
  geom_smooth()

# Change point shapes, colors and sizes
ggplot(mtcars, aes(x=wt, y=mpg, 
                   shape=cyl, color=cyl, size=cyl)
       ) +
  geom_point()


### color with other color option
p <- ggplot(mtcars, aes(x=wt, y=mpg, color=cyl, shape=cyl)) +
  geom_point() + 
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)+
  theme_classic()
# Use brewer color palettes
p+scale_color_brewer(palette="Dark2")


###

# Scatter plot with the 2d density estimation
sp <- ggplot(faithful, aes(x=eruptions, y=waiting)) +
  geom_point()
sp + geom_density_2d()
# Gradient color

##other option
#1
df <- data.frame(x = faithful$eruptions, y = faithful$waiting)
ggplot(df,aes(x=x,y=y)) + stat_binhex()

#2
smoothScatter(faithful)

#3
library(MASS)  # in case it is not already loaded 
set.seed(101)
n <- 1000
X <- mvrnorm(n, mu=c(.5,2.5), Sigma=matrix(c(1,.6,.6,1), ncol=2))

## some pretty colors
library(RColorBrewer)
k <- 11
my.cols <- rev(brewer.pal(k, "RdYlBu"))

## compute 2D kernel density, see MASS book, pp. 130-131
z <- kde2d(X[,1], X[,2], n=50)

plot(X, xlab="X label", ylab="Y label", pch=19, cex=.4)
contour(z, drawlabels=FALSE, nlevels=k, col=my.cols, add=TRUE)
abline(h=mean(X[,2]), v=mean(X[,1]), lwd=2)
legend("topleft", paste("R=", round(cor(X)[1,2],2)), bty="n")


