// Assemble a collection of Sentinel-2 surface reflectance images for a given
// region and date range.
var s2col = ee.ImageCollection('COPERNICUS/S2_SR')
  .filterBounds(ee.Geometry.Point(-96.9037, 48.0395))
  .filterDate('2019-06-01', '2019-10-01');

// Define visualization arguments.
var visArgs = {bands: ['B11', 'B8', 'B3'], min: 300, max: 3500};

// Define a function to convert an image to an RGB visualization image and copy
// properties from the original image to the RGB image.
var visFun = function(img) {
  return img.visualize(visArgs).copyProperties(img, img.propertyNames());
};

// Map over the image collection to convert each image to an RGB visualization
// using the previously defined visualization function.
var s2colVis = s2col.map(visFun);

print("s2col", s2colVis)


// Print the animation to the console as a ui.Thumbnail using the above defined
// arguments. Note that ui.Thumbnail produces an animation when the first input
// is an ee.ImageCollection instead of an ee.Image.
print(ui.Thumbnail(s2colVis, visFun));


// Zeigt den Median von allen Bildern
var s2col_comp = s2col.median()
Map.setCenter(-96.9037, 48.0395, 10)
Map.addLayer(s2col_comp, visArgs, "composite")
