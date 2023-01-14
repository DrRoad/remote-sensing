#### 1. Vorbereitung ####
setwd("~/OneDrive/Dokumente/Fernerkundung/PjS/08_Kastanie/Daten")
install.packages('vioplot')
library('vioplot')
library(raster)
library(rgdal)
Kachel_2020 <- stack('Kachel_Suedwest.tif')
names(Kachel_2020) <- c('NIR','RED','GREEN')
#plotRGB(Kachel_2020, 1, 2, 3, stretch = 'lin')

par(mfrow = c(1,1))

Kronen <- readOGR('rkast_buffer_single.shp')
#plot(Kronen, lwd = 5, border = 'yellow', add = TRUE)

NDVI <- stack('ndvi.tif')
#plot(NDVI)

#### 2. Extrahieren von Pixeln ####
extract_CIR <- extract(Kachel_2020, Kronen, df = TRUE)
extract_NDVI <- extract(NDVI, Kronen, df = TRUE)

#### 3. Statistische Auswertung der extrahierten Pixel ####
##### 3.1 Erstellen von Boxplots #####
col = c('purple','red','green')
boxplot(extract_CIR[2:4], col = col, ylab = 'Reflectance')
##### 3.2 Erstellen von Violinplots #####
vioplot(extract_CIR[2:4], col = col, horizontal = F)

#### 4. Mittelwerte pro Baum bestimmen ####
sp <- aggregate(. ~ ID , data = extract_CIR, FUN = mean, na.rm = TRUE )
##### 4.1 Mittelwerte der Kanäle plotten #####
par(mfrow = c(1,3))

##NIR
plot(sp[,2], ylim = c(0,250), ylab = "Reflectance", main ="NIR")
abline(h = mean(sp$NIR), col ="red")
##Rot
plot(sp[,3], ylim = c(0,250), ylab = "Reflectance", main ="Red")
abline(h = mean(sp$RED), col ="red")
##Gruen
plot(sp[,4], ylim = c(0,250), ylab = "Reflectance", main ="Green")
abline(h = mean(sp$GREEN), col ="red")

#### 5. Vergleich mit der Referenzgattung Linde ####
##### 5.1 Einladen der Daten #####
Linden <- readOGR("Vergleichsbaum_Linde_singlepart.shp")
summary(Linden)
##### 5.2 Stichprobe ziehen #####
sample_index <- sample(1:length(Linden),400)
Linden_sample <-  Linden[sample_index,]

plot(Linden)
plot(Linden_sample, add=T, col="red")
##### 5.3 Extrahieren der Linden Pixel #####
extract_Linden <- extract(Kachel_2020, Linden_sample, buffer = 1, na.rm = TRUE, df = TRUE)

##optional für die die komischerweise keinen Dataframe erhalten (vielleicht Mac-User?)
# Manuelles Umwandeln in einen Dataframe
extract_Linden <- data.frame(extract_Linden)

##### 5.4 Violinplots von Kastanien und Linden vergleichen #####
par(mfrow = c(1,2))

col= c("purple","red","green")
vioplot(extract_CIR[2:4],col = col, horizontal=F, main ="Rosskastanien")

vioplot(extract_Linden[2:4],col = col, horizontal=F, main = "Linden")

##### 5.5 Mittelwerte pro Linde berechnen #####
sp_Linden <- aggregate(. ~ ID , data = extract_Linden, FUN = mean, na.rm = TRUE )

##### 5.6 Mittelwerte des NIR der Gattungen vergleichen #####
par(mfrow = c(1,2))

##NIR Kastanien
plot(sp[,2], ylim = c(0,250))
abline(h = mean(sp$NIR), col ="red")

##NIR Linden

plot(sp_Linden[,2], ylim = c(0,250))
abline(h = mean(sp_Linden$NIR), col ="red")




