# DATA420-23S2 (C) Assignment 1
## GHCN Data Analysis using Spark

**Due:** Friday, September 15 by 5:00 PM

### Instructions

- You are encouraged to work together to understand and solve each of the tasks, but you must submit your own work
- Any assignments submitted after the deadline will receive a 50% penalty
- The forum is a great place to ask questions about the assignment material
- All data under `hdfs:///data/` is read only. Please use your own home directory to store your outputs (e.g. `hdfs:///user/abc123/outputs/`)
- Use the pyspark notebook provided on LEARN for easier code development and interactive output checking
- Be mindful that you are sharing cluster resources. Monitor Spark using the web UI (`mathmadslinux2p:8080`)
- Don't leave shells running longer than necessary
- Contact users via their user code (e.g. `abc123@uclive.ac.nz`) if you need to share resources

### Report Requirements

#### Format
- Submit as single PDF file via LEARN
- Additional code, images, and supplementary material as single zip file (max 10 MB)
- Maximum 10 pages excluding separately provided figures and supplementary material
- Does not include cover page, table of contents, or references

#### Formatting Guidelines
- Margins: 0.5" to 1"
- Font: Sans-serif (e.g., Arial) size 11-12
- Line spacing: 1 or 1.15
- Sensible use of monospaced code blocks, tables, and images
- Reference external resources using APA or MLA citation format
- Include citations for code snippets and ChatGPT usage

#### Required Sections

1. **Background**
   - Brief overview of assignment tasks
   - Useful links or references to background material
   - High-level description of difficulties encountered

2. **Processing**
   - Detailed description of data structure and content
   - Answer processing questions
   - Describe steps taken and interesting discoveries
   - Do not include actual outputs as you create additional columns

3. **Analysis**
   - Answer analysis questions with explained methodology
   - Include requested visualizations (examples in report, rest in supplementary material)
   - Only include small code snippets for detailed explanation
   - All other code in supplementary material

4. **Conclusions**
   - High-level summary of work completed
   - Key insights discovered
   - Tasks unable to complete and reasons why

---

## DATA

### Global Historical Climate Network (GHCN)

The Global Historical Climate Network is an integrated database of climate summaries from land surface stations worldwide. The data:
- Extends back over 250 years
- Collected from 20+ independent sources
- Subjected to quality assurance reviews
- Contains records from 100,000+ stations in 200+ countries

### Data Structure

#### Daily Climate Summaries
- **Format:** Comma-separated values
- **Coverage:** Single row per station per day per variable
- **Variables:** Maximum/minimum temperature, precipitation, snowfall, snow depth
- **Note:** About half of stations report precipitation only
- **Record Length:** Less than 1 year to 100+ years per station

#### Field Definitions (Daily Data)
| Field | Type | Description |
|-------|------|-------------|
| ID | Character | Station code |
| DATE | Date | Observation date (YYYYMMDD) |
| ELEMENT | Character | Element type indicator |
| VALUE | Real | Data value for element |
| MEASUREMENT FLAG | Character | Measurement flag |
| QUALITY FLAG | Character | Quality flag |
| SOURCE FLAG | Character | Source flag |
| OBSERVATION TIME | Time | Observation time (HHMM) |

#### Metadata Tables

**Stations Table** (Fixed-width format)
| Field | Range | Type | Description |
|-------|-------|------|-------------|
| ID | 1-11 | Character | Station identifier |
| LATITUDE | 13-20 | Real | Latitude coordinate |
| LONGITUDE | 22-30 | Real | Longitude coordinate |
| ELEVATION | 32-37 | Real | Elevation |
| STATE | 39-40 | Character | State code |
| NAME | 42-71 | Character | Station name |
| GSN FLAG | 73-75 | Character | GCOS Surface Network flag |
| HCN/CRN FLAG | 77-79 | Character | US Historical/Climate Reference Network flag |
| WMO ID | 81-85 | Character | World Meteorological Organization ID |

**Countries Table**
| Field | Range | Type | Description |
|-------|-------|------|-------------|
| CODE | 1-2 | Character | Country code |
| NAME | 4-64 | Character | Country name |

**States Table**
| Field | Range | Type | Description |
|-------|-------|------|-------------|
| CODE | 1-2 | Character | State code |
| NAME | 4-50 | Character | State name |

**Inventory Table**
| Field | Range | Type | Description |
|-------|-------|------|-------------|
| ID | 1-11 | Character | Station identifier |
| LATITUDE | 13-20 | Real | Latitude coordinate |
| LONGITUDE | 22-30 | Real | Longitude coordinate |
| ELEMENT | 32-35 | Character | Element code |
| FIRSTYEAR | 37-40 | Integer | First year of data |
| LASTYEAR | 42-45 | Integer | Last year of data |

---

## TASKS

### Processing

#### Q1: Data Exploration
**Objective:** Define data sources and explore structure without loading into memory

**(a)** Use `hdfs` command to explore `hdfs:///data/ghcnd` structure
- Draw directory tree representation
- Identify data organization pattern

