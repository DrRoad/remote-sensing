// Calculate slope and aspect
// Calculate statistics

//Detailed description: https://developers.google.com/earth-engine/tutorial_api_03

// Load the SRTM image.
var srtm = ee.Image('CGIAR/SRTM90_V4');

// Apply an algorithm to an image.
var slope = ee.Terrain.slope(srtm);

print(slope)
// Convert degree in percent

// Display the result.
Map.setCenter(12.978717025594149,47.55544193154224,11); // Center on Königsee.
Map.addLayer(srtm, {min: 0, max :2500}, 'srtm');
Map.addLayer(slope, {min: 0, max :60}, 'slope');


//Image math
// Get the aspect (in degrees).
var aspect = ee.Terrain.aspect(srtm);
// Convert to radians, compute the sin of the aspect.
var sinImage = aspect.divide(180).multiply(Math.PI).sin();
// Display the result.
Map.addLayer(sinImage, {min: -1, max: 1}, 'sin');



// Image statistics
// Compute the mean elevation in the polygon.
var stddevDict = srtm.reduceRegion({
  reducer: ee.Reducer.stdDev(),
  geometry: koenigsee,
  scale: 90
});

// Print dictionary
print("dict", stddevDict)

// Get the mean from the dictionary and print it.
// In java a dictionary is a collection of different kinds of information.
// In other languages such as R a dictionary is usally named 'object'.

var stddev = stddevDict.get('elevation');
print('stdDev elevation', stddev);

