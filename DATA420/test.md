# DATA420 Assignment 1

**Author:** Sam Love, 84107034
**Date:** June 6, 2025

---

## Background

This is a report for Assignment 1 of DATA420, a course at the University of Canterbury.

The purpose of this assignment is to study weather data contained in the Global Historical Climate Network (GHCN), an integrated database of climate summaries from land surface stations around the world covering the last 175 years and collected from more than 20 independent sources, with over 100,000 stations in 180 countries and territories.

The main data is contained in the daily climate summaries as comma separated files with empty null fields. Each row represents an observation for a specific station and day. There are also columns for element, value, measurement flag, quality flag, source flag, and observation time.

There are additional metadata tables that provide context for stations, countries, states, and inventory specific to each station and time period.

There were some difficulties encountered with missing data, classification of US territories, and producing effective plots.

## Processing

The purpose of this section is to gain familiarity with the data by examining how it is stored and testing a sample. We also created an enriched stations metadata table that combines the four metadata tables. This is useful for understanding and referencing the data.

### Question 1

Firstly we explore the data files in the hadoop distributed file system (HDFS) accessed via terminal code. This gives an overview of how the data is stored using a safe and accessible method.

The directory is organised as follows:

```
- data
  - ghcnd
    - daily
      - 1750.csv.gs
      - 1763.csv.gs
      - 1764.csv.gs
      - ... (257 rows)
      - 2022.csv.gs
      - 2023.csv.gs
    - daily-uncompressed
      - 2022.csv
    - ghcnd-countries.txt
    - ghcnd-inventory.txt
    - ghcnd-states.txt
    - ghcnd-stations.txt
```

The years 1750 and 1763 to 2023 (inclusive) are contained in the daily folder.

The size of the files steadily increases over time. This is likely due to increasing capability (through improved technology) and desire to collect more data (more stations, more often).

The size of the data generally increases each year:

- Years 1763-1813 have small amounts of data only using KBs
- Years 1814-1857 increases to 10s of KBs
- Years 1858-1877 increases to 100s of KBs
- Years 1878-1892 require MBs of storage
- Years 1893-1951 increases to 10s of MBs
- Years 1952-2023 are the largest files, taking up 100s of MBs each

The total size of the data is 13.6GB of which daily accounts for 12.3GB.

Daily-uncompressed accounts for 1.3GB whilst the metadata tables are relatively tiny accounting for approximately 43mb (0.3%).

### Question 2

Next we load a sample of daily and the metadata tables. This lets us set up an appropriate schema and gives a glimpse of the full dataset. Correctly parsing the metadata tables is in preparation for creating the enriched stations table (see Q3).

The schema for daily has columns for ID, Date, Element, Value, Measurement_Flag, Quality_Flag, Source_Flag, and Observation_Time, where:

- **ID** is the station identification code with format AB111111111 where the first two letters represent the country code and the third integer (or letter) is the network code that identifies the station numbering system used
- **Date** is the observation date with format YYYYMMDD
- **Element** is the observation type with format ABCD. The five core elements are precipitation (PRCP 0.1mm), snow (SNOW mm), snow depth (SNWD mm), maximum temperature (TMAX 0.1°C), and minimum temperature (TMIN 0.1°C)
- **Value** is the observation itself with format 123
- **Measurement_Flag** gives extra measurement information with format A (or blank) where there are 10 possible values
- **Quality_Flag** gives extra quality information with format A (or blank) where there are 14 possible values
- **Source_Flag** gives extra source information with format 1, A, or a (or blank) where there are 30 possible values
- **Observation_Time** has the format HHMM (or blank)

(*Index of /Pub/Data/Ghcn/Daily*, n.d.)

The schema uses string types for all variables except value which uses integer type. The Date and Observation_Time columns would require wrangling into the correct format for date type. Therefore they can remain as strings until required, when we can extract the relevant information from them using substrings. This saves time and effort over superfluous conversion.

