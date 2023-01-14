###Preparation
#Package aktivieren
library(raster)

#Arbeitsordner auf Festplatte festlegen
setwd("~/Nextcloud/Fernerkundung/Regionale Themen/05")

###Donwload and open Bioclim data
#Lade Datei aus Internet
bioclim1 <- getData ('worldclim', var='bio', res=0.5, lon= -122, lat=34)

#Stellt die Datei dar
plot(bioclim1[[1]])

#Speichert die Datei im Arbeitsordner
writeRaster(bioclim1, 'bioclim_1.tif', format='GTiff', overwrite=TRUE)

#Zeigt die Ausmaße der Datei
extent(bioclim1)

#Lade eine zweite Datei
bioclim2 <- getData('worldclim', var='bio', res=0.5, lon=-117, lat=34)

#Nochmal Plotten
plot(bioclim2[[1]])

#Speichert die Datei
writeRaster(bioclim2, 'bioclim_2.tif', format='GTiff', overwrite=TRUE)

#Karten zuasmmenschneiden
bioclim <- merge(bioclim1, bioclim2)

#Daten Speichern
writeRaster(bioclim, 'bioclim.tif', format='GTiff', overwrite=TRUE)

###Clip data to California
#Grenzen von Kalifornien laden
CA <- getData('GADM', country='USA', level=1)

#Bestimmte Grenzen auswählen
CA <- CA[CA@data$NAME_1=='California',]

#Zwei karten übereinander plotten
plot(bioclim[[1]])
plot(CA, add=T)

#Grenzdaten und Daten zusammenschneiden
bioclim <- crop(bioclim, CA)
bioclim <- mask(bioclim, CA)

#Speichern
writeRaster(bioclim, 'bioclim_california.tif', format='GTiff', overwrite=TRUE)

#Laden
bioclim <- stack('bioclim_california.tif')

#plotten
plot(bioclim)

#Bennenung der Karten
names (bioclim) <- c ('Annual Mean Temp', 'Mean Diurnal Range', 'Isothermality',                 
                      'Temp Seasonality', 'Max Temp Warmest Month', 
                      'Min Temp Coldest Month', 'Temp Annual Range', 
                      'Mean Temp Wettest Quarter', 'Mean Temp Driest Quarter', 
                      'Mean Temp Warmest Quarter', ' Mean Temp Coldest Quarter', 
                      'Annual Prec', 'Prec Wettest Month', 'Prec Driest Month', 
                      'Prec Seasonality', 'Prec Wettest Quarter', 
                      'Prec Driest Quarter', 'Prec Warmest Quarter', 
                      'Prec Coldest Quarter')

#File size reduction undo
scaling.factor <- c (10, 10, 1, 1000, 10, 10, 10, 10, 10, 10, 10, 1, 1, 1, 1, 1,
                     1, 1, 1)
bioclim <- bioclim / scaling.factor

#Plot
plot(bioclim)

###Correlation analysis of the Bioclim data

#Extrahieren von Pixel Werten aus der Raster Datei
bc.values <- getValues(bioclim)

#NA Werte entfernen
bc.val <- na.omit(bc.values)

#Korrelation bestimmen
correl <- cor(bc.val)

#Package für Visualisierung
install.packages('corrplot')
library(corrplot)

#Plot correlation
plot <- corrplot(correl, order = 'original', addrect = 2)
plot <- corrplot(correl, order = 'hclust', addrect = 4)



###Principal component analysis of bioclim data
install.packages('RStoolbox')
library(RStoolbox)

#Calculate PCA
PCA <- rasterPCA(bioclim, spca=TRUE)

#Plot PCA
plot(PCA$model$sdev)

#Plot PCA Space (Climate Zones)
plotRGB(PCA$map,1,2,3, stretch='lin')

###Additional: Detailed analysis: interpreting the principal components
pcascores <- na.omit(getValues(PCA$map))

rescale <- function (x) (x - min (x)) / (max (x) - min (x)) * 255
pcargb <- apply (pcascores[,1:3], 2, rescale)
pca.rgb <- rgb(pcargb, maxColorValue=255)

install.packages('vegan')
library(vegan)

sel <- sample(1:nrow (pcascores))[1:5000]

par (bg="black", col="white") 
plot (pcascores[sel,1:2], cex=0.5, pch=19, col=pca.rgb[sel], col.lab="white",               
      main=colnames(bc.val)[1], col.main="white") 
axis (1, col="white", col.axis="white")
axis (2, col="white", col.axis="white")
ordisurf (pcascores[sel, 1:2]~bc.val[sel, 1], add=T, labcex=1, lwd.cl=2,                
          col="white") 
for (i in 2:19){
    plot (pcascores[sel,], cex=0.5, pch=19, col=pca.rgb[sel], col.lab="white",
          main=colnames (bc.val)[i], col.main="white")
    axis (1, col="white", col.axis="white")
    axis (2, col="white", col.axis="white")
    ordisurf (pcascores[sel, 1:2]~bc.val[sel, i], add=T, labcex=1, lwd.cl=2,
              col="white")
    readline ("Press <ENTER> for next plot")
}
