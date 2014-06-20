The analysis have been carried out as part of the project work of Getting and Cleaning Data Coursera course. 

This file is to explain the process of the analysis carried out and how the run_analysis.R scripts work.

## Underlying data
The underlying data for the analysis is obtained from:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

And a full description of the data is here:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

## The goal
The goal of the analysis is to combine the raw test and training data in a meaningful format and to create a clean data set which contains:
1. descriptive and appropriately labled activity names and variable names
2. mean of each variable for each activity and each subject

And the process is broken down into the following 5 steps:

## 1. Merges the training and the test sets to create one data set.
Using read.table function, the script reads the training dataset (/train/X_train.txt) and the test dataset (/test/X_test.txt) into 2 seperate data frames: data_train and data_test. Then the related subject and activity labels are added to the data frames also individually using the cbind function.

Finally, the rbind function was used to combine the 2 data frames into a single dataset: data_combined.

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
Firstly, the feature names are read into a data frame and then cleaned up by substituting "_" to "." and "()" to "FUN" using gsub function and saved into data frame: feature_clean. 

Then an index of all the feature names that contains mean and standard deviation functions is created using the grep function.

Finally, the data_combined data frame is subset by the index into combined_meanstd.

## 4. Appropriately labels the data set with descriptive variable names. 
A feature_right data frame is created by adding in new columns that provides descriptive information to each of the variable names. The newly added columns are:
* domain: "Time" or "Frequency"
* signals: "Body" or "Gravity"
* sensor: "Accelerometer" or "Gyroscope"
* jerk: either "Jerk" or empty
* magnitude: either "Magnitude" or empty
* stats: "Mean" or "Std"
* axis: "X", "Y" or "z"
* variable: A more readable name by combining all the information above.

Then the combined_meanstd data frame was given column names using the variable field of the feature_right data frame.

Finally, the newly names combined_meanstd data frame was reconstructed into a long format using the melt function and joined with the feature_right data frame by the variable field into a new data frame called clean_data.


## 5.Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
Using the ddply function, the clean_data data frame is then summarised into summarise_mean which contains the average of each variable for each activity and each subject.

The summarise_mean data frame is then output to file: summarise_mean.txt. The output file is comma deliminated. 

