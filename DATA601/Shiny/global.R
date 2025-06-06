##
##
## Overview
##
##

# This is the global file for "From Bricks to Bucks: Exploring Influential Variables in Sales Patterns of Lego Sets"
# author: "Samuel Love, 84107034"
# Use in conjunction with server.R and ui.R files

##
##
## Packages (load order impacts functions)
##
##

library(car)
library(caret)
library(corrgram)
library(lattice)
library(magrittr)
library(MASS)
library(openxlsx)
library(plotly)
library(reshape2)
library(shiny)
library(shinyjs)
library(shinycssloaders)
library(summarytools)
library(visdat)
library(randomForest)
library(glmnet)
library(e1071)
library(tidyverse)
library(gridExtra)
library(cluster)
library(GGally)
library(DT)
library(purrr)

##
##
## Data
##
##

# setwd("/Users/samuellove/Documents/UC/23S3/DATA601/Code/Shiny") # Change this accordingly

Merged <- read.csv("Merged")
D15Raw <- read.csv("D15Raw")
D15Clean <- read.csv("D15Clean")
D18Raw <- read.csv("D18Raw")
D18Clean <- read.csv("D18Clean")
JBRaw <- read.csv("JBRaw")
JBClean <- read.csv("JBClean")
MPRaw <- read.csv("MPRaw")
MPClean <- read.csv("MPClean")
subset18 <- read.csv("subset18")
subset22 <- read.csv("subset22")
subset18Clean <- read.csv("subset18Clean")
subset22Clean <- read.csv("subset22Clean")

##
##
## Variable names
##
##

MergedCols <- colnames(as.data.frame(Merged))
MergedColsContinous <- c("yearReleased", "pieces", "minifigs", "rating", "reviewCount", "age", "height", "width", "depth", "weight")
MergedColsDiscrete <- c()
MergedColsPrice <- c("RRP", "price2015", "price2018", "price2019", "price2022", "price2015Standard", "price2018Standard", "price2019Standard")





licensedOpts <- c("All", "Licensed", "Original", "Hybrid")


varsNumeric <- c("pieces", "minifigs", "height", "width", "depth", "weight", "rating", "reviewCount", "age")
varsNumericSub <- c("pieces", "minifigs", "age")

varsCategoric <- c("theme", "subtheme","themeGroup", "licensed", "category", "packagingType", "availability")
varsCategoricSub <- c("theme", "subtheme", "licensed")


priceVars <- c("RRP", "price2015", "price2018", "price2019", "price2022")



##
##
## Missingness correlation
##
##

MergedMissingness <- Merged[, !(names(Merged) %in% c("setID", "theme", "name", "year", "price2015Standard", "price2018Standard", "price2019Standard", "licensed")), drop = FALSE]
MergedMissingness <- is.na(MergedMissingness) + 0

##
##
## Setup
##
##

set.seed(123) # For reproducibility

data_frames <- list(Merged = Merged,
                    D15Raw = D15Raw,
                    D15Clean = D15Clean,
                    D18Raw = D18Raw,
                    D18Clean = D18Clean,
                    JBRaw = JBRaw,
                    JBClean = JBClean,
                    MPRaw = MPRaw,
                    MPClean = MPClean,
                    subset18 = subset18,
                    subset18Clean = subset18Clean,
                    subset22 = subset22,
                    subset22Clean = subset22Clean)

listDataOutputs <- c("glimpse", "dftable", "dfsummary", "vismiss")

spinnerPanel <- function(title, content) {
  # Wraps content in a spinner
  # Used for improved readability
  tabPanel(title, withSpinner(content))
}

##
##
## Outliers (for manual inspection)
##
##

outlierPieces <- table(Merged$pieces)
outlierMinifigs <- table(Merged$minifigs)
outlierReviews <- table(Merged$reviewCount)

outlierRows <- c(404, # pieces
                 9858, # minifigs
                 7245, # minifigs
                 4763, # reviewCount
                 21774, # reviewCount
                 9249, # depth & weight
                 20912 # weight
)
outliers <- Merged[outlierRows, ]



##
##
## Price
##
##


Merged_with_price <- Merged %>%
  filter(!is.na(price2015) | !is.na(price2018) | !is.na(price2019) | !is.na(price2022)) %>%
  select(yearReleased, setID, price2015, price2018, price2019, price2022)





##
##
## Clusters
##
##

## Preparing the Ds data

DsPrices <- c("RRP", "price2015", "price2018", "price2019")

DsSubset <- subset18Clean

DsSubsetPrice <- DsSubset %>%
  select(all_of(DsPrices)) %>%
  scale(center = TRUE, scale = TRUE)
 
## Elbow method to find optimal clusters

DsWcss <- sapply(1:10, function(k) {
  kmeans(DsSubsetPrice, centers = k, nstart = 10)$tot.withinss
})

