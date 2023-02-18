//It's almost possible to make a visualization of the Hansen data like the one at the 
//beginning of the tutorial. In this example, we're putting everything together 
//with one small difference. Instead of specifying the bands parameter in the 
//Map.addLayer call, we're creating new images using select():
var gfc2014 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");


var treeCover = gfc2014.select(['treecover2000']);
var lossImage = gfc2014.select(['loss']);
var gainImage = gfc2014.select(['gain']);

// Add the tree cover layer in green.
Map.addLayer(treeCover.updateMask(treeCover),
    {palette: ['000000', '00FF00'], max: 100}, 'Forest Cover');

// Add the loss layer in red.
Map.addLayer(lossImage.updateMask(lossImage),
            {palette: ['FF0000']}, 'Loss');

// Add the gain layer in blue.
Map.addLayer(gainImage.updateMask(gainImage),
            {palette: ['0000FF']}, 'Gain');
