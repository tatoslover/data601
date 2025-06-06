##
##
## Overview
##
##

# This is the ui file for "From Bricks to Bucks: Exploring Influential Variables in Sales Patterns of Lego Sets"
# author: "Samuel Love, 84107034"
# Use in conjunction with global.R and server.R files

shinyUI(
  fluidPage(
    useShinyjs(),
    htmlOutput("Title"),
    
    tabsetPanel(
      tabPanel("Data",
               tabsetPanel(
                 tabPanel("Description", htmlOutput("HTMLData")),
                 
                 tabPanel("JB",
                          tabsetPanel(
                            spinnerPanel("Overview", verbatimTextOutput(outputId = "glimpseJBRaw")),
                            spinnerPanel("DataFrame Table", dataTableOutput(outputId = "dftableJBRaw")),
                            spinnerPanel("DataFrame Summary", verbatimTextOutput(outputId = "dfsummaryJBRaw")),
                            spinnerPanel("Missingness", plotOutput(outputId = "vismissJBRaw")),
                            spinnerPanel("Cleaned", verbatimTextOutput(outputId = "glimpseJBClean")),
                            spinnerPanel("Cleaned Missingness", plotOutput(outputId = "vismissJBClean"))
                          )),
                 
                 tabPanel("D15",
                          tabsetPanel(
                            spinnerPanel("Overview", verbatimTextOutput(outputId = "glimpseD15Raw")),
                            spinnerPanel("DataFrame Table", dataTableOutput(outputId = "dftableD15Raw")),
                            spinnerPanel("DataFrame Summary", verbatimTextOutput(outputId = "dfsummaryD15Raw")),
                            spinnerPanel("Missingness", plotOutput(outputId = "vismissD15Raw")),
                            spinnerPanel("Cleaned", verbatimTextOutput(outputId = "glimpseD15Clean")),
                            spinnerPanel("Cleaned Missingness", plotOutput(outputId = "vismissD15Clean"))
                          )),
                 
                 tabPanel("D18",
                          tabsetPanel(
                            spinnerPanel("Overview", verbatimTextOutput(outputId = "glimpseD18Raw")),
                            spinnerPanel("DataFrame Table", dataTableOutput(outputId = "dftableD18Raw")),
                            spinnerPanel("DataFrame Summary", verbatimTextOutput(outputId = "dfsummaryD18Raw")),
                            spinnerPanel("Missingness", plotOutput(outputId = "vismissD18Raw")),
                            spinnerPanel("Cleaned", verbatimTextOutput(outputId = "glimpseD18Clean")),
                            spinnerPanel("Cleaned Missingness", plotOutput(outputId = "vismissD18Clean"))
                            
                          )),
                 
                 tabPanel("MP",
                          tabsetPanel(
                            spinnerPanel("Overview", verbatimTextOutput(outputId = "glimpseMPRaw")),
                            spinnerPanel("DataFrame Table", dataTableOutput(outputId = "dftableMPRaw")),
                            spinnerPanel("DataFrame Summary", verbatimTextOutput(outputId = "dfsummaryMPRaw")),
                            spinnerPanel("Missingness", plotOutput(outputId = "vismissMPRaw")),
                            spinnerPanel("Cleaned", verbatimTextOutput(outputId = "glimpseMPClean")),
                            spinnerPanel("Cleaned Missingness", plotOutput(outputId = "vismissMPClean"))
                          )),
                 
                 tabPanel("Merged",
                          tabsetPanel(
                            spinnerPanel("Overview", verbatimTextOutput(outputId = "glimpseMerged")),
                            spinnerPanel("DataFrame Table", dataTableOutput(outputId = "dftableMerged")),
                            spinnerPanel("DataFrame Summary", verbatimTextOutput(outputId = "dfsummaryMerged")),
                            spinnerPanel("Missingness", plotOutput(outputId = "vismissMerged")),
                            tabPanel("Histograms",
                                     withSpinner(
                                       plotOutput(outputId = "histogram")),
                                     selectizeInput(inputId = "variablehist",
                                                    label = "Show variable:",
                                                    MergedColsContinous,
                                                    multiple = FALSE,
                                                    selected = MergedColsContinous[1]),
                                     sliderInput(inputId = "bins",
                                                 label = "Number of bins",
                                                 min = 10,
                                                 max = 100,
                                                 step = 10,
                                                 value = 50)
                            ),
                            tabPanel("Missingness Correlation",
                                     withSpinner(
                                       plotOutput(outputId = "corrMerged")),
                                     selectizeInput(inputId = "correlation",
                                                    label = "Correlation method",
                                                    c("kendall","pearson","spearman"),
                                                    selected = "pearson"),
                                     checkboxInput(inputId = "absolute",
                                                   label = "Uses absolute correlation",
                                                   value = TRUE),
                                     selectInput(inputId = "group",
                                                 label = "Grouping method",
                                                 choices = list("none" = FALSE,"OLO" = "OLO","GW" = "GW","HC" = "HC"),
                                                 selected = "none")
                            ),
                            tabPanel("Boxplots",
                                     withSpinner(
                                       plotOutput(outputId = "boxplot")),
                                     selectizeInput(inputId = "variablesbox",
                                                    label = "Show variables:",
                                                    MergedColsContinous,
                                                    multiple = TRUE,
                                                    selected = MergedColsContinous),
                                     checkboxInput(inputId = "boxcentre",
                                                   label = "Centre",
                                                   value = TRUE),
                                     checkboxInput(inputId = "boxscale",
                                                   label = "Scale",
                                                   value = TRUE),
                                     checkboxInput(inputId = "boxshowoutliers",
                                                   label = "Show outliers",
                                                   value = TRUE),
                                     checkboxInput(inputId = "boxlabeloutliers",
                                                   label = "Label outliers",
                                                   value = TRUE),
                                     sliderInput(inputId = "range",
                                                 label = "IQR Multiplier",
                                                 min = 0,
                                                 max = 5,
                                                 step = 0.1,
                                                 value = 1.5)
                            ),
                            tabPanel("Rising-value Chart",
                                     withSpinner(
                                       plotOutput(outputId = "risingvalue")),
                                     selectizeInput(inputId = "variablesC",
                                                    label = "Show variables:",
                                                    MergedColsContinous,
                                                    multiple = TRUE,
                                                    selected = MergedColsContinous[1]),
                                     checkboxInput(inputId = "standardiseB",
                                                   label = "Show standardized",
                                                   value = FALSE)
                            ),
                            tabPanel("Homogeneity Plot",
                                     withSpinner(
                                       plotOutput(outputId = "homogeneity")),
                                     selectizeInput(inputId = "homovariables",
                                                    label = "Show variables:",
                                                    MergedColsContinous,
                                                    multiple = TRUE,
                                                    selected = MergedColsContinous[1]),
                                     checkboxInput(inputId = "homoscale",
                                                   label = "Scale",
                                                   value = FALSE),
                                     checkboxInput(inputId = "homocentre",
                                                   label = "Centre",
                                                   value = FALSE),
                                     checkboxInput(inputId = "homolegend",
                                                   label = "Show legend",
                                                   value = FALSE)
                            )



                            
                            
                          ))
               )),

      tabPanel("Trends",
               tabsetPanel(
                 tabPanel("Discussion", htmlOutput("HTMLTrends")),
                 
                 tabPanel("Categories",
                          tabsetPanel(
                            spinnerPanel("Sets Per Year", plotlyOutput(outputId = "yearCounts")),
                            spinnerPanel("Themes", plotOutput(outputId = "theme")),
                            spinnerPanel("Subthemes", plotOutput(outputId = "subthemes")),
                            spinnerPanel("Theme Groups", plotOutput(outputId = "themeGroup")),
                            spinnerPanel("Theme IPs", plotOutput(outputId = "licensed")),
                            spinnerPanel("Category", plotOutput(outputId = "category")),
                            spinnerPanel("Packaging Type", plotOutput(outputId = "packagingType")),
                            spinnerPanel("Availability", plotOutput(outputId = "availability"))
                          )),
                 
                 tabPanel("Dimensions",
                          tabsetPanel(
                            spinnerPanel("All", uiOutput("dimensionsAll")),
                            spinnerPanel("Licensed", uiOutput("dimensionsLicensed")),
                            spinnerPanel("Original", uiOutput("dimensionsOriginal")),
                            spinnerPanel("Hybrid", uiOutput("dimensionsHybrid"))
                          )),
                          

                 
                 tabPanel("Prices",
                          tabsetPanel(
                            tabPanel("Price Boxplots",
                                     withSpinner(
                                       plotOutput(outputId = "priceBoxplot")),
                                     selectizeInput(inputId = "priceBoxVariables",
                                                    label = "Show variables:",
                                                    MergedColsPrice,
                                                    multiple = TRUE,
                                                    selected = MergedColsPrice),
                                     checkboxInput(inputId = "priceBoxCentre",
                                                   label = "Centre",
                                                   value = TRUE),
                                     checkboxInput(inputId = "priceBoxScale",
                                                   label = "Scale",
                                                   value = TRUE),
                                     checkboxInput(inputId = "priceBoxOutliers",
                                                   label = "Show outliers",
                                                   value = TRUE),
                                     checkboxInput(inputId = "priceBoxLabels",
                                                   label = "Label outliers",
                                                   value = TRUE),
                                     sliderInput(inputId = "priceBoxIQR",
                                                 label = "IQR Multiplier",
                                                 min = 0,
                                                 max = 5,
                                                 step = 0.1,
                                                 value = 1.5)
                            ),
                            
                            
                            tabPanel("SetID Price by Year",
                                     withSpinner(
                                       plotOutput(outputId = "setYearPrice")
                                     ),
                                     selectizeInput(inputId = "setYearPriceYear",
                                                    label = "Select a Release Year:",
                                                    choices = NULL),
                                     uiOutput("setIDSelector")  # Dynamically generate setID choices based on selected year
                            ),
                            
                            tabPanel("Average Price by Year",
                                     withSpinner(
                                       plotOutput(outputId = "priceAverages")),
                                     selectizeInput(inputId = "priceColumn",
                                                    label = "Select a Price Column:",
                                                    choices = MergedColsPrice, 
                                                    selected = MergedColsPrice[1],
                                                    multiple = TRUE)
                            ),
                            
                            tabPanel("Price vs Numeric",
                                     withSpinner(
                                       plotOutput(outputId = "characteristicsPricePlot")),
                                     selectInput("priceVariable", "Select Price Variable:",
                                                 choices = priceVars),
                                     selectInput("characteristicVariable", "Select Lego Characteristic:",
                                                 choices = NULL)
                                     
                            ),
                            
                            tabPanel("Price vs Categorical",
                                     withSpinner(
                                       plotOutput(outputId = "characteristicsBoxPlot")),
                                     selectInput("priceVariableCat", "Select Price Variable:",
                                                 choices = priceVars),
                                     selectInput("catVariable", "Select Lego Characteristic:",
                                                 choices = NULL),
                                     checkboxInput("catBoxOutliers", "Show outliers", value = TRUE),
                                     sliderInput("catBoxIQR", "IQR Multiplier", min = 0, max = 5, step = 0.1, value = 1.5),
                                     checkboxInput("centerData", "Center Data", FALSE),
                                     checkboxInput("scaleData", "Scale Data", FALSE)
                            )

                            
                            
                            )),
                            
                            
                            
                            
                  tabPanel("Clusters",
                          tabsetPanel(
                            spinnerPanel("Subset 2019 Cluster Choices", plotOutput(outputId = "DsClusterCheck")),
                            tabPanel("Subset 2019 Clusters (2)",
                                     plotOutput("DsClusterVis2"),
                                     dataTableOutput("DsClusterSummary2"),
                                     plotOutput("DsClusterLicensed2"),
                                     plotOutput("DsClusterTheme2")
                            ),
                            
                            tabPanel("Subset 2019 Clusters (3)",
                                     plotOutput("DsClusterVis3"),
                                     dataTableOutput("DsClusterSummary3"),
                                     plotOutput("DsClusterLicensed3"),
                                     plotOutput("DsClusterTheme3")
                            ),
                            
                            spinnerPanel("Subset 2022 Clusters Choices", plotOutput(outputId = "MPClusterCheck")),
                            tabPanel("Subset 2022 Clusters (2)",
                                     plotOutput("MPClusterVis2"),
                                     dataTableOutput("MPClusterSummary2"),
                                     plotOutput("MPClusterLicensed2"),
                                     plotOutput("MPClusterTheme2")
                            ),
                            
                            tabPanel("Subset 2022 Clusters (3)",
                                     plotOutput("MPClusterVis3"),
                                     dataTableOutput("MPClusterSummary3"),
                                     plotOutput("MPClusterLicensed3"),
                                     plotOutput("MPClusterTheme3")
                            ),
                            
                          )),

               )),

      tabPanel("Machine Learning Models",
               tabsetPanel(
                 tabPanel("Discussion", htmlOutput("HTMLML")),

                 tabPanel("Data Subset 2019",
                          tabsetPanel(
                            spinnerPanel("Overview", verbatimTextOutput(outputId = "glimpsesubset18")),
                            spinnerPanel("DataFrame Table", dataTableOutput(outputId = "dftablesubset18")),
                            spinnerPanel("DataFrame Summary", verbatimTextOutput(outputId = "dfsummarysubset18")),
                            spinnerPanel("Missingness", plotOutput(outputId = "vismisssubset18")),
                            spinnerPanel("Cleaned", verbatimTextOutput(outputId = "glimpsesubset18Clean")),
                            spinnerPanel("Cleaned Missingness", plotOutput(outputId = "vismisssubset18Clean"))
                          )),
                 
                 tabPanel("Models Predicting 2019 Price",
                          tabsetPanel(
                            tabPanel("Training Metrics",
                                     withSpinner(
                                       plotOutput(outputId = "metrics18")),
                                     selectizeInput(inputId = "metrics18Data",
                                                    label = "Selected Model:",
                                                    choices = MetricsOptions,
                                                    selected = MetricsOptions[1]),
                                     withSpinner(
                                       plotOutput(outputId = "metrics18box")),
                                     selectizeInput(inputId = "metrics18boxData",
                                                    label = "Selected Metric:",
                                                    choices = MetricsTypes,
                                                    selected = MetricsTypes[1])
                            ),
                            
                            tabPanel("Training Hyperparameters",
                                     withSpinner(
                                       plotOutput(outputId = "hyper18")),
                                     selectizeInput(inputId = "hyper18Data",
                                                    label = "Selected Model:",
                                                    choices = HyperOptions,
                                                    selected = HyperOptions[1])
                            ),
                            
                            tabPanel("Training Features",
                                     withSpinner(
                                       plotOutput(outputId = "feature18")),
                                     selectizeInput(inputId = "feature18Data",
                                                    label = "Selected Model:",
                                                    choices = FeatureOptions,
                                                    selected = FeatureOptions[1])
                            ),
                            
                            tabPanel("Testing Metrics",
                                     withSpinner(
                                       plotOutput(outputId = "metrics18Test")),
                                     selectizeInput(inputId = "metrics18TestData",
                                                    label = "Selected Model:",
                                                    choices = HyperOptions,
                                                    selected = HyperOptions[1]),
                                     withSpinner(
                                       plotOutput(outputId = "metrics18Testbox")),
                                     selectizeInput(inputId = "metrics18TestboxData",
                                                    label = "Selected Metric:",
                                                    choices = MetricsTypes,
                                                    selected = MetricsTypes[1])
                            ),
                            
                            tabPanel("Testing Hyperparameters",
                                     withSpinner(
                                       plotOutput(outputId = "hyper18Test")),
                                     selectizeInput(inputId = "hyper18TestData",
                                                    label = "Selected Model:",
                                                    choices = HyperOptions,
                                                    selected = HyperOptions[1])
                            ),
                            
                            tabPanel("Testing Features",
                                     withSpinner(
                                       plotOutput(outputId = "feature18Test")),
                                     selectizeInput(inputId = "feature18TestData",
                                                    label = "Selected Model:",
                                                    choices = FeatureOptions,
                                                    selected = FeatureOptions[1])
                            )
                            
                            
                            
                          )),
                 
                 tabPanel("Data Subset 2022",
                          tabsetPanel(
                            spinnerPanel("Overview", verbatimTextOutput(outputId = "glimpsesubset22")),
                            spinnerPanel("DataFrame Table", dataTableOutput(outputId = "dftablesubset22")),
                            spinnerPanel("DataFrame Summary", verbatimTextOutput(outputId = "dfsummarysubset22")),
                            spinnerPanel("Missingness", plotOutput(outputId = "vismisssubset22")),
                            spinnerPanel("Cleaned", verbatimTextOutput(outputId = "glimpsesubset22Clean")),
                            spinnerPanel("Cleaned Missingness", plotOutput(outputId = "vismisssubset22Clean"))
                          )),
                 
                 tabPanel("Models Predicting 2022 Price",
                          tabsetPanel(
                            tabPanel("Training Metrics",
                                     withSpinner(
                                       plotOutput(outputId = "metrics22")),
                                     selectizeInput(inputId = "metrics22Data",
                                                    label = "Selected Model:",
                                                    choices = MetricsOptions,
                                                    selected = MetricsOptions[1]),
                                     withSpinner(
                                       plotOutput(outputId = "metrics22box")),
                                     selectizeInput(inputId = "metrics22boxData",
                                           label = "Selected Metric:",
                                           choices = MetricsTypes,
                                           selected = MetricsTypes[1])
                            ),
                            
                            tabPanel("Training Hyperparameters",
                                     withSpinner(
                                       plotOutput(outputId = "hyper22")),
                                     selectizeInput(inputId = "hyper22Data",
                                                    label = "Selected Model:",
                                                    choices = HyperOptions,
                                                    selected = HyperOptions[1])
                            ),
                            
                            tabPanel("Training Features",
                                     withSpinner(
                                       plotOutput(outputId = "feature22")),
                                     selectizeInput(inputId = "feature22Data",
                                                    label = "Selected Model:",
                                                    choices = FeatureOptions,
                                                    selected = FeatureOptions[1])
                                     
                            ),
                            
                            tabPanel("Testing Metrics",
                                     withSpinner(
                                       plotOutput(outputId = "metrics22Test")),
                                     selectizeInput(inputId = "metrics22TestData",
                                                    label = "Selected Model:",
                                                    choices = HyperOptions,
                                                    selected = HyperOptions[1]),
                                     withSpinner(
                                       plotOutput(outputId = "metrics22Testbox")),
                                     selectizeInput(inputId = "metrics22TestboxData",
                                                    label = "Selected Metric:",
                                                    choices = MetricsTypes,
                                                    selected = MetricsTypes[1])
                            ),
                            
                            tabPanel("Testing Hyperparameters",
                                     withSpinner(
                                       plotOutput(outputId = "hyper22Test")),
                                     selectizeInput(inputId = "hyper22TestData",
                                                    label = "Selected Model:",
                                                    choices = HyperOptions,
                                                    selected = HyperOptions[1])
                            ),
                            
                            tabPanel("Testing Features",
                                     withSpinner(
                                       plotOutput(outputId = "feature22Test")),
                                     selectizeInput(inputId = "feature22TestData",
                                                    label = "Selected Model:",
                                                    choices = FeatureOptions,
                                                    selected = FeatureOptions[1])
                                     
                            )



                          ))
                 
               ))
    )
))