## Silhouette method to find optimal clusters

DsAvgSilWidth <- numeric(length = 9)

for(k in 2:10) {
  km_res <- kmeans(DsSubsetPrice, centers = k, nstart = 10)
  sil_widths <- silhouette(km_res$cluster, dist(DsSubsetPrice))
  DsAvgSilWidth[k-1] <- mean(sil_widths[, "sil_width"])
}

## Generating 2 and 3 clusters and attaching them

Ds2Cluster <- DsSubsetPrice %>% kmeans(centers = 2)
Ds3Cluster <- DsSubsetPrice %>% kmeans(centers = 3)

DsSubset$clusterGroup2 <- as.factor(Ds2Cluster$cluster)
DsSubset$clusterGroup3 <- as.factor(Ds3Cluster$cluster)

## Preparing the MP data

MPPrices <- "price2022"

MPSubset <- subset22Clean

MPSubsetPrice <- MPSubset %>%
  select(all_of(MPPrices)) %>%
  scale(center = TRUE, scale = TRUE)

## Elbow method to find optimal clusters

MPWcss <- sapply(1:10, function(k) {
  kmeans(MPSubsetPrice, centers = k, nstart = 10)$tot.withinss
})

## Silhouette method to find optimal clusters

MPAvgSilWidth <- numeric(length = 9)

for(k in 2:10) {
  km_res <- kmeans(MPSubsetPrice, centers = k, nstart = 10)
  sil_widths <- silhouette(km_res$cluster, dist(MPSubsetPrice))
  MPAvgSilWidth[k-1] <- mean(sil_widths[, "sil_width"])
}

## Generating the optimal 2 clusters and attaching them

MP2Cluster <- MPSubsetPrice %>% kmeans(centers = 2)
MP3Cluster <- MPSubsetPrice %>% kmeans(centers = 3)

MPSubset$clusterGroup2 <- as.factor(MP2Cluster$cluster)
MPSubset$clusterGroup3 <- as.factor(MP3Cluster$cluster)

##
##
## Machine Learning
##
##

## Importing model metrics

null18Metrics <- read.csv("null18Metrics")
LR18Metrics <- read.csv("LR18Metrics")
EN18Metrics <- read.csv("EN18Metrics")
RF18Metrics <- read.csv("RF18Metrics")
SVM18Metrics <- read.csv("SVM18Metrics")
EN18Hyper <- read.csv("EN18Hyper")
RF18Hyper <- read.csv("RF18Hyper")
SVM18Hyper <- read.csv("SVM18Hyper")
EN18Features <- read.csv("EN18Features")
RF18Features <- read.csv("RF18Features")

EN18TestMetrics <- read.csv("EN18TestMetrics")
RF18TestMetrics <- read.csv("RF18TestMetrics")
SVM18TestMetrics <- read.csv("SVM18TestMetrics")
EN18TestHyper <- read.csv("EN18TestHyper")
RF18TestHyper <- read.csv("RF18TestHyper")
SVM18TestHyper <- read.csv("SVM18TestHyper")
EN18TestFeatures <- read.csv("EN18TestFeatures")
RF18TestFeatures <- read.csv("RF18TestFeatures")

null22Metrics <- read.csv("null22Metrics")
LR22Metrics <- read.csv("LR22Metrics")
EN22Metrics <- read.csv("EN22Metrics")
RF22Metrics <- read.csv("RF22Metrics")
SVM22Metrics <- read.csv("SVM22Metrics")
EN22Hyper <- read.csv("EN22Hyper")
RF22Hyper <- read.csv("RF22Hyper")
SVM22Hyper <- read.csv("SVM22Hyper")
EN22Features <- read.csv("EN22Features")
RF22Features <- read.csv("RF22Features")

EN22TestMetrics <- read.csv("EN22TestMetrics")
RF22TestMetrics <- read.csv("RF22TestMetrics")
SVM22TestMetrics <- read.csv("SVM22TestMetrics")
EN22TestHyper <- read.csv("EN22TestHyper")
RF22TestHyper <- read.csv("RF22TestHyper")
SVM22TestHyper <- read.csv("SVM22TestHyper")
EN22TestFeatures <- read.csv("EN22TestFeatures")
RF22TestFeatures <- read.csv("RF22TestFeatures")

## Preparing for visualising

MetricsOptions <- c("Null Model", "Linear Regression", "Elastic Net", "Random Forest", "Support Vector Machine")
MetricsTypes <- c("R2", "RMSE", "MAE")
HyperOptions <- c("Elastic Net", "Random Forest", "Support Vector Machine")
FeatureOptions <- c("Elastic Net", "Random Forest")

## 2019 Train

