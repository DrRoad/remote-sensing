#Preprocessed data import
l5_2011_rawdn <- stack('L5_2011.tif')
l5_2011_toa <- stack('L5_2011_TOA.tif')
l5_2011_surfref <- stack('L5_2011_sr.tif')

#Rescale data according to metadata
l5_2011_surfref <- -0.2 + l5_2011_surfref*2.75e-05

#Export raster
writeRaster(l5_2011_surfref, 'L5_2011_sr_rescaled.tif', Format='GTiff', overwrite= TRUE)

#Remove negative values, set negative to 0, above 1 values to 1
l5_2011_surfref <- reclassify(l5_2011_surfref, c(-Inf,0,0,1,Inf,1))

#Plot
plotRGB(l5_2011_rawdn, 3,2,1, stretch='lin')
plotRGB(l5_2011_toa, 3,2,1, stretch='lin')
plotRGB(l5_2011_surfref, 3,2,1, stretch='lin')

#
lambda <- c(480, 560, 655, 865, 1610, 2150)

#Pick a spot with vegetation and show the spectra
plotRGB(l5_2011_surfref, r=4, g=3, b=2, stretch="lin")
pxy<-locator(1) # This function requires an input! -> Click once in the image on a vegetated area --> then wait!

spectrum_rawdn<-extract(l5_2011_rawdn, cbind(pxy$x[1], pxy$y[1]))
spectrum_toa<-extract(l5_2011_toa, cbind(pxy$x[1], pxy$y[1]))
spectrum_surfref<-extract(l5_2011_surfref, cbind(pxy$x[1], pxy$y[1]))
dev.off()

par(mfrow=c(1,3))
plot(lambda, spectrum_rawdn, 
     ylab="raw DN",
     xlab="wavelength (nm)", type='b')
plot(lambda, spectrum_toa, 
     ylab="ToA reflectance",
     xlab="wavelength (nm)", type='b')
plot(lambda, spectrum_surfref, 
     ylab="Surface reflectance",
     xlab="wavelength (nm)", type='b')

#Load terrain correction file
dem <- stack('/Users/huaqo/Downloads/SRTM_ffB01_p045r032.tif')

#Match to images
dem <- resample(dem, l5_2011_surfref)

#Calculate slope and aspect
slp <- terrain (dem, opt='slope')
asp <- terrain (dem, opt='aspect')

#Input sun position
theta_e <- 49.6590900
theta_a <- 144.56665673

#Calculate the hillshade 
hs2011 <- hillShade(slp,asp, angle = theta_e, direction = theta_a)

#Plot hillshade
plot(hs2011, col=grey.colors(255), zlim=c(0,1))
summary(hs2011)

#Reclassify data
hs2011 <- reclassify(hs2011, matrix(c(-Inf, 0, 0.0), 1, 3))

#Topographic normalization with hillshade
l5_2011_topo <- l5_2011_surfref*cos((90-theta_e)/180*pi) / hs2011

#Export
writeRaster(l5_2011_topo, 'l5_2011_topo.tif', format='GTiff', overwrite=TRUE)

#Plot
par(mfrow=c(1,2))
plotRGB(l5_2011_surfref, r=4, g=3, b=2, stretch="lin")
plotRGB(l5_2011_topo, r=4, g=3, b=2, stretch="lin")

#Export Plot
savePlot('topographic correction', type='jpeg')

#Read shapefile with two example points
points <- readOGR('/Users/huaqo/Downloads/shape/points.shp')

#Plot points
plotRGB(l5_2011_surfref,4,3,2, stretch='lin')
plot(points, col=c('green', 'orange'), pch=19, add=TRUE)

#Extract pixel values below points
spectrum_surfref <- extract(l5_2011_surfref, points)
spectrum_topo <- extract(l5_2011_topo, points)

spectrum_surfref
spectrum_topo

#Plot spectra
x11()
par(mfrow=c(2,2))
plot(lambda, spectrum_surfref[2,], 
     ylab="Surface reflectance",
     xlab="wavelength (nm)", type='b', ylim=c(0,0.4), main="no topo - illuminated")
plot(lambda, spectrum_surfref[1,], 
     ylab="Surface reflectance",
     xlab="wavelength (nm)", type='b', ylim=c(0,0.4), main="no topo - shaded")
plot(lambda,spectrum_topo[2,], 
     ylab="Surface reflectance",
     xlab="wavelength (nm)", type='b', ylim=c(0,0.4), main="topo - illuminated")
plot(lambda,spectrum_topo[1,], 
     ylab="Surface reflectance",
     xlab="wavelength (nm)", type='b', ylim=c(0,0.4), main="topo - shaded")
