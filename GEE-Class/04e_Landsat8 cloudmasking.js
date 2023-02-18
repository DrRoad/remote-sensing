// Landsat 8 - Cloud masking

// This example demonstrates the use of the pixel QA band to mask
// clouds in surface reflectance (SR) data.  It is suitable
// for use with any of the Landsat SR datasets.

// Function to cloud mask from the pixel_qa band of Landsat 8 SR data.
function maskL8sr(image) {
  // Bits 3 and 4 are cloud shadow and cloud, respectively.
  var cloudShadowBitMask = 1 << 4;
  var cloudsBitMask = 1 << 3;

  // Get the pixel QA band.
  var qa = image.select('QA_PIXEL');

  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudShadowBitMask).eq(0)
      .and(qa.bitwiseAnd(cloudsBitMask).eq(0));

  // Return the masked image, scaled to reflectance, without the QA bands.
  return image.updateMask(mask)
      .select("SR_B[0-9]*").multiply(0.0000275).add(-0.2)
      .copyProperties(image, ["system:time_start"]);
}

// Map the function over one year of data.
var collection = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2')
    .filterBounds(ee.Geometry.Point(13.4,52.5))
    .filterDate('2016-01-01', '2016-12-31')
    .map(maskL8sr)

var composite = collection.median();

// Display the results.
Map.setCenter(13.4,52.5,10)
Map.addLayer(composite, {bands: ['SR_B4', 'SR_B3', 'SR_B2'], min: 0, max: 0.5});
