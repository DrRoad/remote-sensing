/////// NDVI time series over Landsat 5,7 and 8


// to be defined
Map.centerObject(roi, 12)

var startyear = '1984-01-01'
var endyear = '2021-12-31'

var startmonth = 9
var endmonth = 9

//////////////////////////////////////////////////////////////////////////////////////////////////////

//// Functions that are applied to every image of a collection
// Due to the specific sensor characteristics of TM and OLI, specific function are needed for the sensors

// 1) Cloud masking
// 2) Rename Bands
// 3) Add NDVI and two bands to save the result of the linear regression (gain and constant)

// 1) Cloud masking
// Function to cloud mask from the pixel_qa band of Landsat 5 and 7 SR data.
// (From the Code Editor Examples > Cloud Masking)
function maskL457sr(image) {

  // Bit 0 - Fill
  // Bit 1 - Dilated Cloud
  // Bit 2 - Cirrus
  // Bit 3 - Cloud
  // Bit 4 - Cloud Shadow
  var qa = image.select('QA_PIXEL');
  
  var cloud = qa.bitwiseAnd(1 << 0)
          .or(qa.bitwiseAnd(1 << 1))
          .or(qa.bitwiseAnd(1 << 2))
          .or(qa.bitwiseAnd(1 << 3))
          .or(qa.bitwiseAnd(1 << 4));


  // The flags should equal zero, indicating clear conditions.
  var mask = cloud.eq(0);
 
    // Apply the scaling factors to the appropriate bands.
  var opticalBands = image.select('SR_B1',"SR_B2", "SR_B3","SR_B4","SR_B5","SR_B7").multiply(0.0000275).add(-0.2);

  // Replace the original bands with the scaled ones and apply the masks.
  return image.addBands(opticalBands, null, true)
      .updateMask(mask)
      .copyProperties(image, ['system:time_start']);
}
  


// Function to cloud mask from the pixel_qa band of Landsat 8 SR data.

function maskL8sr(image) {
  // Bit 0 - Fill
  // Bit 1 - Dilated Cloud
  // Bit 2 - Cirrus
  // Bit 3 - Cloud
  // Bit 4 - Cloud Shadow
  var qa = image.select('QA_PIXEL');
  
  var cloud = qa.bitwiseAnd(1 << 0)
          .or(qa.bitwiseAnd(1 << 1))
          .or(qa.bitwiseAnd(1 << 2))
          .or(qa.bitwiseAnd(1 << 3))
          .or(qa.bitwiseAnd(1 << 4));


  // The flags should equal zero, indicating clear conditions.
  var mask = cloud.eq(0);
 
    // Apply the scaling factors to the appropriate bands.
  var opticalBands = image.select('SR_B.').multiply(0.0000275).add(-0.2);

  // Replace the original bands with the scaled ones and apply the masks.
  return image.addBands(opticalBands, null, true)
      .updateMask(mask)
      .copyProperties(image, ['system:time_start']);
}


// 2) Rename Bands

// Function to rename bands of Landsat 5 and 7 to match Landsat 8
function renameBandsTM(image) {
    var bands = ['SR_B1', 'SR_B2', 'SR_B3', 'SR_B4', 'SR_B5', 'SR_B7'];
    var new_bands = ['B', 'G', 'R', 'NIR', 'SWIR1', 'SWIR2'];
    return image.select(bands).rename(new_bands).copyProperties(image, ['system:time_start']);
}

// Function to rename bands of Landsat 8 to match Landsat 5 and 8
function renameBandsOLI(image){
    var bands = ['SR_B2', 'SR_B3', 'SR_B4', 'SR_B5', 'SR_B6', 'SR_B7'];
    var new_bands = ['B', 'G', 'R', 'NIR', 'SWIR1', 'SWIR2'];
    return image.select(bands).rename(new_bands).copyProperties(image, ['system:time_start']);
}


// 3) Add NDVI and two bands to save the result of the linear regression (gain and constant)

// This field contains UNIX time in milliseconds.
var timeField = 'system:time_start';


