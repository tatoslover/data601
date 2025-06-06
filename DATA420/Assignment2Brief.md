# DATA420-23S2 (C) Assignment 2
## The Million Song Dataset (MSD)

**Due on Friday, October 20 by 5:00 PM.**

If you have any questions please email me (james.williams@canterbury.ac.nz).

### LEARN
- Help forum for Assignment 2
- Report upload (pdf only)
- Supplementary material upload (zip only, limited to 10 MB)

## Instructions

- You are encouraged to work together to understand and solve each of the tasks, but you must submit your own work.
- Any assignments submitted within 24 hours after the deadline will automatically receive a 10% penalty and any assignments submitted after that without obtaining an extension will received an immediate 50% penalty.
- The forum is a great place to ask questions about the assignment material. Any questions will be answered by the lecturer or tutors as soon as possible, students can also answer each other's questions, and you can all benefit from the answers and resulting discussion as well.
- All data under `hdfs:///data/` is read only. Please use your own home directory to store your outputs (e.g. `hdfs:///user/abc123/outputs/`).
- I recommend that you use the pyspark notebook provided on LEARN as this will make it easier for you to develop code and check outputs interactively.
- Please be mindful that you are sharing cluster resources. Keep an eye on Spark using the web user interface (mathmadslinux2p:8080), and don't leave a shell running for longer than necessary. Feel free to change the number of executors, cores, and memory you are using, but be prepared to scale down if others need to share those resources. If you need to ask someone to share their resources, email them using their user code (e.g. abc123@uclive.ac.nz). If they don't reply within a reasonable time, please email me and I will kill their shell.

## Reports

- The report should be submitted as a single pdf file via LEARN. Any additional code, images, and supplementary material should be submitted as a single zip file via LEARN. You should not submit any outputs as part of your supplementary material, leave these in your home directory in HDFS.
- The report should be no more than 15 pages long excluding any figures provided separately and any supplementary material. This does not include a cover page, table of contents, or references.
- You should reference any external resources using a citation format such as APA or MLA, including any online resources from which you obtained snippets of code and any use of ChatGPT.
- You should make sensible choices concerning margins, font size, spacing, and formatting. For example, margins between 0.5" and 1", a sans-serif font e.g. Arial with font size 11 or 12, line spacing 1 or 1.15, and sensible use of monospaced code blocks, tables, and images.
- Your report should have the following sections:
  - Background
  - Data processing
  - Audio similarity
  - Song recommendations
  - Conclusions

and should use the question numbers as subheadings to group the paragraphs, tables, and figures that you use to answer the questions that have been asked and explain your method.

- You should try to build an overall narrative rather than listing results and outputs, and you should explain any decisions that you made along the way.

## Sections

An overview of what you should include in each section is provided below.

### Background
In this section you should give an overview of what you have completed including any useful links or references to background material and a high level description of any difficulties that you had.

### Data processing
In this section you should give an overview of the structure of the datasets, give an overview of some applications that you could explore with machine learning, and answer the questions that have been asked.

### Audio similarity
In this section you should describe the continuous features and the categorical target for your classification algorithms in more detail, describe the algorithms, their strengths and weaknesses, and their hyperparameters, describe how you trained the algorithms to predict a binary and a multiclass outcome, discuss the performance of the algorithms, and talk about how you would do hyperparameter tuning. You should explain any decisions that you made about feature selection, splitting, sampling, hyperparameters, and metrics.

### Song recommendations
In this section you should describe the distributions of the user-song play counts, describe any choices that you had to make to use the counts for collaborative filtering, talk about the performance of the collaborative filtering model using some specific examples and the ranking metrics that you have evaluated, and discuss any other considerations for using the collaborative filtering model to generate recommendations in the real world. You should explain the implications of the choices that you had to make and discuss any other systems that you would need to generate recommendations for all users of your recommendation service.

### Conclusions
In this section you should give a high level summary of what you have done and any insights that you had. You should talk about any tasks that you were unable to complete and why.

---

# The Million Song Dataset (MSD)

In this assignment we will study a collection of datasets referred to as the Million Song Dataset (MSD), a project initiated by The Echo Nest and LabROSA. The Echo Nest was a research spin-off from the MIT Media Lab established with the goal of understanding the audio and textual content of recorded music, and was acquired by Spotify after 10 years for 50 million Euro.

## The Million Song Dataset (MSD)

The main dataset contains the song ID, the track ID, the artist ID, and 51 other fields, such as the year, title, artist tags, and various audio properties such as loudness, beat, tempo, and time signature. Note that track ID and song ID are not the same concept - the track ID corresponds to a particular recording of a song, and there may be multiple (almost identical) tracks for the same song. Tracks are the fundamental identifier, and are matched to songs. Songs are then matched to artists as well.

The Million Song Dataset also contains other datasets contributed by organisations and the community:
- SecondHandSongs (cover songs)
- musiXmatch dataset (song lyrics)
- Last.fm dataset (song-level tags and similarity)
- Taste Profile subset (user-song plays)
- thisismyjam-to-MSD mapping (user-song plays, imperfectly joined)
- tagtraum genre annotations (genre labels)
- All Music genre datasets (more genre labels)

