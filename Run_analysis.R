## This script runs the following functions:
    
    ## Merges the training and the test sets to create one data set.

    ## Extracts only the measurements on the mean and standard deviation for 
    ## each measurement.

    ## Uses descriptive activity names to name the activities in the data set.

    ## Appropriately labels the data set with descriptive variable names.

    ## From the data set in step 4, creates a second, independent tidy data set 
    ## with the average of each variable for each activity and each subject.

## Include the "dplyr" package for further use
    library(dplyr)
    
## Download the ZIP file and then unzip it. Check if the files exist before processing.
    filename <- "ActivityData.zip"
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    if (!file.exists(filename)){
      download.file(fileURL, filename, method = "curl")
    }
    foldername <- "UCI HAR Dataset"
    if (!file.exists(foldername)){
      unzip(filename)
    }
    
## Read the files into R as data.frames, assigning column names.
    features <- read.table("./UCI HAR Dataset/features.txt", col.names = c("No.","Functions"))
    activities <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("Code", "Activity"))
    
    subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
    x_test <- read.table("./UCI HAR Dataset/test/X_test.txt", col.names = features$Functions)
    y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", col.names = "Code")
    
    subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
    x_train <- read.table("./UCI HAR Dataset/train/X_train.txt", col.names = features$Functions)
    y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", col.names = "Code")
    
## Step 1: Merges the training and the test sets to create one data set.
    ## To accomplish this, we need first merge the "test" and "training" data for "X",
    ## "Y" and "subject" and then, combine these three together.
    x_merged <- rbind(x_test, x_train) ## Test results
    y_merged <- rbind(y_test, y_train) ## Activity code
    subject_merged <- rbind(subject_test, subject_train) ## Tested subjects
    data_merged <- cbind(subject_merged, y_merged, x_merged)
    
## Step 2: Extracts only the measurements on the mean and standard deviation for 
## each measurement.
    ## The keywords are "mean" and "std", lying in the colnames of X data.
    SelectedData <- data_merged %>% select(Subject, Code, contains("mean"), contains("std"))
    
## Step 3: Uses descriptive activity names to name the activities in the data set.
    SelectedData$Code <- activities[SelectedData$Code,2] ## Second col of activity labels.
    names(SelectedData)[2] <- "Activity"
## Step 4: Appropriately labels the data set with descriptive variable names.
    names(SelectedData)<-gsub("Mag", "Magnitude", names(SelectedData))
    names(SelectedData)<-gsub("^t", "Time", names(SelectedData))
    names(SelectedData)<-gsub("^f", "Frequency", names(SelectedData))
    names(SelectedData)<-gsub("()", "", names(SelectedData))
    
## Step 5: From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.
    TidyData <- SelectedData %>%
                group_by(Subject, Activity) %>%
                summarise_all(mean)
    ## TidyData
    write.table(TidyData, "./TidyData.txt", row.name = FALSE, quote = FALSE)