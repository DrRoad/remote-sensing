setwd("~/Nextcloud/Fernerkundung/Projektbezogenes Arbeiten/05")

install.packages('sf')
install.packages('raster')
install.packages('tidyverse')
install.packages('hsdar')
install.packages('magrittr')

library(sf)
library(raster)
library(tidyverse)
library(hsdar)
library(magrittr)

#Raster einladen
home <- brick('X0066_Y0021.tif') / 10000

#Keine Ahnung
names(home) <- paste0('B', 1:10)

#Plotten
plotRGB(home, 3, 2, 1, stretch = 'lin')

#Ganz Berlin
berlin_composite <- stack('/Users/huaqo/Nextcloud/Fernerkundung/Projektbezogenes Arbeiten/05/level3/complete_berlin.vrt') / 10000
plotRGB(berlin_composite, 3, 2, 1, stretch = 'lin')

#Endmember
image_endmember <- st_read('/Users/huaqo/Nextcloud/Fernerkundung/Projektbezogenes Arbeiten/05_SMA/Endmember.gpkg', quiet = TRUE) %>%
    st_transform(crs = st_crs(home))
class(image_endmember)

#
shade <- tribble(
    ~B1, ~B2, ~B3, ~B4, ~B5, ~B6, ~B7, ~B8, ~B9, ~B10, ~Typ,
    .01, .01, .01, .01, .01, .01, .01, .01, .01, .01, "Schatten"
)

extracted_spectra <- raster::extract(berlin_composite, image_endmember, df = TRUE) %>%
    bind_cols(Typ = image_endmember$Typ) %>%
    select(-ID) %>%
    set_colnames(c(paste0("B", 1:10), "Typ")) %>%
    group_by(Typ) %>%
    summarise(across(contains("B"), mean)) %>%
    add_row(shade)

#
spectra_for_plot <- extracted_spectra %>% 
    pivot_longer(cols = contains("B"), names_to = "var", values_to = "vals") %>%
    mutate(var = fct_relevel(var, function(x) paste0("B", sort(as.numeric(str_extract(x, "[0-9]+"))))))

ggplot(spectra_for_plot) +
    geom_line(aes(x = var, y = vals, color = Typ, group = Typ), lwd = 1) +
    scale_color_discrete(name = "Endmember") +
    labs(x = "Band",
         y = "Reflektanz") +
    theme(legend.position = "bottom")

#Entmischung
em <- speclib(spectra = as.matrix(extracted_spectra[, -1]),
              wavelength = c(490, 560, 665, 705, 740, 783, 842, 865, 1610, 2190),
              continuousdata = FALSE)

image_spectra <- speclib(spectra = getValues(home),
                         wavelength = c(490, 560, 665, 705, 740, 783, 842, 865, 1610, 2190),
                         continuousdata = FALSE)


sma <- unmix(image_spectra, em)

#Visualisierung und Validierung
extent_s2 <- extent(home)

soil_mat <- matrix(sma$fractions[1, ], nrow = 250, ncol = 250, byrow = TRUE)

soil_ras <- raster(soil_mat, crs = crs(home), xmn = extent_s2[1],
                   xmx = extent_s2[2], ymn = extent_s2[3], ymx = extent_s2[4])

veg_mat <- matrix(sma$fractions[2, ], nrow = 250, ncol = 250, byrow = TRUE)

veg_ras <- raster(veg_mat, crs = crs(home), xmn = extent_s2[1],
                  xmx = extent_s2[2], ymn = extent_s2[3], ymx = extent_s2[4])

shadow_mat <- matrix(sma$fractions[3, ], nrow = 250, ncol = 250, byrow = TRUE)

shadow_ras <- raster(shadow_mat, crs = crs(home), xmn = extent_s2[1],
                     xmx = extent_s2[2], ymn = extent_s2[3], ymx = extent_s2[4])

rmse_mat <- matrix(sma$error, nrow = 250, ncol = 250, byrow = TRUE)

rmse_ras <- raster(rmse_mat, crs = crs(home), xmn = extent_s2[1],
                   xmx = extent_s2[2], ymn = extent_s2[3], ymx = extent_s2[4])

sma_raster <- brick(soil_ras, veg_ras, shadow_ras, rmse_ras)

names(sma_raster) <- c("Boden", "Vegetation", "Schatten", "RMSE")

# Alternative
alt_sma_raster <- setValues(home[[1:4]], values = c(t(sma$fractions), sma$error))

names(alt_sma_raster) <- c("Boden", "Vegetation", "Schatten", "RMSE")

compareRaster(sma_raster, alt_sma_raster)

#Abspeichern
writeRaster(sma_raster,"sma_stacked.tif", overwrite = TRUE)
