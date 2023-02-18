// 1. Create country polygon

var countries = ee.FeatureCollection('USDOS/LSIB_SIMPLE/2017');         //load countries data
var country = countries.filter(ee.Filter.eq('country_na', 'Finland'));  //select country

// 2. Get Hansen data

var gfc2020 = ee.Image("UMD/hansen/global_forest_change_2020_v1_8");  // load image
var treeCover = gfc2020.select(['treecover2000']);     // Select Band
var lossImage = gfc2020.select(['loss']);              // Select Band
var gainImage = gfc2020.select(['gain']);              // Select Band

// 3. Get loss area

var lossAreaImage = lossImage.multiply(ee.Image.pixelArea());

// 4. Get all loss per year

var lossYear = gfc2020.select(['lossyear']);

// 5. Get Country loss per year

var lossPerYear = lossAreaImage.addBands(lossYear).reduceRegion({
  reducer: ee.Reducer.sum().group({
    groupField: 1
    }),
  geometry: country,
  scale: 30,
  maxPixels: 1e10
});

// 6. Year values and dictionary

var statsFormatted = ee.List(lossPerYear.get('groups'))
  .map(function(el) {
    var d = ee.Dictionary(el);
    return [ee.Number(d.get('group')).format("20%02d"), d.get('sum')];
  });
var statsDictionary = ee.Dictionary(statsFormatted.flatten());

// 7. Print Chart

var chart = ui.Chart.array.values({
  array: statsDictionary.values(),
  axis: 0,
  xLabels: statsDictionary.keys()
}).setChartType('ColumnChart')
  .setOptions({
    title: 'Yearly Forest Loss in Finland',
    hAxis: {title: 'Year', format: '####'},
    vAxis: {title: 'Area (square meters)'},
    legend: { position: "none" },
    lineWidth: 1,
    pointSize: 3
  });
print(chart);


