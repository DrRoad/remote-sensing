// Simple composite

var landsat = ee.ImageCollection("LANDSAT/LC08/C01/T1")
    .filterDate('2016-01-01', '2017-01-01')
    .filterBounds(geometry)

Map.addLayer(landsat, {bands: ["B4", "B3", "B2"], min:0, max: 30000})

var composite = ee.Algorithms.Landsat.simpleComposite({
  collection: landsat,
  asFloat: true
})

Map.addLayer(composite, {bands: ["B4", "B3", "B2"], min:0, max: 0.3})
Map.centerObject(geometry, 11)