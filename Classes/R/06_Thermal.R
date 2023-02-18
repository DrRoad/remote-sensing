#### 1. Vorbereitung ####
install.packages('RStoolbox')
install.packages('raster')
library(raster)
library(RStoolbox)
setwd("~/OneDrive/Dokumente/Fernerkundung/PjS/06_Thermal/Daten Tag")

mtl <- 'LC08_L1TP_193023_20190726_20190801_01_T1_MTL.txt'
metaData <- readMeta(mtl)

ls8_2020 <- stack(metaData$DATA$FILES[c(1:7)])
names(ls8_2020) <- c("ultra_blue", "blue", "green", "red", "NIR", "SWIR1", "SWIR2")

#metaData$DATA$FILES

ls8_2020_thermal <- stack(metaData$DATA$FILES[9])
names(ls8_2020_thermal) <- c('TIR1')

setwd("~/OneDrive/Dokumente/Fernerkundung/PjS/06_Thermal/Berlin Shapefile")
BB_shape <- shapefile('Berlin_Bezirke.shp')

#### 2. Vorverarbeitung ####
##### 2.1 Top-Of-Atmosphere Reflectance #####
offset <- metaData$CALREF$offset[1:7]
gain <- metaData$CALREF$gain[1:7]
ls8_2020_toa1 <- gain * ls8_2020 + offset

sun_elev_day <- metaData$SOLAR_PARAMETERS['elevation']
sun_earth_distance_day <- metaData$SOLAR_PARAMETERS['distance']
ls8_2020_toa <- ls8_2020_toa1 * sun_earth_distance_day^2 / sin(sun_elev_day*pi/180)
#ls8_2020_toa



##### 2.2 Brightness Temperature #####
offset <- metaData$CALRAD$offset[10]  
gain <- metaData$CALRAD$gain[10] 
ls8_2020_thermal.RAD <- gain * ls8_2020_thermal + offset

K1 <- metaData$CALBT$K1[1]
K2 <- metaData$CALBT$K2[1]
ls8_2020_thermal.BT <- K2/log(K1/ls8_2020_thermal.RAD+1)
#ls8_2020_thermal.BT

#### 3. Shapefile ####
#plotRGB(ls8_2020_toa, r = 4, g = 3, b = 2, stretch = 'hist')
#plot(BB_shape, lwd = 2, border = 'red', add = TRUE)

ls8_2020_toa.BB <- crop(ls8_2020_toa, BB_shape)
ls8_2020_thermal.BT.BB <- crop(ls8_2020_thermal.BT, BB_shape)

#plotRGB(ls8_2020_toa.BB, r = 4, g = 3, b = 2, stretch = 'hist')
#plot(BB_shape, lwd = 2, border = 'red', add = TRUE)

#plot(ls8_2020_thermal.BT.BB, zlim=c(290,320))
#plot(BB_shape, lwd = 2, border = 'red', add = TRUE)

#### 4. Gleichung zur Berechnung der Oberflaechentemperatur ####
#LST(°C)=Bt/[1+(w∗Bt/p)∗ln(e)]−273.15
#e=0,017∗Pv+0,963
#PV=[(NDVI−NDVImin)/(NDVImax−NDVImin)]
#### 5. Berechnen des NDVI ####
ls8.ndvi <- spectralIndices(ls8_2020_toa.BB, red = 'red', nir = 'NIR', indices = 'NDVI')
#plot(ls8.ndvi)
#ls8.ndvi

#### 6. Berechnen des PV ####
NDVImin <- minValue(ls8.ndvi)
NDVImax <- maxValue(ls8.ndvi)
ls8.PV <- ((ls8.ndvi-NDVImin)/(NDVImax-NDVImin))^2
#plot(ls8.PV)

#### 7. Berechnung des Emissionsgrades ####
ls8.emissiv <- 0.017 * ls8.PV + 0.963
plot(ls8.emissiv)
#### 8. Berechnung der Oberflächentemperatur (LST) ####
ls8.LST <- (ls8_2020_thermal.BT.BB / (1+(10.8 * ls8_2020_thermal.BT.BB/14388) * log(ls8.emissiv))) - 273.15
#ls8.LST
#plot(ls8.LST, zlim=c(20,40))
#plot(BB_shape, lwd = 2, border = "red", add = TRUE)
#### 9. Speichern des Ergebnisses ####
setwd("~/OneDrive/Dokumente/Fernerkundung/PjS/06_Thermal")
writeRaster(ls8.LST$layer, "ls8_LST.sdat", format = "SAGA", overwrite = TRUE)
