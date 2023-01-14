setwd("~/OneDrive/Dokumente/Fernerkundung/Regio/07_Klimawandel")

library (raster)

bioclim <- stack('/Users/huaqo/OneDrive/Dokumente/Fernerkundung/Regio/07_Klimawandel/bioclim_california.tif')

names (bioclim) <- c ('Annual Mean Temp', 'Mean Diurnal Range', 'Isothermality',                 
                      'Temp Seasonality', 'Max Temp Warmest Month', 
                      'Min Temp Coldest Month', 'Temp Annual Range', 
                      'Mean Temp Wettest Quarter', 'Mean Temp Driest Quarter', 
                      'Mean Temp Warmest Quarter', ' Mean Temp Coldest Quarter', 
                      'Annual Prec', 'Prec Wettest Month', 'Prec Driest Month', 
                      'Prec Seasonality', 'Prec Wettest Quarter', 
                      'Prec Driest Quarter', 'Prec Warmest Quarter', 
                      'Prec Coldest Quarter')

scaling.factor <- c (10, 10, 1, 1000, 10, 10, 10, 10, 10, 10, 10, 1, 1, 1, 1, 1,
                     1, 1, 1)

bioclim <- bioclim/scaling.factor

bc.values <- getValues(bioclim)

bc.val <- na.omit(bc.values)

clim.kmeans <- kmeans(scale(bc.val), centers=8)

climclust <- clim.kmeans$cluster

clust.pix <- bc.values[,1]

clust.pix[is.na(clust.pix)==F] <- climclust

clust.map <- setValues(bioclim[[1]], clust.pix)

#jpeg('cluster_climate.png', quality=100)

cl <- colorRampPalette (c("yellow", "wheat", "goldenrod", "light green", "forest green", "blue", "firebrick", "black") ) 

#plot(clust.map, col=cl(8))

#dev.off()

#x11()

#for (i in 1: 19) {
#    boxplot (bc.val[,i]~climclust, col=cl(8) , main=colnames(bc.val)[i])
#    readline("Press <ENTER> for next plot") 
#} 

#for (i in 1: 19) {
#    png(filename = paste(i, "_", colnames(bc.val)[i], ".png", sep = ""))
#    boxplot (bc.val[,i]~climclust, col=cl(8) , main=colnames(bc.val)[i])
#    dev.off()
#} 

setwd('/Users/huaqo/OneDrive/Dokumente/Fernerkundung/Regio/07_Klimawandel/gs26bi50')

files <- Sys.glob("*tif")

files

bc.future <- stack(files)

CA <- getData('GADM', country='USA', level=1)

CA <- CA[CA$NAME_1=='California',]

bc.fut <- crop(bc.future, CA)

bc.fut <- mask(bc.fut, CA)

names(bc.fut) <- c('Annual Mean Temp', 'Mean Diurnal Range', 'Isothermality', 
                   'Temp Seasonality', 'Max Temp Warmest Month', 'Min Temp Coldest Month', 'Temp Annual Range', 'Mean Temp Wettest Quarter', 'Mean Temp Driest Quarter', 'Mean Temp Warmest Quarter', 'Mean Temp Coldest Quarter', 'Annual Prec', 'Prec Wettest Month', 'Prec Driest Month', 'Prec Seasonality' , 'Prec Wettest Quarter', 'Prec Driest Quarter' , 'Prec Warmest Quarter', 'Prec Coldest Quarter')

scaling.factor <- c(10, 10, 1, 1000, 10, 10, 10, 10, 10, 10, 10, 1, 1, 1, 1, 1, 
                    1, 1, 1) 

bc.fut <- bc.fut/scaling.factor

bc.diff <- bc.fut - bioclim

#plot(bc.diff[[1]] , col=gray.colors(255,0,1,1))

library(rgdal)
library(rgeos)
library(raster)
clust.poly <- readOGR('/Users/huaqo/OneDrive/Dokumente/Fernerkundung/Regio/07_Klimawandel/cluster_poly.shp')

plot(bc.diff[[2]] , col=gray.colors (255, 0, 1, 1))
plot(clust.poly, add=T, col=cl(8), density=20, angle=45) 
legend("topright", legend=1:8 , col=cl(8) , lty=1, lwd=2) 


