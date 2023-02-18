var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');

// Subset Finland feature from countries.
var finland = ee.Feature(
  countries
    .filter(ee.Filter.eq('country_na', 'Finland'))
    .first()
);

// Subset protected areas to the bounds of the Finland feature
// and other criteria. Clip to the intersection with Finland.
var protectedAreas = ee.FeatureCollection('WCMC/WDPA/current/polygons')
  .filter(ee.Filter.and(
    //ee.Filter.bounds(finland.geometry()),
    ee.Filter.neq('IUCN_CAT', 'VI'),
    ee.Filter.neq('STATUS', 'proposed'),
    ee.Filter.lt('STATUS_YR', 2020)
  ))
  .map(function(feat){
    return finland.intersection(feat);
  });

// Display protected areas on the map.
Map.addLayer(
  protectedAreas,
  {color: '000000'},
  'Finland protected areas'
);