// 1. Create country polygon

var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');         //load countries data
var country = countries.filter(ee.Filter.eq('country_na', 'Finland'));  //select country

// 2. Get Hansen data

var gfc2020 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");  // load image
var treeCover = gfc2020.select(['treecover2000']);     // Select Band
var lossImage = gfc2020.select(['loss']);              // Select Band
var gainImage = gfc2020.select(['gain']);              // Select Band

// 3. Add layers

Map.setCenter(27, 65, 5); // Set Center.

Map.addLayer(treeCover.clip(country).updateMask(treeCover), // Add the Forest Cover Image.
            {palette: ['000000', '00FF00'], max: 100}, 
            'Forest Cover');
Map.addLayer(lossImage.clip(country).updateMask(lossImage), // Add the Loss Image.
            {palette: ['FF0000']}, 
            'Loss');
Map.addLayer(gainImage.clip(country).updateMask(gainImage), // Add the Gain Image.
            {palette: ['0000FF']}, 
            'Gain');


var gainAndLoss = gainImage.and(lossImage); // Use the and() method to create the lossAndGain image.

Map.addLayer(gainAndLoss.updateMask(gainAndLoss), // Add the loss and gain image.
    {palette: 'FF00FF'}, 'Gain and Loss');

var styleParams = {   // Style for Borders
  fillColor: '00000000',
  color: '000000',
  width: 3.0};
  
var country = country.style(styleParams);  // Add Border geometry
Map.addLayer(country, {}, 'Borders');
