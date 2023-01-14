library(raster)
library(rgdal)
setwd("~/OneDrive/Dokumente/Fernerkundung/Regio/11_Landwirtschaft")

#### Build NDVI stack ####

# read all files from the directory starting with "CU_LC08.001_SRB4" (OLI - red band)
landsatred <- list.files(pattern="CU_LC08.001_SRB4", path="/Users/huaqo/OneDrive/Dokumente/Fernerkundung/Regio/11_Landwirtschaft/data", full.names=TRUE)

# read all files from the directory starting with "CU_LC08.001_SRB5" (OLI - NIR band)
landsatNIR <- list.files(pattern="CU_LC08.001_SRB5", path="/Users/huaqo/OneDrive/Dokumente/Fernerkundung/Regio/11_Landwirtschaft/data", full.names=TRUE)

# Build stacks for red and NIR bands
landsatred_stack <- stack(landsatred)
landsatNIR_stack <- stack(landsatNIR)

# calculate the NDVI
NDVI_stack <- (landsatNIR_stack-landsatred_stack)/(landsatNIR_stack+landsatred_stack)

#### Crop the dataset to the study area

# read the shapefle
myshp <- readOGR("study_area_sem10.shp")

# Check crs of datasets
crs(NDVI_stack)
crs(myshp)

# Reporject the shapefile
myshp_proj <- spTransform(myshp, crs(NDVI_stack))

# Subset the image data and save it
NDVI_stack_subset <- crop(NDVI_stack, extent(myshp_proj), snap="out", filename="NDVI_timeseries_2019.tif", overwrite=TRUE)

# split the file name with the delimiter "_", read the date and format the dates
name_split  <- sapply(landsatred, function(i) unlist(strsplit(i,"_")))

# identify number of substring containing the date (in my case 6)
View(name_split)
dates <- name_split [6,]
dates <-substring(dates,4,10)
dates <- as.Date(dates, "%Y%j")

# rename the bands according to their date
names(NDVI_stack_subset) <- dates

ndvistack <- stack ("NDVI_timeseries_2019.tif")
#or
#ndvistack <- NDVI_stack_subset

#### Create date vector (needed if NDVI time series is not created above) ####

# read all files from the directory starting with "CU_LC08.001_SRB4" (OLI - red band)
landsatred <- list.files(pattern="CU_LC08.001_SRB4", path="C:\\Users\\marion\\Documents\\2020_maerz\\RegionaleThemen_CA\\seminar10\\data", full.names=TRUE)

# split the file name with the delimiter "_", read the date and format the dates
name_split  <- sapply(landsatred, function(i) unlist(strsplit(i,"_")))

# identify number of substring containing the date (in my case 6)
View(name_split)
dates <- name_split [6,]
dates <-substring(dates,4,10)
dates <- as.Date(dates, "%Y%j")

# rename the bands according to their date
names(ndvistack) <- dates

plotRGB(ndvistack, 1,4,7, stretch="lin")


cal_proj <- shapefile("training_pol_col.shp")

View(cal_proj@data) ## attribute table

crs(cal_proj)
crs(ndvistack)


cal <- spTransform(cal_proj, crs(ndvistack))


cropcol <- rgb(cal$FIRST_RED, cal$FIRST_GREE, cal$FIRST_BLUE)

plotRGB (ndvistack, 1, 3, 5, stretch="lin")
plot (cal, add=T, col=cropcol, border ="black", lwd=3)

calpix <- extract (ndvistack, cal, df=FALSE)

names (calpix) <- cal@data[,1] 

calpix2 <- extract (ndvistack, cal, df=TRUE) 

View(calpix)
View(calpix2)

cl <- rep(cropcol, sapply(calpix, nrow))

classcentroids <- t(sapply (calpix, colMeans)) 

# plot empty plot of a defined size
plot(0,
     ylim = c(min(classcentroids), max(classcentroids)), 
     xlim = c(min(dates), max(dates)), 
     type = 'n', 
     xlab = "time", 
     ylab = "NDVI",
     xaxt='n'
)

# label the x axis
axis(1, dates, format(dates, "%b %d"), cex.axis = .7)


# draw one line for each class
for (i in 1:nrow(classcentroids)){
    lines(dates, as.numeric(classcentroids[i,]), 
          lwd = 4, 
          col = cropcol[i]
    )
}

# add a grid
grid()

# add a legend
legend(as.character(cal@data[,1]),
       x = "topleft",
       col = cropcol,
       lwd = 5,
       bty = "n"
)

d <- c(1,3,5,7)
dates4 <- dates[d]

classcentroids_4bands <- aggregate(calpix2[, c(2,4,6,8)], list(calpix2$ID), mean)

for (i in 1:4){
    for (j in 1:4){
        plot (calpix2[,i+1], calpix2[,j+1], col=cl, pch=19, cex=0.1, 
              xlab=paste ("NDVI ",dates4[i]), ylab=paste ("NDVI ",dates4[j]), xlim= c(-0.3,1),
              ylim= c(-0.3,1)) ## the '+1' is necessary to
        ## skip the first column with the class codes
        points (classcentroids[,i], classcentroids[,j], bg=cropcol, pch=21)
        
        legend("topleft",
               legend = cal@data[,1],
               fill = cropcol,
               border = FALSE,
               box.col="grey",
               cex = 0.7) # t
        readline ("Press ENTER for next plot")
    }}

source ("mindistclassifier.r")

map <- mindistclassifier(class.codes=1:10, cal.ref=classcentroids,
                         image.stack=ndvistack)

plot(map)

plot(map, col = cropcol, legend =FALSE
)

legend("topright",
       legend = cal@data[,1],
       fill = cropcol,
       border = FALSE,
       box.col="grey") # turn off legend border)

map@legend@colortable <- c ("#000000", cropcol, rep ("#000000", 254))
writeRaster (map, "mindist_map.tif", format="GTiff", overwrite=TRUE)

val <- shapefile ("validation_points_v2.shp")
val_proj <- spTransform(val, crs(map))

head(val_proj)

croptypes <- cal@data[,1]

prediction <- extract (map, val_proj) 
prediction <- croptypes[prediction]

cfm <- table (prediction, val@data[,2])
cfm
oac <- sum (diag (cfm)) / sum (cfm)
print(paste("OAC: ", oac))
users <- diag (cfm) / apply (cfm, 1, sum)
users
producers <- diag (cfm) / apply (cfm, 2, sum)
producers
