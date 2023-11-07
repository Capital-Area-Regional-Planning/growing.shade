Methods
================

We would like to thank the developers, advisors, consultants, and 
all other contributors to the original Growing Shade tool.
  
Methods and data sources for the analyses presented within the Growing
Shade are detailed below. Please
<a href = "mailto:mattn@capitalarearpc.org?subject=growing%shade%20tool">contact
us</a> if you have questions or feedback.

<h2>
<span style="font-size:16pt">Prioritization layer</span>
</h2>

Priority variables were sourced from several locations including:

- Demographic and socioeconomic information comes from the
  <a href = 'https://www.census.gov/programs-surveys/decennial-census/decade/2020/2020-census-results.html' target = '_blank'>2020
  decennial census</a> and
  <a href = 'https://www.census.gov/programs-surveys/acs/data.html' target = '_blank'>American
  Community Survey 5-Year Summary</a>. Census block group data is used.
- Health information comes from the
  <a href="https://www.cdc.gov/places/index.html" target="_blank">PLACES
  dataset</a> published by the Center of Disease Control and Prevention and the
  <a href="https://www.epa.gov/ejscreen" target="_blank">EJScreen
  dataset</a> published by the Environmental Protection Agency.
  Health data is reported by census tract.
- Historic redlining data is obtained from
  <a href = 'https://dsl.richmond.edu/panorama/redlining/#loc=5/39.1/-94.58&text=downloadsMapping' target = "_blank">
  Mapping Inequality</a>.
- Tree canopy and green space information is obtained from the
  <a href = 'https://www.esa.int/Applications/Observing_the_Earth/Copernicus/Sentinel-2' target = "_blank">Copernicus
  Sentinel-2 satellite mission</a>.
- Climate data for temperatures was processed using 
	<a href = 'https://earthengine.google.com/' target = "_blank">Google
	Earth Engine</a> to detect the hottest summer temperature during a year.
	<br>
	Script source: Ermida, S.L., Soares, P., Mantas, V., Göttsche, F.-M., Trigo, I.F., 2020. Google Earth Engine open-source code
	for Land Surface Temperature estimation from the Landsat series. Remote Sensing, 12 (9), 1471; https://doi.org/10.3390/rs12091471	
- Climate data for flood risk was processed using FEMA primary floodplains hosted by
  <a href = 'https://geodata.wisc.edu/catalog/E2CE7AA7-7E6B-4E6C-9237-DA55D4AB69CC' target = '_blank'>
  GeoData@Wisconsin</a>
- Land use data was processed using the CARPC 2020 Dane County Land Use Inventory
  <a href = 'https://data-carpc.opendata.arcgis.com/' target = '_blank'>
  CARPC 2020 Dane County Land Use Inventory</a>. Suitable land for planting trees was defined as any uncultivated
  10m x 10m area with an NDVI value of .7 or higher that was not classified as canopy. This method does not account
  for Sentinel-2 data overestimating canopy (see method below or FAQ for more details), so likely underetimates the total
  available acres of suitable land.

<br> Priority variables were standardized and scaled so that the z-score
was normally distributed on a 0-10 scale (by multiplying the normal
distribution of the z-score for each variable by 10).

Based on user-defined selection of priority variables, standardized
scores are averaged to create a single, integrated priority value.

<h2>
<span style="font-size:16pt">Tree canopy</span>
</h2>

Growing Shade uses <!-- and shows --> a tree canopy layer. A machine
learning method was created in
<a href = 'https://earthengine.google.com/' target = "_blank">Google
Earth Engine</a> and used to detect tree cover from other land cover
types using
<a href = 'https://www.esa.int/Applications/Observing_the_Earth/Copernicus/Sentinel-2' target = "_blank">Sentinel-2
satellite imagery</a>. Any areas identified as
<a href = 'https://data-carpc.opendata.arcgis.com/' target = "_blank">open
water (from the 2020 land use inventory)</a> or
<a href = 'https://developers.google.com/earth-engine/datasets/catalog/USDA_NASS_CDL?hl=en' target = '_blank'>cultivated
cropland</a> were removed.

The tree canopy as identified with Sentinel-2 data was calibrated
to the tree canopy identified in the Twin Cities Region in 2015 using LiDAR data from 2011
(<a href="https://gisdata.mn.gov/dataset/base-landcover-twincities" target="_blank">Twin
Cities Metropolitan area 1-meter land cover classification</a>). With
1000 equal-area regions across the 7-county area, a scaling factor of
0.88 was used to bring the Sentinel data in line with on-the-ground
tree canopy. This scaling factor is appropriate for our methods of using
10 m x 10 m resolution data, which is often larger than tree canopies.
This scaling factor makes our data align very closely with other reports
(r^2 = 0.96) while still leveraging the scalability and temporal
accuracy of our method. Note that the percentage of canopy in a given area
is calculated using the total land area and ignores permanent bodies of water.

<h2>
<span style="font-size:16pt">Update Schedule</span>
</h2>

Growing Shade relies on multiple external datasets which are updated and released at different times of the year.
To simplify upkeep, we perform one annual update in January or February. 

<!--
Here are the datasets included in the annual update:

<table>
  <tr>
    <th>Dataset</th>
    <th>Current Release</th>
    <th>Next Release(update Jan-Feb, 2024)</th>
  </tr>
  
  <tr>
    <td>American Community Survey</td>
    <td>2022 (2017-2021 average)</td>
    <td>2023 (2018-2022 average)</td>
  </tr>
  
  <tr>
    <td>PLACES</td>
    <td>2023</td>
    <td>2023</td>
  </tr>
  
  <tr>
    <td>EJScreen</td>
    <td>2023</td>
    <td>2023</td>
  </tr>
  
  <tr>
    <td>Canopy/Greeness</td>
    <td>2021</td>
    <td>2023</td>
  </tr>
  
  <tr>
    <td>Primary Floodplains</td>
    <td>2023</td>
    <td>2023</td>
  </tr>
  
  <tr>
    <td>City & Township Boundaries</td>
    <td>Aug, 2023</td>
    <td>Jan or Feb, 2024</td>
  </tr>
  
  <tr>
    <td>Neighborhood Boundaries</td>
    <td>Aug, 2023</td>
    <td>Jan or Feb, 2024</td>
  </tr>
  
</table>
<i> *Growing Shade was adapted for Dane County in August of 2023,
so some newer datasets are already being used. 
</i>
-->
<br> <br><br><br><br>
