#### Install packages ####
# install.packages("terra")

#### Activate packages ####
library(terra) # Spatial Data Analysis

#### Import raster files ####
blue <- rast("raster1.TIF")
green <- rast("raster2.TIF")
red <- rast("raster3.TIF")

#### Create layerstack ####
layerstack <- c(blue, green, red)

#### Plot composite ####
plotRGB(layerstack, 3, 2, 1, stretch = "lin")
