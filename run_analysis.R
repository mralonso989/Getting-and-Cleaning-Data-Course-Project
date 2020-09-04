# ALONSO ANTÓN
# I've already had the unzip files in my directory
path <- "C:/Users/Julia/Desktop/2020-2/Coursera/DATA SCIENCE/Curso 3"
library(data.table)
library(reshape2)

# labels and features

Labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))

        # Extracts only the measurements on the mean and standard deviation for each measurement.

features_index <- grep("(mean|std)\\(\\)", features[, featureNames])
measu <- features[features_index, featureNames]
measu <- gsub('[()]', '', measu)

# test data

test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, features_index, with = FALSE] ; data.table::setnames(test, colnames(test), measu)
train_y <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
test_sub <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test_data <- cbind(test_sub, train_y, test)

# train data

train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, features_index, with = FALSE] ; data.table::setnames(train, colnames(train), measu)
train_y <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                 , col.names = c("Activity"))
train_sub <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                   , col.names = c("SubjectNum"))
train_data <- cbind(train_sub, train_y, train)

# Merges the training and the test sets to create one data set.
merge_data <- rbind(train_data, test_data)

# Appropriately labels the data set with descriptive variable names.
merge_data[["Activity"]] <- factor(merge_data[, Activity]
                                 , levels = Labels[["classLabels"]]
                                 , labels = Labels[["activityName"]])

merge_data[["SubjectNum"]] <- as.factor(merge_data[, SubjectNum])
merge_data <- reshape2::melt(data = merge_data, id = c("SubjectNum", "Activity"))
merge_data <- reshape2::dcast(data = merge_data, SubjectNum + Activity ~ variable, fun.aggregate = mean)

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
data.table::fwrite(x = merge_data, file = "tidyDataFinal.txt", quote = FALSE)
