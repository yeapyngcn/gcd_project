
## This is script for Getting & Cleaning Data course project work.
## 1. Merges the training and the test sets to create one data set.
## Importing training data

library(data.table)
library(plyr)
library(reshape)

activities <- read.csv("./UCI HAR Dataset/activity_labels.txt", header = FALSE, as.is=TRUE)

sub_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE, as.is=TRUE)
act_train <- read.csv("./UCI HAR Dataset/train/y_train.txt", header = FALSE, as.is=TRUE)
data_train <- read.table("./UCI HAR Dataset/train/x_train.txt", header = FALSE, as.is=TRUE)
data_train <- cbind(act_train[,1], data_train)
data_train <- cbind(sub_train[,1], data_train)
names(data_train)[1:2] <- c("subject", "activity")

## Importing test data
sub_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE, as.is=TRUE)
act_test <- read.csv("./UCI HAR Dataset/test/y_test.txt", header = FALSE, as.is=TRUE)
data_test <- read.table("./UCI HAR Dataset/test/x_test.txt", header = FALSE, as.is=TRUE)
data_test <- cbind(act_test[,1], data_test)
data_test <- cbind(sub_test[,1], data_test)
names(data_test)[1:2] <- c("subject", "activity")

## Combining 2 data sets
data_combined <- rbind(data_test, data_train)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

## adjusting feature names
secondElement <- function(x){x[2]}
features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE, as.is=TRUE, sep="\t")
feature_clean <- sapply(strsplit(features[,1], split=" "), secondElement)
feature_clean <- gsub("-", "\\.", feature_clean)
feature_clean <- gsub("\\(\\)", "FUN", feature_clean)

feature_meanstd <- sort(c(grep("meanFUN", feature_clean), grep("stdFUN", feature_clean)))
combined_meanstd <- data_combined[, c(1:2, feature_meanstd + 2)]

## 3. Uses descriptive activity names to name the activities in the data set
activities <- sapply(strsplit(activities[,1], split=" "), secondElement)
combined_meanstd$activity <- activities[combined_meanstd$activity]

## 4. Appropriately labels the data set with descriptive variable names. 
feature_right <- as.data.table(feature_clean)
feature_right <- feature_right[c(feature_meanstd), ]
feature_right$domain <- ifelse(substr(feature_right$feature_clean,1,1) == "t", "Time", "Frequency")
feature_right$signals <- ifelse(substr(feature_right$feature_clean,2,5) == "Body", "Body", "Gravity")
feature_right$sensor <- ifelse(grepl("Acc", feature_right$feature_clean), "Accelerometer", "Gyroscope")
feature_right$jerk <- ifelse(grepl("Jerk", feature_right$feature_clean), "Jerk", "")
feature_right$magnitude <- ifelse(grepl("Mag", feature_right$feature_clean), "Magnitude", "")
feature_right$stats <- ifelse(grepl("meanFUN", feature_right$feature_clean), "Mean", "Std")
feature_right$axis <- ifelse(grepl("\\.X", feature_right$feature_clean), "X", ifelse(grepl("\\.Y", feature_right$feature_clean), "Y", ifelse(grepl("\\.Z", feature_right$feature_clean), "Z", "")))
feature_right$variable <- paste0(feature_right$domain, feature_right$signals, feature_right$sensor, feature_right$jerk, feature_right$magnitude, feature_right$stats, feature_right$axis)

names(combined_meanstd) <- c("subject", "activity", as.character(feature_right$variable))
combined_melt <- melt(combined_meanstd, id=c("subject", "activity"))
clean_data <- join(feature_right, combined_melt, by = "variable")

## 5.Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
summarise_mean <- ddply(clean_data, .(domain, signals, sensor, jerk, magnitude, stats, axis, subject, activity), summarize, mean=mean(value))
write.csv(summarise_mean, "./summarise_mean.txt", row.names=FALSE)