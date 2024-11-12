Methods
================

We would like to thank the developers, advisors, consultants, and 
all other contributors to the original Growing Shade tool.
  
Methods and data sources for the analyses presented within Growing Shade are detailed below.

<h2>
<span style="font-size:16pt">Data Sources</span>
</h2>

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
- Tree canopy is obtained from the
  <a href = 'https://www.esa.int/Applications/Observing_the_Earth/Copernicus/Sentinel-2' target = "_blank">Copernicus
  Sentinel-2 satellite mission</a>.
- Climate data for temperatures was processed using 
	<a href = 'https://earthengine.google.com/' target = "_blank">Google
	Earth Engine</a> to detect the hottest summer temperature during a year.
	<br>
	Script source: Ermida, S.L., Soares, P., Mantas, V., Göttsche, F.-M., Trigo, I.F., 2020. Google Earth Engine open-source code
	for Land Surface Temperature estimation from the Landsat series. Remote Sensing, 12 (9), 1471; https://doi.org/10.3390/rs12091471	

<h2>
<span style="font-size:16pt">Prioritization Methodology</span>
</h2>

Each block group in Dane County receives  a score for each variable used in Growing Shade. Variables are scored differently depending
on whether or not they include a <b>margin of error</b> (MOE).

<i> 1. Scoring Variables <b>Without</b> MOE </i> 

Datasets without MOE: Decennial Census data, Canopy data, Temperature data

Each variable without MOE receives  a score of 1 for a block group if it is above the 80th percentile when compared to the
total distribution of said variable. If the variable is below the 80th percentile, it recieves a score of 0. 
Note that the percentile thresholds are the inverse for % canopy, as areas with low canopy should be prioritized.

Additionally, variables related to race/ethnicity recieve a score of 2 if they are above the 95th percentile;
The total score from race related variables in the Socioeconomic Indicators theme is capped at 3.
This extra point underlies the widely recognized correlation between race and deficient tree canopy.

<i> 2. Scoring Variables <b>With</b> MOE </i>

Datasets with MOE: ACS data, Health data

Each variable with MOE receives a score of 1 for a block group if it is significantly higher or lower when compared to the
total distribution of said variable. Significance is determined by using a Z-test to compare each block group to the median 
of the total population, taking into account the MOE. 
If the Z-score is more than 1 standard deviation from the population median, then the variable is significantly higher or lower than the median.
Whether the higher or lower block groups recieve a score of 1 depends on the variable in question -- for example, we are interested in high
values for % asthma among adults and low values for median household income.
If the variable is not significantly higher or lower than the median, it receives a score of 0.



<i> Validation </i>

Some variable populations with high margins of errors are unsuitable for analysis. Variables used in Growing Shade are considered
valid if 60% of block groups have a coefficient of variation (i.e. dispersion of data around the mean) below 40%.
Variables that do not meet this standard are not used.

<i> Themes </i> 

The total score of a block group is the sum of all variable scores in a theme.
With the exception of the socioeconomic indicators theme,
block groups must have a minimum score of 1 to be considered a priority area. 
While all block groups with a score of at least 1 are priority areas, 
those with higher scores can be interpreted as a higher priority for canopy growth/management.

The minimum priority area score is also set at 1 for the Custom theme. We plan to let users customize this threshold in a future update.

Using the socioeconomic indicators theme, block groups must have a minimum score of 2
to be considered a priority area. 

Different minimum scores were tested for each theme; 
we chose the final scores based on how many priority areas were selected.
Our intent was for each theme to show a reasonable and helpful number of priority areas --
to prioritize block groups with the highest canopy needs, but also not be overly restrictive.

<i> Acknowledgments </i>

This methodology and the socioeconomic indicators theme were created by the City of Madison Data Team. 
We are grateful for all their help integrating their work with Growing Shade.

<h2>
<span style="font-size:16pt">Tree canopy</span>
</h2>

Growing Shade uses a tree canopy layer. A machine
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

A supervised learning algorithm (random forest) is trained to identify canopy from non-canopy. 
The input layers are created from a full year worth of data. They are grouped into 5 phenological layers depending on date
 – winter, spring, early summer, summer, fall. For each layer, the normal difference vegetation index (NDVI) is calculated, 
 then a mosaic is made using the ‘best’ pixel (max NDVI).
 
Dane County has a diversity of landcover so some areas are more prone to misclassification. 
To account for this, the classification results are corrected using a "baseline error" calculated by 
comparing the most recent LiDAR-derived canopy layer to this method (using the same year as the LiDAR data).

Note that the percentage of canopy in a given area is calculated using the total land area and ignores permanent bodies of water.

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
