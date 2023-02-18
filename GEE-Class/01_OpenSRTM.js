// Open SRTM image and visualize it

// Detailed description: https://developers.google.com/earth-engine/tutorial_api_02

// Instantiate an image with the Image constructor.
var image = ee.Image('CGIAR/SRTM90_V4');

// Zoom to a location.
Map.setCenter(12.978717025594149,47.55544193154224,11); // Center on Königssee - Berchtesgaden.

// datatype
print('SRTM image', image);

// Display the image on the map.
Map.addLayer(image);

// Customizing layer visualization
Map.addLayer(image, {min: 0, max: 3000}, 'custom visualization');

// Customizing layer visualization - color palette
Map.addLayer(image, {min: 0, max: 3000, palette: ['blue', 'green', 'red']},
    'custom palette');
