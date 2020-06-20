library(plyr)
library(data.table)

## Read in training set, labels and subjects
xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")
labels_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

## Read in test set, labels and subjects
xtest <- read.table("UCI HAR Dataset/test/X_test.txt")
labels_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

## Merge datasets
alldata <- rbind(xtrain, xtest)

## Load features descriptor
features <- read.table("UCI HAR Dataset/features.txt")

## Identify features with mean or std
meanstd <- grepl("mean\\(\\)|std\\(\\)", features[,2])

## Extract features with mean or std from alldata
filtereddata <- alldata[,meanstd]

## Combine subject and activity labels for test and training data
all_subjects <- rbind(subject_train, subject_test)
all_labels <- rbind(labels_train, labels_test)

## Replace activity numbers with descriptive activity names
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activities <- join(all_labels, activities)
filtereddata <- cbind(activities[,2], filtereddata)

## Add subject ID to data frame
filtereddata <- cbind(all_subjects, filtereddata)

## Label variables
selectedvars <- (grep("mean\\(\\)|std\\(\\)", features[,2], value = T))
colnames(filtereddata) = c("subject", "activity", selectedvars)
write.table(filtereddata, file = "alldata.txt", row.names = FALSE)

## Create new tidy dataset with average of each variable for each subject/activity pair
dt <- data.table(filtereddata)
dt2 <- dt[order(subject, activity), lapply(.SD, mean), by = .(subject, activity)]
write.table(dt2, file = "tidydata.txt", row.names = FALSE)