function addVariables(image) {
  // Compute time in fractional years since the epoch.
  var date = ee.Date(image.get(timeField));
  var years = date.difference(ee.Date('1970-01-01'), 'year');
  // Return the image with the added bands.
  return image
    // Add an NDVI band.
    .addBands(image.normalizedDifference(['NIR', 'R']).rename('NDVI'))
    // Add a time band.
    .addBands(ee.Image(years).rename('gain'))
    .float()
    // Add a constant band.
    .addBands(ee.Image.constant(1));
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////

// Create collections of Landsat 5, 7 and 8

// a) using filters (calendar range and ROI)
// b) using the three functions (cloud masking, rename bands, add NDVI)
// c) Merge the collections --> combine the three collections to form a time series over the entire time span

// Landat 5 surface reflection data
var L5coll = ee.ImageCollection('LANDSAT/LT05/C02/T1_L2')
.filterBounds(roi)
.filter(ee.Filter.calendarRange(startmonth,endmonth, 'month'))
.filterDate(startyear, endyear)
.map(maskL457sr)
.map(renameBandsTM)
.map(addVariables);

// Landat 7 surface reflection data
var L7coll = ee.ImageCollection('LANDSAT/LE07/C02/T1_L2')
.filter(ee.Filter.calendarRange(startmonth,endmonth, 'month'))
.filterDate(startyear, endyear)
.filterBounds(roi)
.map(maskL457sr)
.map(renameBandsTM)
.map(addVariables);


// Landat 8 surface reflection data, rename the band names. See USGS pages for more info
var L8coll = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2')
.filter(ee.Filter.calendarRange(startmonth,endmonth, 'month'))
.filterDate(startyear, endyear)
.filterBounds(roi)
.map(maskL8sr)
.map(renameBandsOLI)
.map(addVariables)



// merge L5, L7 & L8
var collection_merge = ee.ImageCollection(L5coll.merge(L7coll.merge(L8coll)));
print (collection_merge)


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Plot time series for an ROI

// Plot a time series of NDVI at a single location.
var l8Chart = ui.Chart.image.series(collection_merge.select('NDVI'), roi)
    .setChartType('ScatterChart')
    .setOptions({
      title: 'Landsat NDVI time series at ROI',
      trendlines: {0: {
        color: 'CC0000'
      }},
      lineWidth: 1,
      pointSize: 3,
    });
print(l8Chart);


// Display the NDVI of the time series (mean, first image, last image)
Map.addLayer(collection_merge.select("NDVI").mean(),{min:0, max:1}, "Mean NDVI Landsat 8")
Map.addLayer(collection_merge.select("NDVI").first(),{min:0, max:1}, "Oldest image within time series")
Map.addLayer(collection_merge.sort("system:time_start",false).select("NDVI").first(),{min:0, max:1}, "Newest image within time series")


///////////////////////////////////////////////////////////////////////////////////////////////////////

// Trend analysis 
// Calculate the constant and gain of the linear regression of the NDVI on a per-pixel basis

Map.centerObject(roi, 11)

// List of the independent variable names
var independents = ee.List(['constant', 'gain']);

// Name of the dependent variable.
var dependent = ee.String('NDVI');

// Compute a linear trend.  This will have two bands: 'residuals' and 
// a 2x1 band called 'coefficients' (columns are for dependent variables).
var trend = collection_merge.select(independents.add(dependent))
    .reduce(ee.Reducer.linearRegression(independents.length(), 1));
// Map.addLayer(trend, {}, 'trend array image');

// Flatten the coefficients into a 2-band image
var coefficients = trend.select('coefficients')
  .arrayProject([0])
  .arrayFlatten([independents]);

// Plot the two bands as gray scale
Map.addLayer(coefficients.select('gain'), {min:-0.01, max: 0.01}, "gain")
Map.addLayer(coefficients.select('constant'), {},"constant")

// Plot the two bands in a RGB-False colour Composite (positive trends = greenish, negative trends = reddish)
Map.addLayer(coefficients,
    {min: 0, max: [-0.02, 0.02, 0.7], bands: ['gain', 'gain', 'constant']},
    'Trend analysis')
