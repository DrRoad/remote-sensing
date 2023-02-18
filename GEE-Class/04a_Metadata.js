// Metadata of image collections

// Load a Landsat 8 ImageCollection for a single path-row.
var collection = ee.ImageCollection('LANDSAT/LC08/C01/T1_TOA')
    .filter(ee.Filter.eq('WRS_PATH', 44))
    .filter(ee.Filter.eq('WRS_ROW', 34))
    .filterDate('2014-03-01', '2014-08-01');
print('Collection: ', collection);

// Get the number of images.
var count = collection.size();
print('Count: ', count);

// Get the date range of images in the collection.
var range = collection.reduceColumns(ee.Reducer.minMax(), ["system:time_start"])
print('Date range: ', ee.Date(range.get('min')), ee.Date(range.get('max')))

// Get statistics for a property of the images in the collection.
var sunStats = collection.aggregate_stats('SUN_ELEVATION');
print('Sun elevation statistics: ', sunStats);

// Sort by a cloud cover property, get the least cloudy image.
var image = ee.Image(collection.sort('CLOUD_COVER').first());
print('Least cloudy image: ', image);

// Limit the collection to the 10 most recent images.
var recent = collection.sort('system:time_start', false).limit(10);
print('Recent images: ', recent);
    