#Preparation
library(rgdal)
library(raster)
setwd('~/Nextcloud/Fernerkundung/Regionale Themen/04')
l5_2011 <- stack("l5_2011_topo.tif")
l8_2014 <- stack("L8_2014_topo.tif")

#NDWI Change analysis

##NDWI and change image (NDWI=Green-SWIR/Green+SWIR)
ndwi2014 <- (l8_2014[[2]] - l8_2014[[5]]) / (l8_2014[[2]] + l8_2014[[5]])
ndwi2011 <- (l5_2011[[2]] - l5_2011[[5]]) / (l5_2011[[2]] + l5_2011[[5]])

###Plot NDWI
plot(ndwi2011, zlim=c(-1,1))
plot(ndwi2014, zlim=c(-1,1))

###Calculate change image
change <- ndwi2011-ndwi2014

###Plot
plot(change)

##Change threshold
plot(density(change))
abline(v = 0.3,
       col = 'red')
loss <- change > 0.3
plot(loss)

##Derive change area
lossval <- getValues(loss)  #convert the values of the raster to a matrix or vector
table(lossval)

###Area in km/m
area <- table (lossval)[2] * 30 * 30 / 10000
area2 <- table (lossval)[2] * res(change) * res(change) / 10000
print(paste("The results of both variants should be equal: ", area, " = ", area2))

#Vector data

##Download administrative data
adm <- getData ("GADM", country="USA", level=2)
#plot(adm)

##Select specific polygons
adm[adm$NAME_2=='Trinity',]
shasta.county <- adm[adm$NAME_2=='Shasta',]
shasta.county
trinity.county <- adm[adm$NAME_2=='Trinity' & adm$NAME_1=='California',]
trinity.county

###Plot
plot(shasta.county)
plot(trinity.county)

###Combined plot option
counties <- bind(shasta.county, trinity.county)
plot(counties)

##Change projection of geodata in R
crs(shasta.county)    #show projection
crs(loss)

shasta.county.utm <- spTransform (shasta.county, crs(loss)) #change projection
trinity.county.utm <- spTransform(trinity.county, crs(loss))

crs (shasta.county.utm)

###Plot
plot(loss)
plot(shasta.county.utm, add=TRUE)
plot(trinity.county.utm, add=TRUE)

##Clip the raster data based on specific polygons
shasta.loss <- mask(loss, shasta.county.utm)
plot(shasta.loss)
trinity.loss <- mask(loss, trinity.county.utm)
plot(trinity.loss)

###Loss area
shasta.lossval <- getValues (shasta.loss) 
shasta.area <- table(shasta.lossval)[2] * res(shasta.loss)[1] * res(shasta.loss)[2] / 10000

trinity.lossval <- getValues (trinity.loss) 
trinity.area <- table(trinity.lossval)[2] * res(trinity.loss)[1] * res(trinity.loss)[2] / 10000

print(paste("The loss area of Shasta county equals ", shasta.area, " ha."))
print(paste("The loss area of Trinity county equals ", trinity.area, " ha." ))

#Tasselled Cap Wetness

##Calculate TCW
TCW.ls8 <- c(0.1511, 0.1973, 0.3283, 0.3407, -0.7117, -0.4559)
wetness.ls8 <- l8_2014*TCW.ls8
wetness.ls8 <- stackApply(wetness.ls8,rep(1,6),sum)
wetness.ls8 <- stackApply(wetness.ls8,1,sum)

wetcol <- colorRampPalette (c("tan3", "beige","navy"))
plot(wetness.ls8, col=wetcol(255), zlim=c(-0.4,0.1))

#Homework




