# Getting and Cleaning Data Project John Hopkins Coursera


library(data.table)
library(reshape2)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "datos.zip"))
unzip(zipfile = "datos.zip")

# Load activity labels + features
actLab <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featN"))
featW <- grep("(mean|std)\\(\\)", features[, featN])
measurements <- features[featW, featN]
measurements <- gsub('[()]', '', measurements)

#train 
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featW, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainAct <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSub <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSub, trainAct, train)

#test 
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featW, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testAct <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSub <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSub, testAct, test)

# merge
merged <- rbind(train, test)

merged[["Activity"]] <- factor(merged[, Activity]
                                 , levels = actLab[["classLabels"]]
                                 , labels = actLab[["activityName"]])

merged[["SubjectNum"]] <- as.factor(merged[, SubjectNum])
merged <- reshape2::melt(data = merged, id = c("SubjectNum", "Activity"))
merged <- reshape2::dcast(data = merged, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = merged, file = "tidyData.txt", quote = FALSE)
