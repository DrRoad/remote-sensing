// 1. Create country polygon

var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');
var country = countries.filter(ee.Filter.eq('country_na', 'Finland'));

// 2. Get Hansen data

var gfc2020 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");
var treeCover = gfc2020.select(['treecover2000']);
var lossImage = gfc2020.select(['loss']);
var gainImage = gfc2020.select(['gain']);

// 3. Get area
//.divide(1000000)
var areaTreeCover = treeCover.multiply(ee.Image.pixelArea()).divide(1000000);
var areaLossImage = lossImage.multiply(ee.Image.pixelArea()).divide(1000000);
var areaGainImage = gainImage.multiply(ee.Image.pixelArea()).divide(1000000);

// 4. Compute forest loss and gain in square km.
var stats = areaTreeCover.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: country,
  scale: 30,
  maxPixels: 2e9
});
print('Tree cover 2000: ', stats.get('treecover2000'), 'square km');

var stats = areaLossImage.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: country,
  scale: 30,
  maxPixels: 2e9
});
print('Loss 2000-2020: ', stats.get('loss'), 'square km');

var stats = areaGainImage.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: country,
  scale: 30,
  maxPixels: 2e9
});
print('Gain 2000-2020: ', stats.get('gain'), 'square km');

