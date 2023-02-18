//Let's start with the calculation needed to create a band that shows pixels 
//where the Hansen et al. data show both loss and gain.

//The Hansen et al. dataset has a band whose pixels are 1 where loss occurred 
//and 0 otherwise (loss) and a band that is 1 where gain has occurred and a 0 otherwise (gain). 
//To create a band where pixels in both the loss and the gain bands have a 1, 
//you can use the and() logical method on images. The and() method is called 
//like image1.and(image2) and returns an image in which pixels are 1 where both 
//image1 and image2 are 1, and 0 elsewhere:
// Load the data and select the bands of interest.

var gfc2014 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");
var lossImage = gfc2014.select(['loss']);
var gainImage = gfc2014.select(['gain']);

// Use the and() method to create the lossAndGain image.
var gainAndLoss = gainImage.and(lossImage);

// Show the loss and gain image.
Map.addLayer(gainAndLoss.updateMask(gainAndLoss),
    {palette: 'FF00FF'}, 'Gain and Loss');
    

//Combining this example with the result from the previous section, 
//it's now possible to recreate the figure from the beginning of the tutorial:

// Displaying forest, loss, gain, and pixels where both loss and gain occur.
var gfc2014 = ee.Image('UMD/hansen/global_forest_change_2015');
var lossImage = gfc2014.select(['loss']);
var gainImage = gfc2014.select(['gain']);
var treeCover = gfc2014.select(['treecover2000']);

// Use the and() method to create the lossAndGain image.
var gainAndLoss = gainImage.and(lossImage);

// Add the tree cover layer in green.
Map.addLayer(treeCover.updateMask(treeCover),
    {palette: ['000000', '00FF00'], max: 100}, 'Forest Cover');

// Add the loss layer in red.
Map.addLayer(lossImage.updateMask(lossImage),
    {palette: ['FF0000']}, 'Loss');

// Add the gain layer in blue.
Map.addLayer(gainImage.updateMask(gainImage),
    {palette: ['0000FF']}, 'Gain');

// Show the loss and gain image.
Map.addLayer(gainAndLoss.updateMask(gainAndLoss),
    {palette: 'FF00FF'}, 'Gain and Loss');

