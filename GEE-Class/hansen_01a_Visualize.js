//The Hansen et al. (2013) Global Forest Change dataset in Earth Engine represents 
//forest change, at 30 meters resolution, globally, between 2000 and 2014. Let's start 
//by adding the Hansen et al. data to the map. Import the global forest change 
//data (learn more about searching and importing datasets) by searching for "Hansen forest" 
//and naming the import gfc2014: 

//Recall that when a multi-band image is added to a map, the first three bands of the 
//image are chosen as red, green, and blue, respectively, and stretched according to the 
//data type of each band. The reason the image looks red is that the first three bands 
//are treecover2000, loss, and gain. The treecover2000 band is expressed as a percent 
//and has values much higher than loss (green) and gain (blue) which are binary ({0, 1}). 
//The image therefore displays as overwhelmingly red.

var gfc2014 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");
Map.addLayer(gfc2014);

//To display forest cover in the year 2000 as a grayscale image, 
//you can use the treecover2000 band, specified in the second argument 
//to Map.addLayer():

Map.addLayer(gfc2014, {bands: ['treecover2000']}, 'treecover2000');

/// 
//Display the band that differentiates land surface and permanent water bodies. 
// Set min and max in the display options!
Map.addLayer(gfc2014, {bands: ['datamask'], min:0, max:2}, 'datamask');


//Here's an image that uses 3 bands, Landsat bands 5, 4, and 3 for 2015. 
// This band combination shows healthy vegetation as green and soil as mauve:

Map.addLayer(
    gfc2014, {bands: ['last_b50', 'last_b40', 'last_b30']}, 'false color');


//One nice visualization of the Global Forest Change dataset shows forest extent 
//in 2000 as green, forest loss as red, and forest gain as blue. 
//Specifically, make loss the first band (red), treecover2000 the second band (green), 
//and gain the third band (blue):
Map.addLayer(gfc2014, {bands: ['loss', 'treecover2000', 'gain']}, 'green');


//We'd like forest loss to show up as bright red and forest gain to show up as bright 
//blue. To fix this, we can use the visualization parameter max to set the range to 
//which the image data are stretched. Note that the max visualization parameter 
//takes a list of values, corresponding to maxima for each band:
Map.addLayer(gfc2014, {
  bands: ['loss', 'treecover2000', 'gain'],
  max: [1, 255, 1]
}, 'forest cover, loss, gain');


/// Improve displaying tree cover (forest extent)

//Use a green palette to display the forest extent image:
Map.addLayer(gfc2014, {
  bands: ['treecover2000'],
  palette: ['000000', '00FF00']
}, 'forest cover palette');

//The image shown in Figure 8 is a bit dark. The problem is that the treecover2000 
//band has a byte data type ([0, 255]), when in fact the values are precentages ([0, 100]). 
//To brighten the image, you can set the min and/or max parameters accordingly. 
// The palette is then stretched between those extrema.
Map.addLayer(gfc2014, {
  bands: ['treecover2000'],
  palette: ['000000', '00FF00'],
  max: 100
}, 'forest cover percent');

//All of the images shown so far have had big black areas were there the data is zero. 
//For example, there are no trees in the ocean. To make these areas transparent, 
//you can mask their values. Every pixel in Earth Engine has both a value and a mask. 
//The image is rendered with transparency set by the mask, with zero being completely 
//transparent and one being completely opaque.

//You can mask an image with itself. For example, if you mask the treecover2000 band 
//with itself, all the areas in which forest cover is zero will be transparent:
Map.addLayer(gfc2014.mask(gfc2014), {
  bands: ['treecover2000'],
  palette: ['000000', '00FF00'],
  max: 100
}, 'forest cover masked');

//You can mask an image by a mask. For example, if you mask the treecover2000 band 
//where all the values are unter 10%, i.e. you want to keep the areas that have at 
//least 10% tree cover, all the areas in which forest cover is zero will be transparent:
var mask10 = gfc2014.select("treecover2000").gte(10)

Map.addLayer(gfc2014.mask(mask10), {
  bands: ['treecover2000'],
  palette: ['000000', '00FF00'],
  min:0, max: 100
}, 'forest cover masked - >10%');


// The same as before but with a threshold of 30%.
var mask30 = gfc2014.select("treecover2000").gte(30)

Map.addLayer(gfc2014.mask(mask30), {
  bands: ['treecover2000'],
  palette: ['000000', '00FF00'],
  min:0, max: 100
}, 'forest cover masked - >30%');




