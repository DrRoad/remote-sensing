#Read hyperspectral image
im <- stack('hymap_subset_hr.bsq') #load stack

#Vector of the wavelength bands in nm of the hyperspectral image (from header file)
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

#Plot the image
plotRGB (im, r=255, g=255, b=255, stretch='lin')

#Open vector data
trees <- readOGR('trees_selection_sp_withoutNA.shp')

#Plot the tree data on top of the hyperspectral data
plotRGB(im, 25,14,5, stretch = 'lin')
plot(trees, cex=0.5, pch=19, col = 'yellow', add=TRUE)

#Summary
summary(trees)

#View attribute table
View(trees@data)

#Access column of attribute table
trees$GATTUNG_DE

#Access all unique values of one column
levels(as.factor(trees$GATTUNG_DE))

#Access one row or point
trees[5,]@data

#Plot one Tree on the image
plotRGB(im, 25, 14, 5, stretch = 'lin')
plot(trees[5,], cex=2, pch=19, col = "yellow", add = TRUE)

#Plot only AHORN & ROSSKASTANIE trees on the image

plotRGB(im, 25,14,5, stretch = 'lin')
plot(trees[trees$GATTUNG_DE == 'AHORN',], cex=1, pch=19, col="yellow", add = TRUE)
plot(trees[trees$GATTUNG_DE == 'ROSSKASTANIE',], cex=1, pch=19, col = 'blue', add = TRUE)

#Extract pixel values from raster
pixel_extract <- extract(im, trees, df = TRUE)

#Establish relationship between the ID of each pixel and the class
pixel_extract_gattung_de <- as.factor(trees$GATTUNG_DE[match(pixel_extract$ID, seq(nrow(trees)))])

#Delete the ID column
pixel_extract <- pixel_extract[-1]

#Calculate mean spectral profiles
sp <- aggregate( . ~ gattung_de, data = pixel_extract, FUN = mean, na.rm = TRUE)

##### Plot mean spectral profiles
# plot empty plot of a defined size
plot(1, ylim = c(0,0.5), 
     xlim = c(7, nlayers(im)), 
     type = 'n', 
     xlab = "Hymap bands", 
     ylab = "reflectance",
)

# define colors for class representation - one color per class necessary!
mycolors <- rainbow(nrow(sp))

# draw one line for each class
for (i in 1:nrow(sp)){
  lines(as.numeric(sp[i, -1]), 
        lwd = 2, 
        col = mycolors[i]
  )
}

# add a grid
grid()

# add a legend
legend(as.character(sp$gattung),
       x = "topleft",
       col = mycolors,
       lwd = 1,
       bty = "n",
       cex = 0.75,
       ncol = 3
)

# plot empty plot of a defined size
plot(1, ylim = c(0,0.5), 
     xlim = c(min(im.wl), max(im.wl)), 
     type = 'n', 
     xlab = "wavelength (nm)", 
     ylab = "reflectance",
)

# define colors for class representation - one color per class necessary!
mycolors <- rainbow(nrow(sp))

# draw one line for each class
for (i in 1:nrow(sp)){
  lines(im.wl, as.numeric(sp[i, -1]), 
        lwd = 2, 
        col = mycolors[i]
  )
}

# add a grid
grid()

# add a legend
legend(as.character(sp$gattung),
       x = "topleft",
       col = mycolors,
       lwd = 1,
       bty = "n",
       cex = 0.75,
       ncol = 3
)
