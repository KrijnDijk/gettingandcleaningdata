---
title: "Readme.md"
author: "me"
date: "19/06/2020"
output: html_document
---


```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, eval = FALSE)
```



# Codebook for Samsung data
##  Coursera "Getting and cleaning data" programming assignment

This file guides the reader through the scripts used to tidy the input data for the "Getting and cleaning data" programming assignment.  
  
This assumes that the source data (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) have been downloaded and extracted in the working directory. This should result in a folder named "UCI HAR Dataset" placed in the working directory.  
  
First, measurement data of the test and training set are read into R, as well as the data files that indicate subject and activity indices.  

```{r}
## Read in training set, labels and subjects
xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")
labels_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

## Read in test set, labels and subjects
xtest <- read.table("UCI HAR Dataset/test/X_test.txt")
labels_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
``` 
  
These datasets are then merged together  
```{r}
## Merge datasets
alldata <- rbind(xtrain, xtest)
```

This results in a data frame with each row corresponding to a subject/activity/time point combination, and each column representing data from one of 561 different features measured.  
Feature data can take any of several forms, including mean, sd, min, max, and others.  
To only select features that are representing by mean or sd, we first load in the txt file that indicates which column corresponds to what feature.  
```{r}
## Load features descriptor
features <- read.table("UCI HAR Dataset/features.txt")
```
  
  We then use grepl to create a logical vector that is TRUE when a feature contains the text "mean" or "SD":
```{r}
## Identify features with mean or std
meanstd <- grepl("mean|std", features[,2])
```  
  
  The data frame is then subsetted to only retain columns corresponding to these features.
  ```{r}
  ## Extract features with mean or std from alldata
filtereddata <- alldata[,meanstd]
```  
  
  We now add two columns to the data frame that indicate subject and activity. First we combine the files that tell us which row corresponds to which subject or activity from the training and test datasets.
  
```{r}
## Combine subject and activity labels for test and training data
all_subjects <- rbind(subject_train, subject_test)
all_labels <- rbind(labels_train, labels_test)
```
  
  The activity labels are indicated by numbers 1-6 which correspond to different activities. We replace the numbers by descriptive activity names, and then add this column to the original data frame. We then add a second column with subject ID.

```{r}
# Replace activity numbers with descriptive activity names
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities <- merge(all_labels, activities, sort = FALSE)
filtereddata <- cbind(activities[,2], filtereddata)

## Add subject ID to data frame
filtereddata <- cbind(all_subjects, filtereddata)
```
  
  Finally, we label columns with descriptive variable names and save the resulting data frame as "alldata.txt"

```{r}
## Label variables
selectedvars <- (grep("mean|std", features[,2], value = T))
colnames(filtereddata) = c("subject", "activity", selectedvars)
write.table(filtereddata, file = "alldata.txt", row.names = FALSE)
```
  
  
  This dataframe contains data for all timepoints analysed. For the second stage of the assignment, I create a new dataset that only reports the average data for all time points combined. I use the data table package for this. To summarise the data, I use lapply combined with .SD parameter of the data table package. This performs the function mean (specified as the second parameter for lapply) for all columns except the .by columns. The resulting table is saved as "tidydata.txt".
  
```{r}
  ## Create new tidy dataset with average of each variable for each subject/activity pair
library(data.table)
dt <- data.table(filtereddata)
dt2 <- dt[order(subject, activity), lapply(.SD, mean), by = .(subject, activity)]
write.table(dt2, file = "tidydata.txt", row.names = FALSE)
```