////// Script 2: Calculate indices and apply a mask //////

// Load an image.
var image = ee.Image('LANDSAT/LC08/C01/T1_TOA/LC08_044034_20140318');

// Center map view
Map.centerObject(image,10)

// Create an NDWI image, define visualization parameters and display. 
var ndwi = image.normalizedDifference(['B3', 'B5']);
var ndwiViz = {min: 0.5, max: 1, palette: ['00FFFF', '0000FF']}; 
Map.addLayer(ndwi, ndwiViz, 'NDWI');
Map.addLayer(ndwi, ndwiViz, 'NDWI false', false); 

// Question 1: What's "false" doing?
//Zeigt den Layer nicht an.

// Mask the non-watery parts of the image, where NDWI < 0.4. 
var ndwiMasked = ndwi.updateMask(ndwi.gte(0.4)); 
Map.addLayer(ndwiMasked, ndwiViz, 'NDWI masked');

// Question 2: What does the function .gte actually do?
//Maskiert alles wo der NDWI unter 0.4 ist.

//// Create visualization layers.
// The .visualize function creates images that contain the visualisation parameters. 
var imageRGB = image.visualize({bands: ['B3', 'B2', 'B1'], max: 0.5});
var ndwiRGB = ndwiMasked.visualize({min: 0.5, max: 1, palette: ['00FFFF', '0000FF']});
Map.addLayer(imageRGB, {}, 'imageRGB');
Map.addLayer(ndwiRGB, {}, 'NDWI masked - 2'); //looks the same than the fist visualization, just another layer

// Mosaic the visualization layers and display.
var mosaic = ee.ImageCollection([imageRGB, ndwiRGB]).mosaic(); 
Map.addLayer(mosaic, {}, 'mosaic');

//Question 3: What does the mosaic function do?
//Fügt das RGB Image und das NDWI Image zusammen.






// Exercise 2a:
// Calculate the NDVI and visualize it
var ndvi = image.normalizedDifference(['B4', 'B5']);

// Find a threshold for differentiating vegetated and non-vegetated areas
var ndviViz = {min: -1, max: 1}; 
Map.addLayer(ndvi, ndviViz, 'NDVI');

// Create a mask that masks non-vegetated areas
// Mask the non-planty parts of the image, where NDVI < 0. 
var ndviMasked = ndvi.updateMask(ndvi.gte(0)); 

// Find a nice visualization
var ndviRGB = ndviMasked.visualize({min: -1, max: 1, palette: ['00FFFF', '0000FF']});
Map.addLayer(ndviRGB, {}, 'NDVI masked');

// Create a mosaic of the Landsat image and the NDVI data.
var mosaic = ee.ImageCollection([imageRGB, ndviRGB]).mosaic(); 
Map.addLayer(mosaic, {}, 'mosaic');



