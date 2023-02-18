// Cloud Masking
function maskL8sr(image) {
  var cloudShadowBitMask = 1 << 4;
  var cloudsBitMask = 1 << 3;

  var qa = image.select('QA_PIXEL');

  var mask = qa.bitwiseAnd(cloudShadowBitMask).eq(0)
      .and(qa.bitwiseAnd(cloudsBitMask).eq(0));

  return image.updateMask(mask)
      .select("SR_B[0-9]*").multiply(0.0000275).add(-0.2)
      .copyProperties(image, ["system:time_start"]);
}

// Load Image
var collection = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2')
    .filterBounds(geometry)
    .filterDate('2020-01-01', '2020-12-31')
    .map(maskL8sr)
    
// Composite
var composite = collection.median();

// Display Layer

//Map.addLayer(composite, {bands: ['SR_B4', 'SR_B3', 'SR_B2'], min: 0, max: 0.5});

// Export Layer
Export.image.toDrive({
  image: composite,
  description: 'MINT',
  region: geometry
});