Parsing the metadata tables required substrings and aliases to generate columns out of the fixed width text formatting of the raw files.

The metadata tables have the following sizes:

- Countries has 219 rows
- Inventory has 737,925 rows
- States has 74 rows
- Stations has 124,247 rows

The countries metadata table has columns for Code and Name, where:

- **Code** is a two letter string that corresponds to the code at the start of every station ID
- **Name** is a string of each countries name where territories are indicated after the relevant countries name

The inventory metadata table has columns for ID, Latitude, Longitude, Element, FirstYear, and LastYear, where:

- **ID** is the station ID (as in the schema)
- **Latitude** is the latitude of the station in decimal degrees
- **Longitude** is the longitude of the station in decimal degrees
- **Element** is the observation type (as in the schema)
- **FirstYear** is the first year of unflagged data
- **LastYear** is the last year of unflagged data

The states metadata table is similar to countries but represents US states instead of countries.

The stations metadata table is the basis for the combined enriched stations table that we want to create. It has columns for ID, Latitude, Longitude, Elevation, State, Name, GSN_Flag, HCN/CRN_Flag, and WMO_Flag, where:

- **ID** is the station ID (as in the schema)
- **Latitude** is the latitude (as in inventory)
- **Longitude** is the longitude (as in inventory)
- **Elevation** is the elevation of the station in meters (missing = -999.9)
- **State** is the US state code when applicable
- **Name** is the name of the station
- **GSN_Flag** indicates whether the station is part of the GCOS Surface Network of stations
- **HCN/CRN_Flag** indicates whether the station is part of the US Historical Climatology or US Climate Reference Network of stations
- **WMO_Flag** is the World Meteorological Organization number for the station

(*Index of /Pub/Data/Ghcn/Daily*, n.d.)

There are 116,297 stations (~93.6%) that do not have a WMO ID.

A challenge with this is that the missing data is represented by strings of spaces. Most missing WMO_Flag data has 5 spaces but 9 observations only have 4 spaces. These were the only options so were filtered accordingly to find the total missing WMO IDs.

### Question 3

Next we combine the metadata tables to create an enriched stations table containing all the metadata. We will a sample of the daily data combined with the enriched stations table to check for completeness. The table is useful for filtering and sorting stations based on desired attributes.

We first left-join stations with countries then the result with states. A left-join is useful in this situation since it maintains all the station metadata and generates missing values were applicable (states columns for countries that are not the US).

The inventory metadata table requires some wrangling before it can be joined. We will group by station ID and aggregate to generate columns for First_Year, Last_Year, Total_Elements, Core_Elements, and Noncore_Elements. This creates a table of unique stations which can then be joined onto the combined stations table to create the final enriched stations table. The omitted columns from inventory of Latitude and Longitude are redundant since they exist in the stations table.

124,239 distinct stations collected an element, of which 20,449 collected all core elements, and 16,272 stations only collected the precipitation element.

A challenge with this is that there are 124,247 unique stations in the stations metadata, meaning 8 stations did not collect an element. 6 of these stations are in Sweden, 1 is in the US, and 1 in Germany. As there are so few stations with missing elements, we can ignore this anomaly, however it would be worth further investigation if we wanted completeness of data.

The enriched stations table is useful so will be saved to the output directory. The most appropriate format is .csv.gz. This offers the following advantages:

- Consistent with how the daily data is stored
- Lossless with data integrity maintained
- Faster load times
- Reduced file size
- Popular so commonly supported

("What Is GZIP Compression?," 2022)

There are however some disadvantages:

- The compressed data is not splittable so needs to be loaded by one executor
- Increased CPU usage when writing

Now we left-join a 1000 observation subset of the daily data with the enriched stations table. All the stations in the subset are contained in daily.

