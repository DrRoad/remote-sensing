// Filter and first composites

// Load Landsat 5 data, filter by date and bounds.
var collection = ee.ImageCollection('LANDSAT/LT05/C01/T1')
  .filterDate('1987-01-01', '1989-12-31')
  .filter(ee.Filter.calendarRange(6,8,'month'))
  .filterBounds(ee.Geometry.Point(13.41, 52.53));

// Also filter the collection by the CLOUD_COVER property.
var filtered = collection
  .filterMetadata('CLOUD_COVER', 'equals', 0);

// Create two composites to check the effect of filtering by CLOUD_COVER.
var unfilteredComposite = collection.mean()
var cloudfreeComposite = filtered.mean()

// Display the composites.
Map.setCenter(13.41, 52.53, 13);
Map.addLayer(unfilteredComposite,
             {bands: ['B4', 'B3', 'B2'], gain: 3.5},
             'unfiltered composite');
Map.addLayer(cloudfreeComposite,
             {bands: ['B4', 'B3', 'B2'], gain: 3.5},
             'cloudless composite');
    