**(b)** Analyze temporal coverage and size patterns
- How many years contained in daily data?
- How does data size change over time?

**(c)** Calculate total data footprint
- Total size of all data
- Proportion that is daily data

#### Q2: Initial Data Loading
**Objective:** Load and examine data sources with proper schemas

**Setup:** Start notebook with 2 executors, 1 core per executor, 1 GB memory each

**(a)** Schema definition for daily data
- Define schema using `pyspark.sql` data types
- Load 1000 rows from `hdfs:///data/ghcnd/daily/2023.csv.gz`
- Justify data type choices

**(b)** Load metadata tables
- Parse fixed-width text formatting
- Use `spark.read.format('text')` and `pyspark.sql.functions.substring`
- Alternative: find open source library

**(c)** Data quality assessment
- Count rows in each metadata table
- Identify stations without WMO ID

#### Q3: Data Integration
**Objective:** Join daily summaries with metadata tables

**Setup:** Create output directory in home directory (e.g., `hdfs:///user/abc123/outputs/ghcnd/`)

**(a)** Country code extraction
- Extract 2-character country code from station codes
- Store as new column using `withColumn`

**(b)** Countries integration
- LEFT JOIN stations with countries using country code

**(c)** States integration
- LEFT JOIN stations and states
- Handle US-only state codes appropriately

**(d)** Station activity analysis
- Determine first/last active year for each station
- Count different elements collected per station
- Separate core elements from "other" elements
- Identify stations with all five core elements
- Identify precipitation-only stations

**(e)** Enhanced stations table
- LEFT JOIN stations with inventory analysis
- Save enriched stations table to output directory
- Choose appropriate file format (CSV, CSV.gz, Parquet)

**(f)** Daily data integration assessment
- LEFT JOIN 1000-row daily subset with enriched stations
- Identify orphaned stations in daily data
- Estimate cost of full daily-stations JOIN
- Propose alternative methods for orphan detection

### Analysis

#### Q1: Station Demographics
**Objective:** Analyze station distribution and characteristics

**Setup:** May increase to 4 executors, 2 cores each, 4 GB memory

**(a)** Station counts
- Total stations in database
- Stations active in 2023

**(b)** Network participation
- Count stations in GSN, HCN, and CRN networks
- Identify stations in multiple networks

**(c)** Geographic distribution
- Count stations per country (store in countries table)
- Count stations per state (save both tables)
- Count Northern Hemisphere stations
- Count stations in US territories (excluding mainland US)

#### Q2: Geographic Analysis
**Objective:** Implement spatial analysis functions

**(a)** Distance calculation function
- Write Spark UDF for geographical distance between stations
- Use spherical earth model
- Test with CROSS JOIN on station subset

**(b)** New Zealand station analysis
- Compute pairwise distances for all NZ stations
- Save results to output directory
- Identify closest station pair

#### Q3: Parallelism and Performance
**Objective:** Understand Spark's handling of compressed data

**(a)** HDFS block analysis
- Determine default HDFS blocksize using `hdfs getconf -confKey "dfs.blocksize"`
- Calculate blocks required for 2023 and 2022 daily data
- Determine individual block sizes for 2022

**(b)** Parallelism assessment
- Load and count 2022 and 2023 observations separately
- Monitor task execution via web UI (`mathmadslinux2p:8080`)
- Compare task count to block count

**(c)** Multi-year analysis
- Load and count observations from 2014-2023 (inclusive)
- Use glob patterns in read command
- Analyze task execution patterns

**(d)** Compression impact
- Explain how Spark partitions compressed input files
- Estimate parallel task capacity
- Propose methods to increase parallelism

#### Q4: Comprehensive Data Analysis
**Objective:** Perform full-scale analysis of climate data

**(a)** Complete data inventory
- Count total rows in daily data
- Note: This operation will take considerable time with minimal resources

**(b)** Core elements analysis
- Filter daily data for five core elements
- Count observations per core element
- Identify element with most observations

**(c)** Temperature data pairing
- Find TMIN observations without corresponding TMAX
- Count unique stations contributing to these observations

**(d)** New Zealand climate analysis
- Filter all TMIN and TMAX observations for NZ stations
- Save results to output directory
- Verify row count using `hdfs dfs -copyToLocal` and `wc -l`
- Create time series plots for each NZ station
- Generate country-wide average time series

**(e)** Global precipitation analysis
- Group precipitation by year and country
- Calculate average annual rainfall per country
- Identify country with highest single-year average rainfall
- Assess result validity and consistency
- Create elegant visualization (e.g., choropleth map for 2022)
- Identify data gaps or missing values

---

## Technical Notes

### Resource Management
- Monitor cluster usage via web UI
- Scale resources based on task requirements
- Respond promptly to resource sharing requests
- Maximum allocation: 4 executors, 2 cores each, 4 GB memory

### Data Storage Considerations
- 400GB distributed storage limit
- Choose efficient file formats
- Consider compression for output files
- Never cache or collect entire daily dataset

### File Operations
- Use appropriate HDFS commands for exploration
- Leverage glob patterns for multi-file operations
- Verify Spark operations with command-line tools