Joining all of the daily data with enriched stations is only expensive when an action is performed on the join. This is due to lazy execution of transformations (such as a join). Considering daily has over 3 million rows (see Analysis Q4), any action performed on it will be computationally expensive. A broadcast join would be more appropriate as it copies the smaller dataset (enriched stations) to each node and applies the join locally. However, it is still relatively expensive so we should look for different methods to garner useful information.

We can answer some questions without needing a join, such as finding any stations in daily that are not in the stations metadata table by creating and comparing lists of the unique station IDs in both tables. This is much faster than joining the tables since the comparison is run on much smaller datasets which avoids the issues discussed above.

## Analysis

The purpose of this section is to answer specific questions about the daily dataset using our newly gained knowledge. This is useful for further understanding the data and gaining insights into what the data shows.

### Question 1

Firstly we will further investigate the stations using the new enriched stations metadata table.

There are 124,247 unique stations, of which 35,150 are active in 2023. There are 991 GSN, 1,218 HCN, and 234 CRN stations. Of these, there are 15 stations in both the HCN and CRN networks.

We can count the number of stations in each country and US state to create enriched versions of the Countries and States metadata tables. From these enriched tables we find that there are 98,871 stations in the northern hemisphere and 25,376 stations in the southern hemisphere. This is determined using latitude data where >0 is north and <0 is south. (*Equator*, n.d.)

There are 80,218 stations in the enriched states metadata table. We find from the enriched countries metadata table that there are 374 stations across 9 countries associated with the US (by filtering countries with Q in the code). However, this presents another challenge. The US States enriched table has 74 entries despite there being only 50 states. Filtering out the states shows Canadian provinces (and territories) have been included in the metadata. Filtering these out as well as Washington DC (a federal district) leaves 10 US 'territories' that account for 455 stations.

**Table 1: US States & Canadian Provinces and Territories**

![Table 1](Images/T1.png)

*Adapted from Patrias (2007).*

Data classification decisions and global politics account for this discrepancy. If we require further clarity we could generate a list of desired US territories and filter for entries that correspond to the list.

### Question 2

Next we create a user defined function to calculate the geographical distance between station pairs. This is useful for further understanding the stations in New Zealand which is relevant since we live in New Zealand.

Geographical distance can be calculated with the Haversine formula:

**Formula 1: Haversine Distance**

d(φ₁,φ₂,λ₁,λ₂) = √[sin²((φ₂-φ₁)/2) + cos φ₁ cos φ₂ sin²((λ₂-λ₁)/2)]

where φᵢ = station i's latitude and λᵢ = station i's longitude.

*Adapted from Gade (2010).*

This accounts for the fact that the earth is spherical (with radius 6371km (Lide, 2000)).

There are 15 stations in New Zealand. When we apply the Haversine formula to find pairwise distances between the stations in New Zealand we get 225 rows which can be reduced down to 105 (by removing redundancy). The closest two stations in New Zealand are NZ000093417 (Paraparaumu AWS) and NZM00093439 (Wellington Aero AWS) which are 50.5km from each other.

*Code provided by ChatGPT*

### Question 3

Next we start exploring the daily dataset, initially by developing an understanding of the level of parallelism we can achieve with samples of the dataset.

The default blocksize of HDFS is 134,217,728 bytes which is 128MB or 0.125GB.

The Daily 2023 data takes up 89.4MB which easily fits into one block. However, the Daily 2022 data takes up 160.4MB which requires two blocks.

A transformation is an operation applied to a resilient distributed dataset (RDD). Transformations are performed locally and lazily (on execution of an action).

Spark is designed to load and apply transformations in parallel for both these years despite the number of blocks and partitions the data uses.

There are 37,807,475 rows in the daily 2022 data and 20,887,047 rows in the daily 2023 data.

Counting these rows required 1 job for each year (since we counted them separately). Each job consisted of 2 stages which contained 2 tasks (1 in each). In this case the tasks are performing the count locally and shuffling the counts to the master node to be viewed by the user. As such, the number of tasks do not correspond to the number of blocks in each input. Rather they correspond to the number of partitions.

