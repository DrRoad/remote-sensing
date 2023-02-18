//Now that you're more familiar with the bands in the Hansen et al. dataset, 
//we can use concepts learned so far to compute statistics about forest gain 
//and loss in a region of interest. For this we'll need to use vector data 
//(points, lines, and polygons). A vector dataset is represented as a 
//FeatureCollection in Earth Engine. (Learn more about feature collections 
//and how to import vector data.)

//In this section, we'll compare the total amount of forest loss that happened 
//within the Republic of the Congo in the year 2012 to the amount of forest loss that 
//happened within the country's protected areas at the same time.

//As you learned in the Earth Engine API tutorial, the key method for calculating 
//statistics in an image region is reduceRegion(). (Learn more about reducing image 
//regions.) For example, suppose we want to calculate the number of pixels estimated 
//to represent forest loss during the study period. For that purpose, consider the 
//following code.


//The example uses the ee.Reducer.sum() reducer to sum the values of the 
//pixels in lossImage within the Republic of the Congo feature. Because lossImage consists 
//of pixels that have a value of 1 or 0 (for loss or not loss, respectively), 
//the sum of these values is equivalent to the number of pixels of loss in the 
//region.


// Load country features from Large Scale International Boundary (LSIB) dataset.
var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');

// Subset the Republic of the Canada feature from countries.
var germany = countries.filter(ee.Filter.eq('country_na', 'Germany'));

// Get the forest loss image.
var gfc2014 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");
var lossImage = gfc2014.select(['loss']);

// Sum the values of forest loss pixels in Canada.
var stats = lossImage.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: germany,
  scale: 30,
  maxPixels: 2e9
});
print(stats);


//By expanding the object printed to the console, observe that the 
//result is 4897933 (in the original example!) pixels of forest lost. You can 
//clean up the printout in the console a bit by labeling the output 
//and getting the result of interest from the dictionary returned 
//by reduceRegion():

print('pixels representing loss: ', stats.get('loss'));


//You're almost ready to answer the question of how much area was lost in 
//the Republic of the Congo. 
//The remaining part is to convert pixels into actual area. This conversion 
//is important because we don't necessarily know the size of the pixels input 
//to reduceRegion(). To help compute areas, Earth Engine has the ee.Image.pixelArea() 
//method which generates an image in which the value of each pixel is the pixel's 
//area in square meters. Multiplying the loss image with this area image and then 
//summing over the result gives us a measure of area:
// Load country features from Large Scale International Boundary (LSIB) dataset.
var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');

// Subset Republic of the Congo feature from countries.
var germany = countries.filter(ee.Filter.eq('country_na', 'Germany'));

// Get the forest loss image.
//var gfc2014 = ee.Image('UMD/hansen/global_forest_change_2015'); //we did already open that one
var lossImage = gfc2014.select(['loss']);
var areaImage = lossImage.multiply(ee.Image.pixelArea()).divide(1000000);


// Sum the values of forest loss pixels in Canada.
var stats = areaImage.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: germany,
  scale: 30,
  maxPixels: 2e9
});

print('pixels representing loss: ', stats.get('loss'), 'square km');


//You are now ready to answer the question at the start of this section - how 
//much forest area was lost in the Republic of the Congo in 2012, and how much of that 
//was in protected areas? Have a look in the next script.