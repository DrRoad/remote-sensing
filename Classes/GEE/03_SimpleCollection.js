
////// Skript 3: First Image Collection ///////

//// Open an image collection
// An image collection refers to a set of Earth Engine images. For example, the collection of all Landsat 8 
// surface reflectance images is an ee.ImageCollection.

var l8 = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2'); 
print('Landsat 8 collection', l8);

// Question 1: Which error occurs when printing the contents of the variable l8?
// Before the second run, comment the line "print('Landsat 8 collection', l8);"

// No worries: we can still work with all the images… 


//// Filter the collection

// The way to limit the collection by time or space is by filtering it.
// For example, to filter the collection to images that cover a particular location, 
// first define your area of interest with a point (or line or polygon) using the geometry drawing tools.

var spatialFiltered = l8.filterBounds(point); 
print('spatialFiltered', spatialFiltered);

var temporalFiltered = spatialFiltered.filterDate('2015-01-01', '2015-12-31'); 
print('temporalFiltered', temporalFiltered);

//// Exercise 3a: 
// - Create a point somewhere and name it “point”. Of course you might give it another name, 
// but then you need to change the code accordingly.
// - Have a look at another time period.


//// How to work with the collection

// Alternative 1: Visualize the Image collection as is

// Note: You may directly visualize the image collection but then only the newest one will be 
// visualized (if you do not specify it otherwise) 
var visParams = {bands: ['SR_B4', 'SR_B3', 'SR_B2'], min: 0, max: 30000};
Map.centerObject(temporalFiltered, 9); 
Map.addLayer(temporalFiltered, visParams, 'l8 collection');


//// Alternative 2: How to use single images from the stack

// We may see and use the images that the collection contains. 
var listofimages = temporalFiltered.toList(temporalFiltered.size()); 
print('List of images', listofimages);

// We may then assign the images to a variable. We start counting with 0. 
var firstimage = listofimages.get(0);
var tenthimage = listofimages.get(9);
var lastimage = listofimages.get(listofimages.length().subtract(1)); 
print('tenth image', tenthimage);

// Visualize the 10th image 
Map.addLayer(ee.Image(tenthimage), visParams, '10th image');
 

//// Alternative 3: Use the least cloudy image

// This will sort from least to most cloudy.
var sorted = temporalFiltered.sort('CLOUD_COVER');
print("sorted", sorted)

// Get the first (least cloudy) image. 
var scene = sorted.first();

// Visualize the least cloudy image print("cloudless", scene)
Map.addLayer(scene, visParams, 'Least cloudy image');

//// Exercise 3a:
// - Use the Landsat 5 collection (surface reflectance).
// - Which images are available from the year of your birthday and your place of birth?
// - Are there any images from your month of birth?
// - Visualize the image that comes closest to your birthday
// - Plot the least cloudy image

// Of course you may use any other event. In this case you need to see if the Landsat 5 collection 
// is the right one to use.
