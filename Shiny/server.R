##
##
## Overview
##
##

# This is the server file for "From Bricks to Bucks: Exploring Influential Variables in Sales Patterns of Lego Sets"
# author: "Samuel Love, 84107034"
# Use in conjunction with global.R and ui.R files

shinyServer(function(input, output, session) {
  
  ##
  ##
  ## Data visualisations
  ##
  ##
  
  renderData <- function(data, output_id, output_type) {
    switch(output_type,
           glimpse = renderPrint({
             glimpse(data)
           }),
           dftable = renderDataTable({
             datatable(as.data.frame(data))
           }),
           dfsummary = renderPrint({
             dfSummary(data)
           }),
           vismiss = renderPlot({
             vis_miss(data) +
               xlab("Variables")
           })
    )
  }
  
  lapply(listDataOutputs, function(output_type) {
    lapply(names(data_frames), function(name) {
      output_id <- paste0(output_type, name)
      output[[output_id]] <- renderData(data_frames[[name]], output_id, output_type)
    })
  })
  
  output$corrMerged <- renderPlot({
    corrgram(cor(MergedMissingness),
             order = input$group, 
             abs = input$absolute, 
             cor.method = input$correlation)
    title(main = "Variable Missingness Correlation")
  })
  
  output$boxplot <- renderPlot({
    boxdata <- as.matrix(Merged[input$variablesbox])
    boxdata <- scale(Merged[input$variablesbox],
                     center = input$boxcentre,
                     scale = input$boxscale)
    Boxplot(y = boxdata,
                 id = input$boxlabeloutliers,
                 xlab = "Variable",
                 ylab = "Value",
                 notch = TRUE,
                 outline = input$boxshowoutliers,
                 range = input$range,
                 col = rainbow(ncol(boxdata)),
                 main = "Boxplots of numeric data")
  })
  
  output$risingvalue <- renderPlot({
    d <- Merged[input$variablesC]
    for (col in 1:ncol(d)) {
      d[,col] <- d[order(d[,col]),col]
    }
    d <- scale(x = d,
               center = input$standardiseB,
               scale = input$standardiseB)
    matplot(x = seq(1, 100, length.out = nrow(d)),
            y = d,
            type = "l",
            xlab = "Percentile",
            ylab = "Values",
            lty = 1,
            lwd = 1,
            col = rainbow(ncol(d)),
            main = "Rising-value chart")
    legend(legend = colnames(d),
           x = "topleft",
           y = "top",
           lty = 1,
           lwd = 1,
           col = rainbow(ncol(d)),
           ncol = round(ncol(d)^0.3))
  })
  
  output$homogeneity <- renderPlot({
    homo <- scale(Merged[input$homovariables],
                  center = input$homocentre,
                  scale = input$homoscale) 
    matplot(homo,
            type = "l",
            col = rainbow(ncol(homo)),
            xlab = "Observations in sequence",
            ylab = "Value",
            main = "Homogeneity plot")
    legend(legend = colnames(homo),
           x = "topleft",
           y = "top",
           lty = 1,
           lwd = 1,
           col = rainbow(ncol(homo)),
           plot = input$homolegend,
           ncol = round(ncol(homo)^0.3))
  })
  
  output$histogram <- renderPlot({
    ggplot2::ggplot(Merged[input$variablehist],
                    mapping = aes(x = Merged[,input$variablehist])) +
      geom_histogram(bins = input$bins) +
      labs(title = "Histogram Chart") +
      xlab("Variable")
  })
  
  ##
  ##
  ## Trend visualisations
  ##
  ##
  
  ## Categories

  output$yearCounts <- renderPlotly({
      plot_ly(
        data = Merged %>% group_by(yearReleased) %>% tally(),
        x = ~yearReleased,
        y = ~n,
        type = "bar"
      ) %>%
        layout(
          title = "Number of Lego sets per year of release ",
          xaxis = list(title = "Year Released"),
          yaxis = list(title = "Number of sets")
        )
  })
  
  renderCategories <- function(fill_var) {
    renderPlot({
      ggplot(Merged, aes(x = yearReleased, fill = !!sym(fill_var))) +
        geom_bar(stat = "count") +
        labs(title = paste(fill_var, "distribution over time"), x = "Year released", y = "Number of sets") +
        theme(legend.position = "right")
    })
  }
  
  lapply(varsCategoric, function(name) {
    output[[name]] <- renderCategories(name)
  })
  
  output$subthemes <- renderPlot({
    
    top_n_subthemes <- Merged %>%
      group_by(subtheme) %>%
      summarize(count = n()) %>%
      arrange(desc(count)) %>%
      top_n(50)
  
    Merged_with_category <- Merged %>%
      mutate(subtheme_category = ifelse(subtheme %in% top_n_subthemes$subtheme, as.character(subtheme), "other"))
    
      ggplot(Merged_with_category, aes(x = yearReleased, fill = subtheme_category)) +
        geom_bar(position = "stack") +
        labs(x = "Year", y = "Count") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "right")
  })
  
  ## Dimensions
  
  generate_plots_for_theme <- function(licensedOpts) {
    lapply(varsNumeric, function(dimensionVar) {
      outputId <- paste0(licensedOpts, dimensionVar, "Plot")
      output[[outputId]] <- renderPlot({
        filtered_data <- if (licensedOpts != "All") {
          Merged %>% filter(licensed == licensedOpts)
        } else {
          Merged
        }
        
        ggplot(filtered_data, aes_string(x = "yearReleased", y = dimensionVar)) +
          geom_point(color = "blue") +
          geom_smooth(method = "lm", se = FALSE, color = "red") +
          labs(title = paste(licensedOpts, "theme sets distribution of", dimensionVar),
               x = "Year", y = dimensionVar)
      })
      
      plotOutput(outputId)
    })
  }
  
  output$dimensionsAll <- renderUI({ generate_plots_for_theme("All") })
  output$dimensionsLicensed <- renderUI({ generate_plots_for_theme("Licensed") })
  output$dimensionsOriginal <- renderUI({ generate_plots_for_theme("Original") })
  output$dimensionsHybrid <- renderUI({ generate_plots_for_theme("Hybrid") })
  
  ##
  ## Prices
  ##
  
  output$priceBoxplot <- renderPlot({
    priceBoxData <- as.matrix(Merged[input$priceBoxVariables])
    priceBoxData <- scale(Merged[input$priceBoxVariables],
                          center = input$priceBoxCentre,
                          scale = input$priceBoxScale)
    Boxplot(y = priceBoxData,
            id = input$priceBoxLabels,
            xlab = "Price Variable",
            ylab = "Set Cost (USD)",
            notch = TRUE,
            outline = input$priceBoxOutliers,
            range = input$priceBoxIQR,
            col = rainbow(ncol(priceBoxData)),
            main = "Boxplots of Price Variables")
  })
  
  observe({
    years_with_data <- sort(unique(Merged_with_price$yearReleased))
    updateSelectizeInput(session, "setYearPriceYear", choices = years_with_data, server = TRUE)
  })
  
  output$setIDSelector <- renderUI({
    selected_year_data <- Merged_with_price %>%
      filter(yearReleased == input$setYearPriceYear) %>%
      select(setID) %>%
      distinct()

    selectizeInput("setYearPriceSetID",
                   "Select Set IDs:",
                   choices = selected_year_data$setID,
                   selected = selected_year_data$setID, # Select all by default
                   multiple = TRUE)
  })

  output$setYearPrice <- renderPlot({
    req(input$setYearPriceYear, input$setYearPriceSetID)
    
    filtered_data <- Merged_with_price %>%
      filter(yearReleased == input$setYearPriceYear, setID %in% input$setYearPriceSetID) %>%
      pivot_longer(cols = starts_with("price"), names_to = "PriceType", values_to = "Price") %>%
      na.omit()
    
    if(nrow(filtered_data) > 0) {
      ggplot(filtered_data, aes(x = setID, y = Price, color = PriceType)) +
        geom_point() +
        theme_minimal() +
        labs(title = paste("Prices by Set ID for the Year", input$setYearPriceYear),
             x = "Set ID", y = "Price") +
        theme(axis.text.x = element_text(angle = 90, hjust = 1))
    } else {
      return(ggplot() + 
               annotate("text", x = 0.5, y = 0.5, label = "No price data available", 
                        size = 5, hjust = 0.5, vjust = 0.5))
    }
  })

  output$priceAverages <- renderPlot({
    if (length(input$priceColumn) > 0) {
      avg_price_data <- lapply(input$priceColumn, function(column) {
        Merged %>%
          group_by(yearReleased) %>%
          summarize(AvgPrice = mean(get(column), na.rm = TRUE),
                    Column = column)
      }) %>% 
        bind_rows()
      
      ggplot(avg_price_data, aes(x = yearReleased, y = AvgPrice, color = Column)) +
        geom_line() +
        geom_point() +
        labs(title = "Average Price for Each Year of Release",
             x = "Year of Release",
             y = "Average Price") 
    }
  })
  
  
  reactiveVarsNumeric <- reactive({
    if (input$priceVariable == "RRP") {
      varsNumeric
    } else {
      varsNumericSub
    }
  })
  
  observe({
    updateSelectInput(session, "characteristicVariable", 
                      choices = reactiveVarsNumeric())
  })
  
  updateSelectInput(session, "priceVariable", 
                    choices = priceVars, 
                    selected = "RRP")
  
  output$characteristicsPricePlot <- renderPlot({

    plot_data <- Merged %>%
      select(setID, input$priceVariable, input$characteristicVariable) %>%
      na.omit()
    
    ggplot(plot_data, aes_string(x = input$characteristicVariable, y = input$priceVariable)) +
      geom_point() +
      geom_smooth(method = "lm", color = "red", se = FALSE) +
      theme_minimal() +
      labs(title = paste(input$characteristicVariable, "vs.", input$priceVariable),
           x = input$characteristicVariable, y = input$priceVariable)
  })
  
  
  reactiveVarsCategoric <- reactive({
    if (input$priceVariableCat == "RRP") {
      varsCategoric
    } else {
      varsCategoricSub
    }
  })
  
  observe({
    updateSelectInput(session, "catVariable", 
                      choices = reactiveVarsCategoric())
  })
  
  updateSelectInput(session, "priceVariableCat", 
                    choices = priceVars, 
                    selected = "RRP")
  
  output$characteristicsBoxPlot <- renderPlot({

    selectedData <- Merged %>%
      select(!!sym(input$priceVariableCat), !!sym(input$catVariable)) %>%
      na.omit()
    
    if(input$centerData) {
      selectedData[[input$priceVariableCat]] <- scale(selectedData[[input$priceVariableCat]], center = TRUE, scale = FALSE)
    }
    
    if(input$scaleData) {
      selectedData[[input$priceVariableCat]] <- scale(selectedData[[input$priceVariableCat]], center = FALSE, scale = TRUE)
    }
    
    longData <- reshape2::melt(selectedData, id.vars = input$catVariable)
    
    p <- ggplot(longData, aes_string(x = input$catVariable, y = "value", fill = input$catVariable)) +
      geom_boxplot(outlier.shape = ifelse(input$catBoxOutliers, 19, NA), coef = input$catBoxIQR) +
      scale_fill_manual(values = rainbow(length(unique(longData[[input$catVariable]])))) +
      theme_minimal() +
      labs(x = input$catVariable, y = "Set Cost (USD)", title = "Boxplots of Categorical Variables")
    
    print(p)
  })
  
  ##
  ## Clusters
  ##
  
  generateClusterCheckPlot <- function(wcss, avgSilWidth) {
    renderPlot({
      layout(matrix(1:2, nrow = 1))
      plot(1:10, wcss, type = "b", xlab = "Number of Clusters", ylab = "WCSS")
      title("Elbow Method")
      plot(2:10, avgSilWidth, type = "b", xlab = "Number of Clusters", ylab = "Average Silhouette Width")
      title("Silhouette Method")
    })
  }
  
  output$DsClusterCheck <- generateClusterCheckPlot(DsWcss, DsAvgSilWidth)
  output$MPClusterCheck <- generateClusterCheckPlot(MPWcss, MPAvgSilWidth)
  
  output$DsClusterVis2 <- renderPlot({
    ggpairs(DsSubset, columns = DsPrices, ggplot2::aes(color = as.factor(clusterGroup2))) + theme_minimal()
  })

  output$DsClusterSummary2 <- renderDataTable({
    DsSubset %>%
      group_by(clusterGroup2) %>%
      summarise(
        Count = n(), # Calculate the count of observations in each cluster
        across(where(is.numeric), ~ round(mean(.x, na.rm = TRUE), 2))
      )
  })

  output$DsClusterLicensed2 <- renderPlot({
    ggplot(DsSubset, aes(x = clusterGroup2, fill = licensed)) +
      geom_bar(position = "dodge") +
      labs(title = "Licensed Distribution Across Clusters", x = "Cluster Group 2", y = "Count", fill = "Licensed")
  })
  
  output$DsClusterTheme2 <- renderPlot({
    ggplot(DsSubset, aes(x = clusterGroup2, fill = theme)) +
      geom_bar(position = "dodge") +
      labs(title = "Theme Distribution Across Clusters", x = "Cluster Group 2", y = "Count", fill = "Theme")
  })
  
  output$DsClusterVis3 <- renderPlot({
    ggpairs(DsSubset, columns = DsPrices, ggplot2::aes(color = as.factor(clusterGroup3))) + theme_minimal()
  })
  
  output$DsClusterSummary3 <- renderDataTable({
    DsSubset %>%
      group_by(clusterGroup3) %>%
      summarise(
        Count = n(), # Calculate the count of observations in each cluster
        across(where(is.numeric), ~ round(mean(.x, na.rm = TRUE), 2))
      )
  })
  
  output$DsClusterLicensed3 <- renderPlot({
    ggplot(DsSubset, aes(x = clusterGroup3, fill = licensed)) +
      geom_bar(position = "dodge") +
      labs(title = "Licensed Distribution Across Clusters", x = "Cluster Group 3", y = "Count", fill = "Licensed")
  })
  
  output$DsClusterTheme3 <- renderPlot({
    ggplot(DsSubset, aes(x = clusterGroup3, fill = theme)) +
      geom_bar(position = "dodge") +
      labs(title = "Theme Distribution Across Clusters", x = "Cluster Group 3", y = "Count", fill = "Theme")
  })
  
  output$MPClusterVis2 <- renderPlot({
    ggpairs(MPSubset, columns = MPPrices, ggplot2::aes(color = as.factor(clusterGroup2))) + theme_minimal()
  })
  
  output$MPClusterSummary2 <- renderDataTable({
    MPSubset %>%
      group_by(clusterGroup2) %>%
      summarise(
        Count = n(), # Calculate the count of observations in each cluster
        across(where(is.numeric), ~ round(mean(.x, na.rm = TRUE), 2))
      )
  })
  
  output$MPClusterLicensed2 <- renderPlot({
    ggplot(MPSubset, aes(x = clusterGroup2, fill = licensed)) +
      geom_bar(position = "dodge") +
      labs(title = "Licensed Distribution Across Clusters", x = "Cluster Group 2", y = "Count", fill = "Licensed")
  })
  
  output$MPClusterTheme2 <- renderPlot({
    ggplot(MPSubset, aes(x = clusterGroup2, fill = theme)) +
      geom_bar(position = "dodge") +
      labs(title = "Theme Distribution Across Clusters", x = "Cluster Group 2", y = "Count", fill = "Theme")
  })
  
  output$MPClusterVis3 <- renderPlot({
    ggpairs(MPSubset, columns = MPPrices, ggplot2::aes(color = as.factor(clusterGroup3))) + theme_minimal()
  })
  
  output$MPClusterSummary3 <- renderDataTable({
    MPSubset %>%
      group_by(clusterGroup3) %>%
      summarise(
        Count = n(), # Calculate the count of observations in each cluster
        across(where(is.numeric), ~ round(mean(.x, na.rm = TRUE), 2))
      )
  })
  
  output$MPClusterLicensed3 <- renderPlot({
    ggplot(MPSubset, aes(x = clusterGroup3, fill = licensed)) +
      geom_bar(position = "dodge") +
      labs(title = "Licensed Distribution Across Clusters", x = "Cluster Group 3", y = "Count", fill = "Licensed")
  })
  
  output$MPClusterTheme3 <- renderPlot({
    ggplot(MPSubset, aes(x = clusterGroup3, fill = theme)) +
      geom_bar(position = "dodge") +
      labs(title = "Theme Distribution Across Clusters", x = "Cluster Group 3", y = "Count", fill = "Theme")
  })
  
  ##
  ##
  ## Machine Learning Visualisations
  ##
  ##
  
  output$metrics18 <- renderPlot({
    req(input$metrics18Data)
    
    selectedData <- lapply(input$metrics18Data, function(model) {
      MetricMappings18[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = Bootstrap_Sample, y = Value, color = Metric)) +
      geom_line() +
      theme_minimal() +
      ggtitle(paste({input$metrics18Data}, "Performance Metrics")) +
      xlab("Bootstrap Sample") +
      ylab("Metric Value")
  })
  
  output$metrics22 <- renderPlot({
    req(input$metrics22Data)

    selectedData <- lapply(input$metrics22Data, function(model) {
      MetricMappings22[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = Bootstrap_Sample, y = Value, color = Metric)) +
      geom_line() +
      theme_minimal() +
      ggtitle(paste({input$metrics22Data}, "Performance Metrics")) +
      xlab("Bootstrap Sample") +
      ylab("Metric Value")
  })
  
  output$metrics18box <- renderPlot({
    req(input$metrics18boxData)
    
    selectedData <- lapply(names(MetricMappings18), function(model) {
      df <- MetricMappings18[[model]]
      df <- df %>% 
        filter(Metric == input$metrics18boxData) %>%
        mutate(Model = model)
      return(df)
    }) %>% 
      bind_rows()
    
    means <- selectedData %>%
      group_by(Model) %>%
      summarise(MeanValue = mean(Value), .groups = 'drop')
    
    ggplot(selectedData, aes(x = Model, y = Value, fill = Model)) +
      geom_boxplot() +
      geom_text(data = means, aes(x = Model, y = MeanValue, label = round(MeanValue, 2)), 
                position = position_dodge(width = 0.75), 
                vjust = -2, 
                color = "black", size = 6) +
      theme_minimal() +
      ggtitle(paste({input$metrics18Data}, "Performance Metrics Boxplot")) +
      xlab("Metric") +
      ylab(paste(input$metrics18boxData, "Value"))
  })
  
  output$metrics22box <- renderPlot({
    req(input$metrics22boxData)
    
    selectedData <- lapply(names(MetricMappings22), function(model) {
      df <- MetricMappings22[[model]]
      df <- df %>% 
        filter(Metric == input$metrics22boxData) %>%
        mutate(Model = model)
      return(df)
    }) %>% 
      bind_rows()
    
    means <- selectedData %>%
      group_by(Model) %>%
      summarise(MeanValue = mean(Value), .groups = 'drop')
    
    ggplot(selectedData, aes(x = Model, y = Value, fill = Model)) +
      geom_boxplot() +
      geom_text(data = means, aes(x = Model, y = MeanValue, label = round(MeanValue, 2)), 
                position = position_dodge(width = 0.75), 
                vjust = -2, 
                color = "black", size = 6) +
      theme_minimal() +
      ggtitle(paste(input$metrics22boxData, "Performance Metrics Boxplot")) +
      xlab("Metric") +
      ylab(paste(input$metrics22boxData, "Value"))
  })
  
  output$hyper18 <- renderPlot({
    req(input$hyper18Data)
    
    selectedData <- lapply(input$hyper18Data, function(model) {
      HyperMappings18[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = bootstrap_sample, y = Value, color = Hyperparameter)) +
      geom_line() +
      theme_minimal() +
      labs(title = paste({input$hyper18Data}, "Optimal Hyperparameters"), x = "Bootstrap Sample", y = "Hyperparameter Value")
  })
  
  output$hyper22 <- renderPlot({
    req(input$hyper22Data)
    
    selectedData <- lapply(input$hyper22Data, function(model) {
      HyperMappings22[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = bootstrap_sample, y = Value, color = Hyperparameter)) +
      geom_line() +
      theme_minimal() +
      labs(title = paste({input$hyper22Data}, "Optimal Hyperparameters"), x = "Bootstrap Sample", y = "Hyperparameter Value")
  })

  output$feature18 <- renderPlot({
    req(input$feature18Data)
    
    selectedData <- lapply(input$feature18Data, function(model) {
      FeatureMappings18[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = reorder(Feature, Importance), y = Importance)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      theme_minimal() +
      labs(title = paste({input$feature18Data}, "Feature Importance Across Bootstrap Samples"),
           x = "Feature",
           y = "Importance")
  })

  output$feature22 <- renderPlot({
    req(input$feature22Data)
    
    selectedData <- lapply(input$feature22Data, function(model) {
      FeatureMappings22[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = reorder(Feature, Importance), y = Importance)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      theme_minimal() +
      labs(title = paste({input$feature22Data}, "Feature Importance Across Bootstrap Samples"),
           x = "Feature",
           y = "Importance")
  })
  
  
  
  
  
  
  
  
  
  
  
  output$metrics18Test <- renderPlot({
    req(input$metrics18TestData)
    
    selectedData <- lapply(input$metrics18TestData, function(model) {
      MetricMappings18Test[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = Bootstrap_Sample, y = Value, color = Metric)) +
      geom_line() +
      theme_minimal() +
      ggtitle(paste({input$metrics18TestData}, "Performance Metrics")) +
      xlab("Bootstrap Sample") +
      ylab("Metric Value")
  })
  
  output$metrics22Test <- renderPlot({
    req(input$metrics22TestData)
    
    selectedData <- lapply(input$metrics22TestData, function(model) {
      MetricMappings22Test[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = Bootstrap_Sample, y = Value, color = Metric)) +
      geom_line() +
      theme_minimal() +
      ggtitle(paste({input$metrics22TestData}, "Performance Metrics")) +
      xlab("Bootstrap Sample") +
      ylab("Metric Value")
  })
  
  output$metrics18Testbox <- renderPlot({
    req(input$metrics18TestboxData)
    
    selectedData <- lapply(names(MetricMappings18Test), function(model) {
      df <- MetricMappings18Test[[model]]
      df <- df %>% 
        filter(Metric == input$metrics18TestboxData) %>%
        mutate(Model = model)
      return(df)
    }) %>% 
      bind_rows()
    
    # Calculate means on the combined dataframe, `selectedData`
    means <- selectedData %>%
      group_by(Model) %>%
      summarise(MeanValue = mean(Value), .groups = 'drop') # Use .groups='drop' to avoid having to ungroup manually
    
    # Proceed with plotting code, including geom_text for mean values
    ggplot(selectedData, aes(x = Model, y = Value, fill = Model)) +
      geom_boxplot() +
      geom_text(data = means, aes(x = Model, y = MeanValue, label = round(MeanValue, 2)), 
                position = position_dodge(width = 0.75), 
                vjust = -1, 
                color = "black", size = 6) + # Adjust color and size as necessary
      theme_minimal() +
      ggtitle(paste(input$metrics18TestboxData, "Performance Metrics Boxplot")) +
      xlab("Metric") +
      ylab(paste(input$metrics18TestboxData, "Value"))
  })
  
  
  output$metrics22Testbox <- renderPlot({
    req(input$metrics22TestboxData)
    
    selectedData <- lapply(names(MetricMappings22Test), function(model) {
      df <- MetricMappings22Test[[model]]
      df <- df %>% 
        filter(Metric == input$metrics22TestboxData) %>%
        mutate(Model = model)
      return(df)
    }) %>% 
      bind_rows()
    
    # Calculate means on the combined dataframe, `selectedData`
    means <- selectedData %>%
      group_by(Model) %>%
      summarise(MeanValue = mean(Value), .groups = 'drop') # Use .groups='drop' to avoid having to ungroup manually
    
    # Proceed with plotting code, including geom_text for mean values
    ggplot(selectedData, aes(x = Model, y = Value, fill = Model)) +
      geom_boxplot() +
      geom_text(data = means, aes(x = Model, y = MeanValue, label = round(MeanValue, 2)), 
                position = position_dodge(width = 0.75), 
                vjust = -1, 
                color = "black", size = 6) + # Adjust color and size as necessary
      theme_minimal() +
      ggtitle(paste(input$metrics22TestboxData, "Performance Metrics Boxplot")) +
      xlab("Metric") +
      ylab(paste(input$metrics22TestboxData, "Value"))
  })
  
  output$hyper18Test <- renderPlot({
    req(input$hyper18TestData)
    
    selectedData <- lapply(input$hyper18TestData, function(model) {
      HyperMappings18Test[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = bootstrap_sample, y = Value, color = Hyperparameter)) +
      geom_line() +
      theme_minimal() +
      labs(title = paste({input$hyper18TestData}, "Optimal Hyperparameters"), x = "Bootstrap Sample", y = "Hyperparameter Value")
  })
  
  output$hyper22Test <- renderPlot({
    req(input$hyper22TestData)
    
    selectedData <- lapply(input$hyper22TestData, function(model) {
      HyperMappings22Test[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = bootstrap_sample, y = Value, color = Hyperparameter)) +
      geom_line() +
      theme_minimal() +
      labs(title = paste({input$hyper22TestData}, "Optimal Hyperparameters"), x = "Bootstrap Sample", y = "Hyperparameter Value")
  })
  
  output$feature18Test <- renderPlot({
    req(input$feature18TestData)
    
    selectedData <- lapply(input$feature18TestData, function(model) {
      FeatureMappings18Test[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = reorder(Feature, Importance), y = Importance)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      theme_minimal() +
      labs(title = paste({input$feature18TestData}, "Feature Importance Across Bootstrap Samples"),
           x = "Feature",
           y = "Importance")
  })
    
  output$feature22Test <- renderPlot({
    req(input$feature22TestData)
    
    selectedData <- lapply(input$feature22TestData, function(model) {
      FeatureMappings22Test[[model]]
    })
    
    selectedData <- selectedData %>% as.data.frame()
    
    ggplot(selectedData, aes(x = reorder(Feature, Importance), y = Importance)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      theme_minimal() +
      labs(title = paste({input$feature22TestData}, "Feature Importance Across Bootstrap Samples"),
           x = "Feature",
           y = "Importance")
  })
  
  
  
  ##
  ##
  ## HTML
  ##
  ##
  
  output$Title <- renderUI({
    HTML("
         <h2>Data Visualisation Dashboard</h2>
         <h4>UC DATA601_23X</h4>
         <h4>Samuel Love</h4>
         <h4>84107034</h4>

         ")
  })
  
  output$HTMLData <- renderUI({
    HTML("
          
         <h3>JB</h3>
          
         <p>
         The main dataset (JB) is provided by Jason Bryer in the JBryer/brickset R package, a package with tools to interact with the Brickset API. This dataset contains 19,409 observations of 36 variables of contextual Lego data. Notable variables include the year each set was released (from 1970 to 2023 inclusive), the number of pieces in each set, the number of minifigures in each set, the US recommended retail price, and the theme of each set. The unique identifier variable, SetID, is present for every row.
         </p>
         
         <p>
         This data will be useful for creating visualisations that show trends over time. It also serves as an excellent frame of reference for the price data as it provides many variables that can be used for machine learning. The only price data in this dataset is RRP so there are three supplementary datasets that contain secondary market pricing data.
         </p>
         
         <h3>D15 & D18</h3>
          
         <p>
         The main secondary price dataset (D15 & D18) is provided by Victoria Dobrynskaya, generated for the paper: LEGO - The Toy of Smart Investors. D15 contains 2332 rows of 11 variables, whilst D18 contains 2332 rows of 22 variables. This data was parsed from Brickpicker and represents the average of the 30 most recent transactions on Ebay for each set. D15 contains yearly average prices for new and used sets in 2015, whilst D18 contains monthly average prices for sets in 2018 and the first quarter of 2019. This data will be useful for visualising changes over time and machine learning. Common variables have the same number of unique values, indicating that these dataframes are near identical.
         </p>
         
         <h3>MP</h3>
         
         <p>
         Another supplementary dataset (MP) is provided by MRPANTHESON. This dataset contains 5075 rows of 9 variables. The secondary prices for the year 2022 were scraped across different sellers whilst other parameters were sourced from Rebrickable.
         </p>
         
         <h3>Merged</h3>

        <p>
        The result of joining the four datasets by the column setID into one is the dataset referred to as Merged. Merged has 26324 observations of 29 variables. This is 6915 more than the JB dataset. As there are 2322 observations in D15 and D18, and 5075 observations in MP, there are only 482 setIDs that were common amongst the datasets. This caused high rates of missingness.
        </p>
          
          ")
  })
  
  
  output$HTMLTrends <- renderUI({
    HTML("
         <h3>Details</h3>
         
         <p>
         Categories show the number of sets released each year, and time-series visualisations of categorical variables.
         Dimensions shows time-series visualisations of numerical varaiables, categorised by licensing type.
         Prices shows various comparisons of price variables.
         Clusters shows the effects of clustering two subsets of Merged into two and three clusters.
         </p>
         
         ")
  })
  
  
  output$HTMLML <- renderUI({
    HTML("
         <h3>Details</h3>
         
        <p>
        The caret package streamline(s) the process for creating predictive models. The documentation is extensive and was used to develop the machine learning process for this project.
        </p>
        
        <p>
        The goal is to use supervised learning to predict prices for 2019 and 2022.
        Since most algorithms require datasets with complete cases, the subsets have no missingness.
        The 2019 subset has 2,277 observations of 12 variables.
        The 2022 subset has 3,241 observations of 7 variables.
        Comparisons of subsets will reveal the effects of price variables (RRP, price2015, and price2018) that are present only in the 2019 subset.
        </p>
        
        <p>
        In preparation for training, the categorical variables theme and licensed were one-hot-encoded, with theme being grouped into 'superthemes' to reduce cardinality. All variables were centred and scaled to allow equitable treatment by the algorithms, enabling fair comparisons. Data is split into training and testing sets using a 75/25 ratio. The training set was used to generate 20 bootstraps to enable training distributions of each model that will give a clearer indication of performance.
        </p>
        
        <p>
        Using a range of algorithms increases the chances of finding a successful model. Selected algorithms are linear regression (LR), elastic net (EN), random forest (RF), and support vector machine (SVM). A null model was included as a comparative baseline.
        </p>
        
        <p>
        There are three metrics suitable for regression machine learning problems. R-squared (R2) measures the proportion of variance in the dependent variable that is predictable from the independent variables. Root Mean Square Error (RMSE) measures the standard deviation of the residuals. Mean Absolute Error (MAE) measures the average absolute difference between the observed outcomes and the predictions.
        </p>
        
        <p>
        EN, RF, and SVM have tuneable hyperparameters. These were tuned using a Cartesian grid search to methodically find the best performing model. EN grid tried 5 values for alpha and 10 for lambda. RF grid tried 4 values for mtry. SVM grid tried 4 values for C and 10 for Sigma. This results in training 50 EN models, 4 RF models, and 40 SVM models on each bootstrap. With 20 bootstraps, we train 1885 models in total on each subset of data. This is computationally expensive but achievable with such small datasets. Only EN and RF have built-in feature selection.
        </p>
         
         ")
  })
    
})  
  
