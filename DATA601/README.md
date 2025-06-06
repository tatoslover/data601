# Overview

Code for my DATA601 (capstone project) paper of the Master of Applied Data Science at the University of Canterbury.

Files of interest are server.R, ui.R, and global.R, which together create the shiny application: https://samsdata601.shinyapps.io/DATA601/

# Course Description | Whakamahuki

This project will give you the skills, and experience to work in a team to solve real world data science problems.

# Project Brief

## Project Title

LEGOscape: A Holistic Data Exploration of Sets, Sentiments, and Systems in the LEGO Universe.

## Background

LEGO is a popular brand of toy building bricks. They are often sold in sets with instructions in order to build a specific object. Each set contains a number of parts in different shapes, sizes and colors. A database that can be found here: https://www.kaggle.com/datasets/rtatman/lego-database contains LEGO Parts/Sets/Colors and Inventories of every official LEGO set in the Rebrickable database. These files are current as of July 2017. This database contains information on which parts are included in different LEGO sets. It was originally compiled to help people who owned some LEGO sets already figure out what other sets they could build with the pieces they had. This is a very rich dataset that offers lots of rooms for exploration, especially since the “sets” file includes the year in which a set was first released. Leveraging LEGO datasets can offer numerous opportunities for some interesting data science, these spans from data visualization to machine learning.

## Goals

Project Goals

The goals of this project include, but are not limited to, the following:

1. Update Database
-	Use the Kaggle dataset as a starting point.
-	Use the Rebrickable API to update the data with the most current information.

2. Exploratory Data Analysis (EDA)
-	Examine the distribution of LEGO sets across years, themes, and piece counts.
- Objectives:
	-	Explore trends and patterns related to set releases and retirements.
	-	Identify the most popular themes and the average lifespan of sets.
- Tools/Skills: R, RStudio, Python, Pandas, Matplotlib, Seaborn

3. Data Visualization
-	Build interactive dashboards to display LEGO statistics.
- Objectives:
	-	Visualize the evolution of LEGO colors and piece complexity over time.
	-	Map the popularity of different themes and set sizes.
- Tools/Skills: Shiny, Tableau, Plotly, Dash, D3.js

4. Price Prediction Model
-	Develop a model to estimate the resale price of retired LEGO sets using features like piece count, theme, and release year.
- Objectives:
	-	Evaluate feature importance in predicting resale prices.
	-	Optimize the model for both accuracy and interpretability.
- Tools/Skills: Caret, MLR3, AutoML, Scikit-learn, Feature Engineering

5. Sentiment Analysis
-	Analyze customer reviews of LEGO sets to extract sentiment and thematic patterns.
- Objectives:
	-	Identify the most loved and disliked aspects of different LEGO sets.
	-	Explore how sentiment varies across themes and set complexity.
- Tools/Skills: Natural Language Processing, TextBlob, NLTK

6. Cluster Analysis
- Group LEGO sets into clusters based on features and user ratings.
- Objectives:
	-	Discover underlying patterns and groupings within the dataset.
	-	Analyze how these clusters relate to user preferences and buying behavior.
- Tools/Skills: K-Means, Hierarchical Clustering, DBSCAN, Python

7. Network Analysis
- Build a network graph to examine relationships between LEGO themes and sets.
- Objectives:
	-	Identify the most interconnected sets and themes.
	-	Explore how the LEGO theme network has evolved over time.
- Tools/Skills: NetworkX, Graph Theory, Python

## Data Sources

Remember to verify the availability, quality, and legality of any dataset you intend to use. Numerous public datasets related to LEGO are available for analysis. Here are a few places where you can find such datasets:
1. Kaggle
- Kaggle is a rich resource for datasets. You can find LEGO datasets by searching for LEGO in the datasets section of the website.
- [LEGO Dataset on Kaggle](https://www.kaggle.com/rtatman/lego-database)
2. Rebrickable
- Rebrickable provides extensive data on LEGO sets, including details on individual bricks, colors, and set inventories. They offer a comprehensive API that allows you to access a wealth of data on LEGO products.
- [Rebrickable API](https://rebrickable.com/api/)
3. Brickset
- Brickset is another site that offers detailed information about LEGO sets, and they also provide an API that you can use to access their data programmatically.
- [Brickset API](https://brickset.com/tools/webservices)
4. LEGO Official Site
- Sometimes, official sites offer APIs or data downloads. Check the LEGO site for any available public data resources or developer APIs.
- [LEGO API Documentation](https://www.lego.com/en-us/service/open-api/documentation)
5. GitHub
- GitHub might also have some user-uploaded LEGO datasets, typically in repositories related to specific projects. These can be valuable resources, but availability and data quality may vary.
- Example search: “LEGO dataset GitHub”
6. Public Data Repositories
- You may also find LEGO datasets on various public data repositories like the UCI Machine Learning Repository, Google Dataset Search, or AWS Open Data Registry.

## Points to Note

When using public datasets, it’s essential to review the licensing and usage restrictions that accompany the data. Additionally, while these sources may provide rich datasets, you might need to clean and preprocess the data depending on your project needs.