We will focus on the Taste Profile and All Music datasets, but you are free to explore the other datasets on your own and as part of the challenges. There are many online resources and some publications exploring these datasets as well.

## Taste Profile

The Taste Profile dataset contains real user-song play counts from undisclosed organisations. All songs have been matched to identifiers in the main million song dataset and can be joined with this dataset to retrieve additional song attributes. This is an implicit feedback dataset as users interact with songs by playing them but do not explicitly indicate a preference for the song.

The dataset has an issue with the matching between the Taste Profile tracks and the million song dataset tracks. Some tracks were matched to the wrong songs, as the user data needed to be matched to song metadata, not track metadata. Approximately 5,000 tracks are matched to the wrong songs and approximately 13,000 matches are not verified. This is described in their blog post in detail.

## Audio Features (Vienna University of Technology)

The Music Information Retrieval research group at the Vienna University of Technology downloaded audio samples for 994,960 songs in the dataset which were available from an online content provider, most in the form of 30 or 60 second snippets. They used these snippets to extract a multitude of features to allow comparison between the songs and prediction of song attributes:

- Rhythm Patterns
- Statistical Spectrum Descriptors
- Rhythm Histograms
- Temporal Statistical Spectrum Descriptors
- Temporal Rhythm Histograms
- Modulation Frequency Variance
- Marsyas
- Timbral features
- jMir
- Spectral Centroid
- Spectral Rolloff Point
- Spectral Flux
- Compactness
- Spectral Variability
- Root Mean Square
- Zero Crossings
- Fraction of Low Energy Windows
- Low-level features derivatives
- Method of Moments
- Area of Moments
- Linear Predictive Coding (LPC)
- MFCC features

These features are described in detail on the million song dataset benchmarks downloads page and the audio feature extraction page, and the number of features is listed along with file names and sizes for the separate audio feature sets.

## MSD AllMusic Genre Dataset (MAGD)

Many song annotations have been generated for the MSD by sources such as Last.fm, musiXmatch, and the Million Song Dataset Benchmarks by Schindler et al. The latter contains song level genre and style annotations derived from the AllMusic online music guide. We will use the MSD All Music Genre Dataset (MAGD) provided by the Music Information Retrieval research group at the Vienna University of Technology.

This dataset is included on the million song dataset benchmarks downloads page and class frequencies are provided on the MSD AllMusic Genre Dataset (MAGD) details page as well. For more information about the genres themselves have a look at the AllMusic genres page.

---

# Data processing

The datasets that we need for the assignment have been copied to the following locations:

- **HDFS:** `hdfs:///data/msd/`
- **Windows:** `T:\courses\2023\DATA420-22S2\data\msd\`
- **Linux:** `/scratch-network/courses/2023/DATA420-22S2/data/msd/`

The `main/summary` directory contains the song metadata from the main million song dataset but none of the audio analysis, similar artists, or tags (see the page on getting the dataset). This is all we need to combine with the supplementary datasets below.

The `tasteprofile` directory contains the user-song play counts from the Taste Profile dataset as well as logs identifying mismatches that were identified and matches that were manually accepted.

The `audio` directory contains audio features sets from the Music Information Retrieval research group at the Vienna University of Technology. The `audio/attributes` directory contains attributes names from the header of the ARFF, the `audio/features` directory contains the audio features themselves, and the `audio/statistics` directory contains additional track statistics.

**Do not copy any of the data to your home directory.**

## Q1
Read through the documentation above and figure out how to read from each of the datasets. Make sure that you only read a subset of the larger datasets, so that you can develop your code efficiently without taking up too much of your time and the cluster resources.

(a) Give an overview of the structure of the datasets, including their sizes, formats, data types, and how each dataset has been stored in HDFS.

(b) Count the number of rows in each of the datasets. How do the counts compare to the total number of unique songs?

## Q2
Complete the following data preprocessing.

(a) Some of the tracks in the Million Song Dataset were matched to the wrong songs in the Taste Profile dataset and there is a list of song-track mismatches that were automatically identified and a list of mismatches that were manually accepted. Do we need to take any action to account for this based on the datasets that we are using in the sections below and how we are using them?

(b) Load the audio feature attribute names and types from the `audio/attributes` directory and think about how they can be used to define schemas for the audio feature datasets themselves. Note that the attribute files and feature datasets share the same prefix and that the attribute types are named consistently. Think about how you can automate the creation of StructType by mapping attribute types to pyspark.sql.types objects.

---

# Audio similarity

In this section you will explore using numerical representations of a song's audio waveform to predict its genre. If this is possible, it could enable an online music streaming service to offer a unique service to their customers. For example, it may be possible to compare songs based entirely on the way they sound, and to discover rare songs that are similar to popular songs even though they have no collaborative filtering relationship. This would enable users to have more precise control over variety, and to discover songs they would not have found any other way.

## Q1
There are multiple audio feature datasets, with different levels of detail. Pick one of the small datasets to use for the following.

(a) The audio features are continuous values, obtained using methods such as digital signal processing and psycho-acoustic modeling. Produce descriptive statistics for each feature column in the dataset you picked. Are any features strongly correlated?

(b) Load the MSD All Music Genre Dataset (MAGD). Visualize the distribution of genres for the songs that were matched.

(c) Merge the genres dataset and the audio features dataset so that every song has a label.

## Q2
First you will develop a binary classification model.

(a) Research and choose three classification algorithms from the spark.ml library. Justify your choice of algorithms, taking into account considerations such as explainability, interpretability, predictive accuracy, training speed, hyperparameter tuning, dimensionality, and issues with scaling.

Based on the descriptive statistics from Q1 part (a), decide what processing you should apply to the audio features before using them to train each model.

(b) Convert the genre column into a binary column that represents if the song is "Electronic" or some other genre. What is the class balance of the binary label?

(c) Split the dataset into training and test sets. You should use stratified random sampling to make sure the class balanced is preserved. You may also want to use a resampling method such as subsampling, oversampling, or observation weighting. Justify your overall approach and your choice of resampling method.

(d) Train each of the three classification algorithms that you chose in part (a).

(e) Use the test set to compute the compute a range of performance metrics for each model, such as precision, accuracy, and recall.

(f) Discuss the relative performance of each model and of the classification algorithms overall, taking into account the performance metrics that you computed in part (e). How does the class balance of the binary label affect the performance of the algorithms?

## Q3
Now you will think about hyperparameter tuning.

(a) Look up the hyperparameters for each of your classification algorithms. Try to understand how these hyperparameters affect the performance of each model and think about if you would have chosen different hyperparameter values for Q2 part (d).

(b) Explain how cross-validation works and why it is used for hyperparameter tuning.

(c) Explain how you would tune the hyperparameters of a classification algorithm in general, including how you would define the hyperparameter grid. How much do you expect hyperparmeter tuning would improve your performance metrics?

## Q4
Next you will extend your work above to predict across all genres instead.

(a) Choose one of your algorithms from Q2 that is capable of multiclass classification and describe how it can predict one class out of multiple classes.

(b) Convert the genre column into an integer index that encodes each genre consistently. Find a way to do this that requires the least amount of work by hand.

(c) Split your dataset into training and test sets, train the classification algorithm that you chose in part (b), and compute a range of performance metrics that are relevant to multiclass classification. Make sure you take into account the class balance in your comments. How has the performance of your model been affected by the inclusion of multiple genres?

---

# Song recommendations

In this section you will use the Taste Profile dataset to develop a song recommendation service based on collaborative filtering.

Collaborative filtering describes algorithms that generate songs recommendations for specific users based on the combined user-song play information from all users. These song recommendations are generated by embedding users and songs as numerical vectors in the same vector space, and selecting songs that are similar to the user based on cosine similarity.

## Q1
First it will be helpful to know more about the properties of the dataset before you being training the collaborative filtering model.

(a) Based on the size, format, and number of rows, do you think you should repartition and cache the Taste Profile dataset to improve efficiency when training a collaborative filtering model?

(b) How many unique songs are there in the dataset? How many unique users?

(c) How many different songs has the most active user played? What is this as a percentage of the total number of unique songs in the dataset?

(d) Visualize the distribution of song popularity and the distribution of user activity by collecting the counts of user plays per song and the counts of song plays per user respectively, and describe the shape of the distributions.

## Q2
Next you will train the collaborative filtering model.

(a) Collaborative filtering determines similar users and songs based on their combined play history. Songs which have been played only a few times and users who have only listened to a few songs will not contribute much information and are unlikely to improve the model. Create a clean dataset of user-song plays by removing songs which have been played less than N times and users who have listened to fewer than M songs in total. Choose sensible values for N and M, taking into account the total number of users and songs.

(b) Split the dataset into training and test sets. The test set should contain at least 25% of the plays in total. Note that due to the nature of the collaborative filtering model, you must ensure that every user in the test set has some user-song plays in the training set as well. Explain why this is required and how you have done this while keeping the selection as random as possible.

(c) Use the spark.ml library to train an implicit matrix factorization model using Alternating Least Squares (ALS).

(d) Select a few of the users from the test set by hand and use the model to generate some recommendations. Compare these recommendations to the songs the user has actually played. Comment on the effectiveness of the collaborative filtering model.

(e) Use the test set of user-song plays and recommendations from the collaborative filtering model to compute the following metrics:
- Precision @ 10
- NDCG @ 10
- Mean Average Precision (MAP)

Look up these metrics and explain why they are useful in evaluating the collaborate filtering model. Explore the limitations of these metrics in evaluating a collaborative filtering model or recommendation service in general. Suggest an alternative method for comparing two recommendation services in the real world.

Assuming that you could measure future user-song plays based on your recommendations, what other metrics could be useful?
