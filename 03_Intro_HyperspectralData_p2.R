install.packages ("hsdar")
install.packages ("raster")
install.packages ("rgdal")

library (hsdar)
library (raster) 
library (rgdal)

spec.berlin <- read.delim2("/Users/huaqo/Nextcloud/Fernerkundung/Projektbezogenes Arbeiten/03/SpecLib_Berlin_Urban_Gradient_2009.txt", header=TRUE)

class(spec.berlin)

View(spec.berlin)

#load a spectral matrix
specs <- t(as.matrix(spec.berlin))

class(specs)

?speclib

#create a spectral library
sl.berlin <- speclib(specs[-1, ], (specs[1, ])*1000)

class(sl.berlin)

sl.berlin

# Create a plot
plot (sl.berlin, FUN=1, ylim=c (0, 0.8))

# add verticel lines at the wavelength of blue, green and red
abline (v=450, col="blue")
abline (v=550, col="green")
abline (v=630, col="red")

# create a vector of colors
colbar = rainbow(10)

# Choose soectra to be plotted
spectra = c(1,10,15,18,22,25,30,35,40)

# Add these spectra to a plot
plot (sl.berlin, FUN=1, ylim=c ( 0, 0.8), col=colbar[1], lwd=2) ## plot
plot (sl.berlin, FUN=10 , new=F, col=colbar[2], lwd=2) ## add
plot (sl.berlin, FUN= 15, new=F, col=colbar[3], lwd=2)
plot (sl.berlin, FUN=18 , new=F, col=colbar[4], lwd=2)
plot (sl.berlin, FUN=22, new=F, col=colbar[5], lwd=2)
plot (sl.berlin, FUN=25, new=F, col=colbar[6], lwd=2)
plot (sl.berlin, FUN=30 , new=F, col=colbar[7], lwd=2)
plot (sl.berlin, FUN=35, new=F, col=colbar[8], lwd=2)
plot (sl.berlin, FUN=35, new=F, col=colbar[9], lwd=2)

#Add a legend
legend ("topright", legend=idSpeclib(sl.berlin[spectra]) , col=colbar, lwd=2, ncol=2, cex=0.7)

#Load hyperstectral image
im <- stack("/Users/huaqo/Nextcloud/Fernerkundung/Projektbezogenes Arbeiten/03/hymap_subset2/hymap_subset.bsq")

im.wl <- c(
  0.455400, 0.469400, 0.484300, 0.499100, 0.513800, 0.528800, 0.543600,
  0.558400, 0.573100, 0.588100, 0.602900, 0.617600, 0.632000, 0.646500,
  0.660900, 0.675500, 0.690000, 0.704500, 0.718900, 0.733200, 0.747600,
  0.761800, 0.775900, 0.790100, 0.804600, 0.818800, 0.832900, 0.847100,
  0.861100, 0.874700, 0.887800, 0.893000, 0.908500, 0.923900, 0.939400,
  0.955200, 0.970400, 0.985800, 1.001400, 1.016600, 1.031800, 1.046900,
  1.062000, 1.076600, 1.091300, 1.106200, 1.120800, 1.135300, 1.149700,
  1.164100, 1.178600, 1.192800, 1.206900, 1.221000, 1.235100, 1.249200,
  1.263100, 1.277000, 1.290700, 1.304300, 1.318300, 1.330100, 1.505000,
  1.518800, 1.532600, 1.546300, 1.559800, 1.573200, 1.586400, 1.599500,
  1.612700, 1.625900, 1.638900, 1.651700, 1.664400, 1.677100, 1.689600,
  1.702100, 1.714600, 1.726900, 1.739300, 1.751500, 1.763600, 1.775600,
  1.787600, 1.798100, 2.027500, 2.046700, 2.065500, 2.084100, 2.102500,
  2.120900, 2.139000, 2.157000, 2.174700, 2.191700, 2.210300, 2.228100,
  2.245600, 2.263400, 2.280400, 2.297400, 2.314400, 2.331400, 2.348300,
  2.365000, 2.381500, 2.397700, 2.414100, 2.430300, 2.446500)*1000

plotRGB (im, 51, 34, 13, stretch="lin") 

# Open the image in a new window
plotRGB(im, r=70, g=50, b=14, scale=255, stretch="lin")

#``loactor()`` function
pxy<-locator(4)


# extract spectral information
spectrum11<-extract(im, cbind(pxy$x[1], pxy$y[1]))
spectrum12<-extract(im, cbind(pxy$x[2], pxy$y[2]))
spectrum13<-extract(im, cbind(pxy$x[3], pxy$y[3]))
spectrum14<-extract(im, cbind(pxy$x[4], pxy$y[4]))

#plot the spectra

plot(im.wl, spectrum11[1,], type = "b", col = "cyan", ylim=c(0,0.5),ylab="reflectance",
     xlab="wavelength [nm]")
lines(im.wl, spectrum12[1,], type = "b", col = "red")
lines(im.wl, spectrum13[1,], type = "b", col = "green")
lines(im.wl, spectrum14[1,], type = "b", col = "blue")

legend("topright", legend = c("spectrum 1","spectrum 2", "spectrum 3","spectrum 4"), fill = c("cyan", "red", "green", "blue"))

#Calculate an index
NDVI <- ((im[[34]] - im[[14]])/im[[34]] + im[[14]])
#Plot the index
plot(NDVI, main="NDVI August 2009")
plot(NDVI, main="NDVI August 2009",zlim=c(-0.1,1))
plot(NDVI, main="NDVI August 2009",zlim=c(-0.1,1), col=grey.colors(255))
mycol = colorRampPalette(c("tan4", "yellow", "forestgreen"))
plot(NDVI, main="NDVI August 2009",zlim=c(-0.1,1),col=mycol(255))
mycol = colorRampPalette(c("tan4", "yellow", "forestgreen"))
plot(NDVI, main="NDVI August 2009",zlim=c(-0.1,1),col= mycol(5))

#Create a matrix that has following structure:
# min max newValue
# min2 max2 new Value2

# I have started the first class with -Inf as this makes sure that any negative value is included in the first class.
reclass_matrix <- matrix(c(-Inf,0.3,1,0.3,1,2),ncol=3, byrow=TRUE)
reclass_matrix

NDVI_reclass <- reclassify(NDVI, reclass_matrix)

plot(NDVI_reclass, col=c("tan4", "forestgreen"))
plot(NDVI_reclass, col=mycol(2))