metrics_list18 <- list(
  "Null Model" = null18Metrics,
  "Linear Regression" = LR18Metrics,
  "Elastic Net" = EN18Metrics,
  "Random Forest" = RF18Metrics,
  "Support Vector Machine" = SVM18Metrics
)

MetricMappings18 <- lapply(metrics_list18, function(df) {
  df %>% pivot_longer(
    cols = c("R2", "RMSE", "MAE"),
    names_to = "Metric",
    values_to = "Value"
  )
})

HyperMappings18 <- list(
  "Elastic Net" = EN18Hyper %>% 
    pivot_longer(
      cols = c("alpha", "lambda"),
      names_to = "Hyperparameter",
      values_to = "Value"
    ),
  
  "Random Forest" = RF18Hyper %>%
    mutate(Hyperparameter = "mtry", 
           Value = mtry) %>%
    select(-mtry),
  
  "Support Vector Machine" = SVM18Hyper %>% 
    pivot_longer(
      cols = c("sigma", "C"),
      names_to = "Hyperparameter",
      values_to = "Value"
    )
)

FeatureMappings18 <- list(
  "Elastic Net" = EN18Features,
  "Random Forest" = RF18Features
)

## 2019 Test

metrics_list18Test <- list(
  "Elastic Net" = EN18TestMetrics,
  "Random Forest" = RF18TestMetrics,
  "Support Vector Machine" = SVM18TestMetrics
)

MetricMappings18Test <- lapply(metrics_list18Test, function(df) {
  df %>% pivot_longer(
    cols = c("R2", "RMSE", "MAE"),
    names_to = "Metric",
    values_to = "Value"
  )
})

HyperMappings18Test <- list(
  "Elastic Net" = EN18TestHyper %>% 
    pivot_longer(
      cols = c("alpha", "lambda"),
      names_to = "Hyperparameter",
      values_to = "Value"
    ),
  
  "Random Forest" = RF18TestHyper %>%
    mutate(Hyperparameter = "mtry", 
           Value = mtry) %>%
    select(-mtry),
  
  "Support Vector Machine" = SVM18TestHyper %>% 
    pivot_longer(
      cols = c("sigma", "C"),
      names_to = "Hyperparameter",
      values_to = "Value"
    )
)

FeatureMappings18Test <- list(
  "Elastic Net" = EN18TestFeatures,
  "Random Forest" = RF18TestFeatures
)

## 2022 Train

metrics_list22 <- list(
  "Null Model" = null22Metrics,
  "Linear Regression" = LR22Metrics,
  "Elastic Net" = EN22Metrics,
  "Random Forest" = RF22Metrics,
  "Support Vector Machine" = SVM22Metrics
)

MetricMappings22 <- lapply(metrics_list22, function(df) {
  df %>% pivot_longer(
    cols = c("R2", "RMSE", "MAE"),
    names_to = "Metric",
    values_to = "Value"
  )
})

HyperMappings22 <- list(
  "Elastic Net" = EN22Hyper %>% 
    pivot_longer(
      cols = c("alpha", "lambda"),
      names_to = "Hyperparameter",
      values_to = "Value"
    ),
  
  "Random Forest" = RF22Hyper %>%
    mutate(Hyperparameter = "mtry", 
           Value = mtry) %>%
    select(-mtry),
  
  "Support Vector Machine" = SVM22Hyper %>% 
    pivot_longer(
      cols = c("sigma", "C"),
      names_to = "Hyperparameter",
      values_to = "Value"
    )
)

FeatureMappings22 <- list(
  "Elastic Net" = EN22Features,
  "Random Forest" = RF22Features
)

## 2022 Test

metrics_list22Test <- list(
  "Elastic Net" = EN22TestMetrics,
  "Random Forest" = RF22TestMetrics,
  "Support Vector Machine" = SVM22TestMetrics
)

MetricMappings22Test <- lapply(metrics_list22Test, function(df) {
  df %>% pivot_longer(
    cols = c("R2", "RMSE", "MAE"),
    names_to = "Metric",
    values_to = "Value"
  )
})

HyperMappings22Test <- list(
  "Elastic Net" = EN22TestHyper %>% 
    pivot_longer(
      cols = c("alpha", "lambda"),
      names_to = "Hyperparameter",
      values_to = "Value"
    ),
  
  "Random Forest" = RF22TestHyper %>%
    mutate(Hyperparameter = "mtry", 
           Value = mtry) %>%
    select(-mtry),
  
  "Support Vector Machine" = SVM22TestHyper %>% 
    pivot_longer(
      cols = c("sigma", "C"),
      names_to = "Hyperparameter",
      values_to = "Value"
    )
)

FeatureMappings22Test <- list(
  "Elastic Net" = EN22TestFeatures,
  "Random Forest" = RF22TestFeatures
)



