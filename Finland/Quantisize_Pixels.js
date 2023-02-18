// 1. Create country polygon

var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');
var country = countries.filter(ee.Filter.eq('country_na', 'Finland'));

// 2. Get Hansen data

var gfc2020 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");
var treeCover = gfc2020.select(['treecover2000']);
var lossImage = gfc2020.select(['loss']);
var gainImage = gfc2020.select(['gain']);

// 3. Calculating loss and Gain Pixels

var stats = lossImage.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: country,
  scale: 30,
  maxPixels: 2e9
});

print('pixels representing loss: ', stats.get('loss'));

var stats = gainImage.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: country,
  scale: 30,
  maxPixels: 2e9
});

print('pixels representing gain: ', stats.get('gain'));

