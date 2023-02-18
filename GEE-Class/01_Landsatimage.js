////// Satellite images and RGB color presentation //////

/// Open a satellite image and create an RGB-Composite

// Load an image.
var image = ee.Image('LANDSAT/LC08/C01/T1_TOA/LC08_044034_20140318');

// Define the visualization parameters.
var visParams = {
  bands: ['B5', 'B4', 'B3'],
  min: 0,
  max: 0.5,
};

// Center the map and set zoom level
Map.setCenter(-122.1899, 37.5010, 10); // San Francisco Bay

// Visualize image
Map.addLayer(image, visParams, 'false color composite');

//// Exercise 1a:
// Play around with the visualization


//// Clip the image to a feature:

// Create a circle by drawing a 20000 meter buffer around a point.
//var roi = ee.Geometry.Point([-122.4481, 37.7599]).buffer(20000);

// Display a clipped version of the mosaic.
// After the layers are visible in the Map view, please do only display the layer "buffer"
//Map.addLayer(image.clip(roi), visParams, 'buffer');

//// Exercise 1b:
// Create a polygon and clip the image to this feature
// 1. Create a polygon with the available tool (freehand or rectangle)
// 2. You will find the feature under imports at the beginning of your script
// 3. Change the function image.clip accordingly
// 4. Re-run the sript
Map.addLayer(image.clip(Rechteck), visParams, 'Rechteck')