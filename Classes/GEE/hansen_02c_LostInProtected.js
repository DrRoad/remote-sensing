//You are now ready to answer the question at the start of this 
//section - how much forest area was lost in the Republic of the Congo in
//2012, and how much of that was in protected areas?

// Load country features from Large Scale International Boundary (LSIB) dataset.
var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');

// Subset the Congo Republic feature from countries.
var congo = ee.Feature(
  countries
    .filter(ee.Filter.eq('country_na', 'Rep of the Congo'))
    .first()
);

// Subset protected areas to the bounds of the feature of the Republic of the Congo
// and other criteria. Clip to the intersection with the Republic of the Congo.
var protectedAreas = ee.FeatureCollection('WCMC/WDPA/current/polygons')
  .filter(ee.Filter.and(
    ee.Filter.bounds(congo.geometry()),
    ee.Filter.neq('IUCN_CAT', 'VI'),
    ee.Filter.neq('STATUS', 'proposed'),
    ee.Filter.lt('STATUS_YR', 2010)
  ))
  .map(function(feat){
    return congo.intersection(feat);
  });

// Get the loss image.
var gfc2014 = ee.Image('UMD/hansen/global_forest_change_2015');
var lossIn2012 = gfc2014.select(['lossyear']).eq(12);
var areaImage = lossIn2012.multiply(ee.Image.pixelArea());

// Calculate the area of loss pixels in the Republic of the Congo.
var stats = areaImage.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: congo.geometry(),
  scale: 30,
  maxPixels: 1e9
});

print(
  'Area lost in the Republic of the Congo:',
  stats.get('lossyear'),
  'square meters'
);

// Calculate the area of loss pixels in the protected areas.
var stats2 = areaImage.reduceRegion({
  reducer: ee.Reducer.sum(),
  geometry: protectedAreas.geometry(),
  scale: 30,
  maxPixels: 2e9
});

print(
  'Area lost in protected areas:',
  stats2.get('lossyear'),
  'square meters'
);


//The only changes between this script and the one just prior are the 
//addition of the protected area information and changing the script 
//from looking at overall loss to looking at loss in 2012. This required 
//two changes. First, there's a new lossIn2012 image which has a 1 where loss
//was recorded in 2012, 0 otherwise. Second, because the name of the band is different 
//(lossyear instead of loss) the property name had to change in the print statement.