There are 352,566,795 rows in the daily 2014-2023 (inclusive) data.

Counting these rows required 1 job. The job consisted of 2 stages which contained 11 tasks (10 in the first, 1 in the second). There is 1 partition per year (input file) that each generated a task.

For compressed files that are splittable (e.g. parquet), Spark can load each block independently (on multiple executors). The partitions come from the HDFS blocks. When loaded in parallel, we get distributed partitions from the HDFS blocks without needing to shuffle.

For compressed files that are unsplittable (e.g. gzip), Spark loads the file on one executor. The partitions come from the separate files. When it cannot load in parallel, Spark has to load all the blocks to successfully uncompress the data.

To improve this, we can partition data split by time (if temporal) or into n part files where n is sufficiently small.

Since the number of tasks depends on the number of partitions, the parallelism is directly proportional to how many years (input files) we load. Parallelism is also limited by the number of CPU cores we are using. In this case we are using 8 cores so 8 tasks can run in parallel at any time. Since transformations are applied locally and lazily, they can all be applied before shuffling the results to the master node.

To increase parallelism we can manually increase the number of partitions using the 'repartition()' function. However, this must be accompanied by an increased number of cores to be effective. Additional preprocessing can also increase parallelism since we can reduce the size of the dataframes depending on what we need.

### Question 4

Finally we examine aspects of the full daily dataset and produce some visualisations of temperature extremes in New Zealand and rainfall in 2022 for each country.

There are 3,079,907,141 rows in the full daily dataset, of which:

- 1,061,852,307 rows have the element PRCP
- 350,340,072 rows have the element SNOW
- 295,694,194 rows have the element SNWD
- 453,107,311 rows have the element TMAX
- 451,900,942 rows have the element TMIN

Clearly precipitation (rainfall) is the main focus of many stations since it accounts for 1/3 of all observations.

The minimum and maximum temperatures are ideally collected and reported in pairs. There are however, 28,660 stations that contribute to 10,396,990 observations of TMAX without a corresponding (same date) TMIN observation.

We will focus on the observations of TMIN and TMAX from the 15 stations in New Zealand. There are 481,143 observations of either TMIN or TMAX collected across 83 years 1940-2023 (inclusive). Of these 232,054 are TMIN and 249,089 are TMAX observations.

There are 962,286 observations when counting in the terminal. This is exactly double the count found in Pyspark so is likely due to the compression method (.csv.gz).

A challenge here was plotting TMIN and TMAX values over time for the New Zealand stations. The temperature values are measured at by 0.1° so the axis values are larger by a magnitude of 10. Changing the dataframe itself is impractical due to its size. Also the plot filled in the space between TMIN and TMAX which is not a particularly accurate representation of the data.

**Graph 1: Average minimum and maximum temperatures in New Zealand over time**

