#Minimum Noise Fractioning and narrow band vegetation indices
#### 1. Preparation ####
##### 1.1 Packages, working directory and reading the data #####
install.packages('raster')
install.packages('rgdal')
install.packages('RStoolbox')

library(raster)
library(rgdal)
library(RStoolbox)

setwd('/Users/huaqo/OneDrive/Dokumente/Fernerkundung/Regio/10_Dürreperioden')

unzip("EO1H0440342014184110KC_1T.ZIP")

files <- dir(pattern='TIF')

##### 1.2 Set scaling factors and cropping extent #####
scaling.factor <- c(rep(40,70), rep(80,172)) 

ex <- extent(566600, 572900, 4139900, 4149300) 

##### 1.3 Cropping and scaling the data #####
hyp_bands <- stack(files)

hyp <- crop(hyp_bands,ex)*scaling.factor
!!!

#### 2. Checking the data quality ####
##### 2.1 Visual inspection of the data quality #####
plotRGB (hyp, 50, 20, 10, stretch="lin") 

wl <- as.vector(t(read.table("hyperion.txt")))  

x11()
for (i in 1:242){
    plot (hyp[[i]], 
          col=gray.colors (255, 0, 1, 1), 
          zlim=c(minValue(hyp)[i], 
          maxValue(hyp)[i]), 
          main=paste (wl[i], 
          "nm"))
    Sys.sleep (0.5)}

##### 2.2 Remove bad bands #####
badbands <- c (1:7,58:78,121:127, 167:178, 224:242)

wl <- wl[-badbands] 

hyp <- dropLayer(hyp,badbands) 

#### 3. Principal component analysis (PCA) ####
##### 3.1 PCA #####
pca <- rasterPCA(hyp, spca=T, nSamples=10000) 

##### 3.2 Inspection of the PCA results #####
plot(pca$model$sdev)

plot(cumsum((pca$model$sdev)^2/sum((pca$model$sdev)^2)),ylab="accumulated explained variance",xlab="PC")

cumsum((pca$model$sdev)^2/sum((pca$model$sdev)^2))[1:10]

pcax <- pca$map
pcaim <- setValues(hyp,pcax) 
plotRGB (pca$map, 1, 2, 3, stretch="lin") 
plotRGB (pca$map, 3, 4, 5, stretch="lin") 

x11()
for (i in 1: 10) { 
    plot(pca$map[[i]], 
         col=gray.colors (255, 0, 1, 1) , 
         main=paste("PC", i)) 
    Sys.sleep (1) 
} 

#### 4. Minimum Noise Fractioning ####
##### 4.1 Backward rotation #####
##### 4.2 Implementation #####
backrot <- function (sc, i) { 
    floor(apply(t(pca$model$loadings[,1:i]) * sc, 2, sum) * pca$model$scale + pca$model$center)
}

pca_val <- getValues(pca$map)

mnfval <- apply(pca_val[,1:4], 1, backrot, i=4)

mnfhyp <- setValues(hyp,t(mnfval))

par(mfrow=c(1,2))
plotRGB(hyp, 40,20,10, stretch="lin")
plotRGB(mnfhyp, 40,20,10, stretch="lin")

#### 5. Evalutation of the MNF-result ####
##### 5.1 Calculating the pseudo-reflectance #####

hyp_scaled <- (hyp - minValue(hyp))/maxValue(hyp)

mnfhyp_scaled <- (mnfhyp-minValue(mnfhyp))/maxValue(mnfhyp)

##### 5.2 Comparison #####

par(mfrow=c(1,2))
plot(hyp_scaled[[10]], zlim=c(0,1))
plot(mnfhyp_scaled[[10]], zlim=c(0,1))

## before=original image, after=mnf, 
## wl=band wavelengths 
testspec <- function(before, after, wl){ 
    x1 <- click (before, n=1, type="p", xy=T, show=F) ## extract original spectrum 
    ## and pixel coordinates 
    x2 <- extract(after, x1[1:2]) ## extract MNF-transformed spectrum 
    x1 <- x1[-c(1:2)] ## remove coordinates 
    x11() ## open new graphic window, comment if you do not want to do so 
    plot (wl, x1*100, type="l", ylim=c(0, 100) , ylab="pseudo-reflectance/%", 
          xlab="wavelength/nm") ## plot original spectrum 
    lines (wl, x2*100, col=2) ## add MNF-spectrum 
    legend ("topright", c("before", "after"), lwd=1, col=c(1,2)) ## add legend 
}

x11()
plotRGB (mnfhyp_scaled, 35, 20, 1, stretch="lin") 

testspec(hyp_scaled, mnfhyp_scaled, wl) 

#### 6. Detecting water stress ####

nm819 <- (mnfhyp_scaled[[39]] + mnfhyp_scaled[[40]])/2 
nm1599 <- mnfhyp_scaled[[110]] 

msi <- nm1599 / nm819 

msi <- reclassify (msi, matrix (c(-Inf, 0, 0, 2, Inf, 2),2,3, byrow=T)) 

plot (msi, col=bpy.colors (100)) 
