#Intro

##Packages
library(raster)
library(rgdal)
library(randomForest)

##Working directory
setwd('/Users/huaqo/Nextcloud/Fernerkundung/Projektbezogenes Arbeiten/04')

##Load data
img <- brick("landsat8_satellit_randomForest.tif")
shp <- shapefile("Trainingsdaten_landsat8_RF.shp")
getwd()
dir()
img
shp

##Coordinate system
compareCRS(shp, img)    #Compare coordinate systems
shp <-spTransform(shp, crs(img))    #Overwrite coordinate system

##Plot data
plotRGB(img, r = 4, g = 3, b = 2, stretch = "lin")
plot(shp, col = "yellow", add = TRUE)

#Preprocessing of shapefile
levels(as.factor(shp$classes))  #Show all classes
for (i in 1: length(unique(shp$classes))) {
    cat(paste0(i,"", levels(as.factor(shp$classes))[i], sep= "\n")) 
}   #assignment of numerical values to classes

#Create trainingdata 

##Extract Pixelvalues
smp <- extract(img, shp, df = TRUE) #Extract and merge
save(smp , file = "smp.rda") #save file in wd
load(file = 'smp.rda')  #load file from wd

##Merge trainingdate with classes
smp$cl <- as.factor(shp$classes[match(smp$ID, seq(nrow(shp)))]) #merge
smp <- smp[-1]
summary(smp$cl) #show assignment
str(smp)    #show data

#Create random forest modell

##Downsampling and get sample size of classification
smp.size <- rep(min(summary(smp$cl)), nlevels(smp$cl))
smp.size

##Modell
rfmodel <- tuneRF(x = smp[-ncol(smp)],
                  y = smp$cl,
                  sampsize = smp.size,
                  strata = smp$cl,
                  ntree = 250,
                  importance = TRUE,
                  doBest = TRUE)
rfmodel    #show modell

##Plot Statistical information
x11()
varImpPlot(rfmodel)

x11()
plot(rfmodel, col = c("violet", "tan4", "blueviolet", 
                      "yellowgreen", "green4", "blue"))
save(rfmodel, file = "rfmodel.RData")

#Classification
##Show modell as image
result <- predict(img, 
                  rfmodel,
                  filename = 'Ergebnis.tif',
                  overwrite = TRUE)

##Plot results
plot(result, 
     axes = FALSE, 
     box = FALSE,
     col= c("violet", 
            "tan4", 
            "blueviolet", 
            "yellowgreen", 
            "green4", 
            "blue"))
