![New Zealand Min and Max Temperatures Over Time](https://i.imgur.com/placeholder1.png)

There are many outliers in the average minimum temperature observations around 1850. It may be worth investigating further to find the context of this and either change or omit these values.

There are no strong trend lines for the average maximum temperatures but there is an increase in the average minimum temperatures over the last 50 years. This indicates fewer extreme cold temperatures which could be due to climate change or alternatively more rigorous data collection methods. The earlier outliers could give some context as to issues with data collection.

**Individual Station Temperature Graphs**

The following graphs show temperature data for individual New Zealand weather stations, revealing patterns of data collection and temperature trends at specific locations:

![Station NZ000093012 Min and Max Temperature Over Time](https://i.imgur.com/placeholder2.png)

![Station NZ000093292 Min and Max Temperature Over Time](https://i.imgur.com/placeholder3.png)

![Station NZ000093417 Min and Max Temperature Over Time](https://i.imgur.com/placeholder4.png)

![Station NZ000093844 Min and Max Temperature Over Time](https://i.imgur.com/placeholder5.png)

![Station NZ000933090 Min and Max Temperature Over Time](https://i.imgur.com/placeholder6.png)

![Station NZ000936150 Min and Max Temperature Over Time](https://i.imgur.com/placeholder7.png)

![Station NZ000937470 Min and Max Temperature Over Time](https://i.imgur.com/placeholder8.png)

![Station NZ000939450 Min and Max Temperature Over Time](https://i.imgur.com/placeholder9.png)

![Station NZ000939870 Min and Max Temperature Over Time](https://i.imgur.com/placeholder10.png)

![Station NZM00093110 Min and Max Temperature Over Time](https://i.imgur.com/placeholder11.png)

![Station NZM00093439 Min and Max Temperature Over Time](https://i.imgur.com/placeholder12.png)

![Station NZM00093678 Min and Max Temperature Over Time](https://i.imgur.com/placeholder13.png)

![Station NZM00093781 Min and Max Temperature Over Time](https://i.imgur.com/placeholder14.png)

![Station NZM00093929 Min and Max Temperature Over Time](https://i.imgur.com/placeholder15.png)

![Station NZ000093994 Min and Max Temperature Over Time](https://i.imgur.com/placeholder16.png)

These individual station graphs reveal that some stations have chunks of missing data whilst others have relatively infrequent data collection. Not all stations have collected consistent and robust data which may affect further analysis. The graphs show varying data collection periods, with some stations having continuous records spanning several decades, while others show intermittent data collection or shorter operational periods.

Looking at average precipitation (rainfall) in each country, Equatorial Guinea has the highest average at 436mm in the year 2000. This is reasonable considering Equatorial Guinea has a tropical equatorial climate. It is in also in keeping with the data from the World Bank Climate Change Knowledge Portal.

*Note: missing plot of average rainfall in 2022 for each country.*

## Conclusion

In this assignment we have studied weather data contained in the Global Historical Climate Network (GHCN).

In the preprocessing section we gained familiarity with the metadata tables and combined them into an enriched table that we tested on a sample of the main dataset.

In the analysis section we explored aspects of the main dataset and produced visualisations of relevant subsections.

I was unable to plot the average rainfall in 2022 for each country due to inexperience and time constraints.

---

## References

*Equator*. (n.d.). https://education.nationalgeographic.org/resource/equator/

Gade, K. (2010). *A non-singular horizontal position representation*. Journal of Navigation, 63(3), 395–417. https://doi.org/10.1017/s0373463309990415

ChatGPT by OpenAI. https://chat.openai.com/auth/login

Global Historical Climatology Network daily (GHCNd). (2023, July 20). National Centers for Environmental Information (NCEI). https://www.ncei.noaa.gov/products/land-based-station/global-historical-climatology-network-daily

Index of /pub/data/ghcn/daily. (n.d.). https://www.ncei.noaa.gov/pub/data/ghcn/daily/

Lide, D. R. (2000). *Handbook of Chemistry and Physics: A Ready-Reference Book Chemical and Physical Data*. CRC-Press.

Patrias, K. (2007, October 10). *Two-Letter abbreviations for Canadian provinces and territories and U.S. states and territories*. Citing Medicine - NCBI Bookshelf. https://www.ncbi.nlm.nih.gov/books/NBK7254/

*PySpark Overview — PySpark 3.5.0 documentation.* (n.d.). https://spark.apache.org/docs/latest/api/python/index.html#

What is GZIP Compression? (2022). *10Web*. https://10web.io/site-speed-glossary/gzip-compression/#:~:text=GZIP%20is%20a%20lossless%20compression,is%20the%20same%20after%20decompressing.

World Bank Climate Change Knowledge Portal. (n.d.). https://climateknowledgeportal.worldbank.org/country/equatorial-guinea/climate-data-historical
