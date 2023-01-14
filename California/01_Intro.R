#install.packages("raster")
#install.packages("rgdal")
library(raster)
library(rgdal)

#Assign .tif to an object
dem <- raster("SRTM_ffB01_p045r032.tif")

#General information
summary(dem)

#Structure of an object
str(dem)

#Visualize the imagery
plot(dem)
##Set min and max value
plot(dem, zlim=c(0,3000))
##Change color schemes (greyscale)
plot(dem, zlim=c(0,3000), col=grey.colors(255))
##Change color schemes (terrain colors)
plot(dem, zlim=c(0,3000), col=terrain.colors(255))

#Derive terrain features such as slope and aspect
slp <- terrain(dem, opt="slope", unit="degrees")
slp <- terrain(dem, opt="aspect", unit="degrees")

#Read single raster bands
blue2011 <- raster ("./LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B1.TIF")
green2011 <- raster ("./LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B2.TIF")
red2011 <- raster ("./LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B3.TIF")
nir2011 <- raster ("./LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B4.TIF")
swira2011 <- raster ("./LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B5.TIF")
swirb2011 <- raster ("./LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B7.TIF")

#Multiband raster
ls52011 <- stack(blue2011,green2011,red2011,nir2011,swira2011,swirb2011)

#Plot multiband raster images
plot(ls52011)
plot(ls52011[[4]]) #only one layer
plotRGB(ls52011, 3, 2, 1, stretch="lin") #plot RGB

#Raster image information
res (ls52011) #Resulution
projection (ls52011) #Projection
dim (ls52011) #Dimention (rows & columns)
nlayers (ls52011) #Number of layers
extent (ls52011) 
ncell (ls52011)

#Display new extent (crop) with lines on a plot
plot(nir2011)
abline(v=510000)
abline(v=580000)
abline(h=4490000)
abline(h=4543000)

#Define new extent (crop) with a box on a plot
plot(nir2011)
e <- extent(510000, 580000, 4490000, 4543000)
plot(e, add=TRUE, col = "red")

#Crop the image
ls52011.subs <- crop(ls52011, e)
##plot
plotRGB (ls52011.subs, 3, 2, 1, stretch="lin")

#Homework
dim(ls52011.subs)
ncell(ls52011.subs)
extent(ls52011)
636315-395685
4571415 - 4355985
215.430 * 240.630