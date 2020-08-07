#############
# My take on Getting and Cleaning Data Course Project. 
# 'reshape2' library used for ease in generating summarized data (too many columns).
##############

###
# 1. Getting Dataset from the Web
###
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
tmpFileNm <- "tmp.zip"
tmpFileDir <- file.path("./temp")
tmpFilePath <- file.path(tmpFileDir, tmpFileNm)

dataFileDir <- "./dataset"

if (!file.exists(tmpFilePath)) {
        if (!dir.exists(tmpFileDir)) {
                dir.create(tmpFileDir)
        }
        
        download.file(url, tmpFilePath)
}

if (!dir.exists(dataFileDir)) {
        dir.create(dataFileDir)
        unzip(zipfile = tmpFilePath, exdir = dataFileDir)
}


###
# 2. Merges the training and the test sets to create one data set.
# refer: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
###

# root directory for uci har dataset
ucidir <- file.path(dataFileDir, "UCI HAR Dataset")

# train data
x_train <- read.table(file.path(ucidir, 'train/X_train.txt'))
y_train <- read.table(file.path(ucidir, 'train/y_train.txt'))
s_train <- read.table(file.path(ucidir, 'train/subject_train.txt'))

# test data
x_test <- read.table(file.path(ucidir, 'test/X_test.txt'))
y_test <- read.table(file.path(ucidir, 'test/y_test.txt'))
s_test <- read.table(file.path(ucidir, 'test/subject_test.txt'))

# merge train and test
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)

# load feature and activity labels
features <- read.table(file.path(ucidir, 'features.txt'))
activity <- read.table(file.path(ucidir, 'activity_labels.txt'))
activity[,2] <- as.character(activity[,2])

###
# 3. Extracts only the measurements on the mean and standard deviation for each measurement.
###
selectedCols = grep("mean|std", features[,2])
selectedColNames <- as.character(features[selectedCols, 2])

# data containing only the selected columns
ex_data <- x_data[,selectedCols]

###
# 4. Uses descriptive activity names to name the activities in the data set
###

# Set subject & activity data (y_data) using factor instead of foreign key integer
ys_data <- factor(as.vector(y_data[,1]), levels = activity[,1], labels = activity[,2])
sf_data <- as.factor(s_data[,1])

###
# 5. Appropriately labels the data set with descriptive variable names.
###

# rename some column names to removed/change to beautify
selectedColNamesf <- gsub("-std", "Std", selectedColNames)
selectedColNamesf <- gsub("-mean", "Mean", selectedColNamesf)
selectedColNamesf <- gsub("[-()]", "", selectedColNamesf)

# merge subject, activity, and variable data (selected column)
alldata <- cbind(sf_data, ys_data, ex_data)

colnames(alldata) <- c("Subject", "Activity", selectedColNamesf)

###
# 6. From the data set in step 5, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.
###

# install and load rehape2 package
install.packages("reshape2")
library(reshape2)

# melt the data to be tall and skinny
# note: i was planning to use sapply & tapply but then stopped because of the number of
# columns to individually process and merge
meltedData <- melt(alldata, id.vars = c("Subject", "Activity"))

# average of each variable for each activity and subject
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

# write to file
write.table(tidyData, file.path("./tidy_dataset.txt"), row.names = FALSE, quote = FALSE)

