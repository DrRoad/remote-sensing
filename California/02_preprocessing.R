##### 01 Uebung ######

#1.01 Install packages
install.packages("rgdal")
install.packages("raster")

#1.02 Load packages
library(raster)
library(rgdal)

#1.03 Set working directory
setwd("/Users/huaqo/Nextcloud/Regionale Themen/02 uebung")

#1.04 Assign .tif to an object
dem <- raster("SRTM_ffB01_p045r032.tif")

#1.05 General information
summary(dem)

#1.06 Structure of an object
str(dem)

#1.07 Visualize the imagery
plot(dem)
##1.08 Set min and max value
plot(dem, zlim=c(0,3000))
##1.09 Change color schemes (greyscale)
plot(dem, zlim=c(0,3000), col=grey.colors(255))
##1.10Change color schemes (terrain colors)
plot(dem, zlim=c(0,3000), col=terrain.colors(255))

#1.11Derive terrain features such as slope and aspect
slp <- terrain(dem, opt="slope", unit="degrees")
slp <- terrain(dem, opt="aspect", unit="degrees")

#1.12Read single raster bands
blue2011 <- raster ("/Users/fokus/Nextcloud/Regionale Themen/LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B1.TIF")
green2011 <- raster ("/Users/fokus/Nextcloud/Regionale Themen/LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B2.TIF")
red2011 <- raster ("/Users/fokus/Nextcloud/Regionale Themen/LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B3.TIF")
nir2011 <- raster ("/Users/fokus/Nextcloud/Regionale Themen/LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B4.TIF")
swira2011 <- raster ("/Users/fokus/Nextcloud/Regionale Themen/LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B5.TIF")
swirb2011 <- raster ("/Users/fokus/Nextcloud/Regionale Themen/LT05_L1TP_045032_20110909_20160831_01_T1/LT05_L1TP_045032_20110909_20160831_01_T1_B7.TIF")

#1.13Multiband raster
ls52011 <- stack(blue2011,green2011,red2011,nir2011,swira2011,swirb2011)

#1.14 Plot multiband raster images
plot(ls52011)
plot(ls52011[[4]]) #only one layer
plotRGB(ls52011, 3, 2, 1, stretch="lin") #plot RGB

#1.15 Raster image information
res (ls52011) #Resulution
projection (ls52011) #Projection
dim (ls52011) #Dimention (rows & columns)
nlayers (ls52011) #Number of layers
extent (ls52011) 
ncell (ls52011)

#1.16 Display new extent (crop) with lines on a plot
plot(nir2011)
abline(v=510000)
abline(v=580000)
abline(h=4490000)
abline(h=4543000)

#1.17 Define new extent (crop) with a box on a plot
plot(nir2011)
e <- extent(510000, 580000, 4490000, 4543000)
plot(e, add=TRUE, col = "red")

#1.18 Crop the image
ls52011.subs <- crop(ls52011, e)
##plot
plotRGB (ls52011.subs, 3, 2, 1, stretch="lin")

#1.19 Homework
dim(ls52011.subs)
ncell(ls52011.subs)
extent(ls52011)
636315-395685
4571415 - 4355985
215.430 * 240.630

####### 02 Uebung #######
## For Landsat 5
#1.01
#1.02
#1.03
#1.12
#1.13

#2.01 Export layerstack
writeRaster(l5_2011, "L5_2011_entire.tif", Format="GTiff", overwrite = TRUE)

#1.17
#2.01
#1.13

## For Landsat 8

blue2014 <- raster ("/Users/huaqo/Nextcloud/Regionale Themen/02 uebung/LC08_L1TP_045032_20140901_20170303_01_T1/LC08_L1TP_045032_20140901_20170303_01_T1_B2.TIF")
green2014 <- raster ("/Users/huaqo/Nextcloud/Regionale Themen/02 uebung/LC08_L1TP_045032_20140901_20170303_01_T1/LC08_L1TP_045032_20140901_20170303_01_T1_B3.TIF")
red2014 <- raster ("/Users/huaqo/Nextcloud/Regionale Themen/02 uebung/LC08_L1TP_045032_20140901_20170303_01_T1/LC08_L1TP_045032_20140901_20170303_01_T1_B4.TIF")
nir2014 <- raster ("/Users/huaqo/Nextcloud/Regionale Themen/02 uebung/LC08_L1TP_045032_20140901_20170303_01_T1/LC08_L1TP_045032_20140901_20170303_01_T1_B5.TIF")
swira2014 <- raster ("/Users/huaqo/Nextcloud/Regionale Themen/02 uebung/LC08_L1TP_045032_20140901_20170303_01_T1/LC08_L1TP_045032_20140901_20170303_01_T1_B6.TIF")
swirb2014 <- raster ("/Users/huaqo/Nextcloud/Regionale Themen/02 uebung/LC08_L1TP_045032_20140901_20170303_01_T1/LC08_L1TP_045032_20140901_20170303_01_T1_B7.TIF")
ls82014 <- stack(blue2014, green2014, red2014, nir2014, swira2014, swirb2014)
ls82014.crop <- crop(ls82014, e)
writeRaster(ls82014, "ls82014_entire.tif", Format="GTiff", overwrite = TRUE)
writeRaster(ls82014.crop, "ls82014.tif", Format="GTiff", overwrite = TRUE)
ls52011.crop <- stack("ls52011.tif")
ls82014.crop <- stack("ls82014.tif")

#Metadata
# REFLECTANCE_MULT_BAND_4 = 2.0000E-05
# REFLECTANCE_ADD_BAND_4 = -0.100000
# SUN_ELEVATION = 53.22163770
# EARTH_SUN_DISTANCE = 1.0091290

#Calculation of the TOA reflectance for one band
ls82014_NIR_TOA_simple <- (ls82014.crop[[4]]*0.00002) - 0.1
plot(ls82014_NIR_TOA_simple, col = grey.colors(255), zlim= c(0,1))

#Correct for the sun zenith angle and the sun-earth-distance for one band
sun_elev <- 53.22163770
sun_earth_distance <- 1.0091290
ls82014_NIR_TOA <- ls82014_NIR_TOA_simple * sun_earth_distance^2 / sin(sun_elev*pi/180)
plot(NIR_TOA, col = grey.colors(255), zlim= c(0,0.6))

#Correct all for all bands
ls82014_TOA_corrected <- (((ls82014.crop*0.00002) - 0.1) * sun_earth_distance^2) / sin(sun_elev*pi/180)
writeRaster(ls82014_TOA_corrected, "ls82014_TOA_corrected.tif", format = "GTiff", overwrite = TRUE)

#Correct for dark pixels
min2014 <- minValue(ls82014_TOA_corrected)
ls82014_darkpixel_corrected <- ls82014_TOA_corrected - min2014
writeRaster(ls82014_darkpixel_corrected, format = "GTiff")
plotRGB(ls82014_darkpixel_corrected,4,3,2, stretch="lin")

#Q1: No Comparison
#Q2:
##DM: Quantized and calibrated scaled Digital Numbers (DN) representing the multispectral image acquired by OLI and TIRS.
##TOA: They can be converted to Top Of Atmosphere (TOA) reflectance and radiance values by using radiometric rescaling coefficients as described in this USGS guide.
##Surface Reflectance products provide an estimate of the surface spectral reflectance as it would be measured at ground level in the absence of atmospheric scattering or absorption.
#Q3: Level1: DM oder TOA Level2: SR
#Q4: Yes it is a physical Value but without the correct for the sunzenith ang and Earth distance
