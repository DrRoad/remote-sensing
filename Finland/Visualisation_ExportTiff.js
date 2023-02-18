// 1. Create country polygon

var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');
var country = countries.filter(ee.Filter.eq('country_na', 'Finland'));

// 2. Get Hansen data

var gfc2014 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");
var treeCover = gfc2014.select(['treecover2000']);
var lossImage = gfc2014.select(['loss']);
var gainImage = gfc2014.select(['gain']);







// 3. Export cloud-optimized GeoTIFFs.

var projection = treeCover.select('treecover2000').projection().getInfo();
Export.image.toDrive({
  image: treeCover,
  description: 'treeCover',
  crs: projection.crs,
  crsTransform: projection.transform,
  region: country,
  maxPixels: 806400000001,
  fileFormat: 'GeoTIFF',
  formatOptions: {
    cloudOptimized: true
  }
});

var projection = lossImage.select('loss').projection().getInfo();
Export.image.toDrive({
  image: lossImage,
  description: 'lossImage',
  crs: projection.crs,
  crsTransform: projection.transform,
  region: country,
  maxPixels: 806400000001,
  fileFormat: 'GeoTIFF',
  formatOptions: {
    cloudOptimized: true
  }
});

var projection = gainImage.select('gain').projection().getInfo();
Export.image.toDrive({
  image: gainImage,
  description: 'gainImage',
  crs: projection.crs,
  crsTransform: projection.transform,
  region: country,
  maxPixels: 806400000001,
  fileFormat: 'GeoTIFF',
  formatOptions: {
    cloudOptimized: true
  }
});
