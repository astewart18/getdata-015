# run_analysis.R 
# Author: astewart18 
#
# Script written as part of the Data Collection and Cleaning project
# 
# Overall brief:
# 1. Merges the training and the test sets to create one data set.
# 
# 2. Extracts only the measurements on the mean and standard deviation for each
# measurement.
# 
# 3. Uses descriptive activity names to name the activities in the data set
# 
# 4. Appropriately labels the data set with descriptive variable names.
# 
# 5. From the data set in step 4, creates a second, independent tidy data set
# with the average of each variable for each activity and each subject.
run_analysis<-function(){
# Zip file should be downloaded to current directory
# The following variables identify specific files withing th eZIP
zipfile<-"./getdata-projectfiles-UCI HAR Dataset.zip"
X_test.txt<-"UCI HAR Dataset/test/X_test.txt"
Y_test.txt<-"UCI HAR Dataset/test/Y_test.txt"
subject_test.txt<-"UCI HAR Dataset/test/subject_test.txt"
X_train.txt<-"UCI HAR Dataset/train/X_train.txt"
Y_train.txt<-"UCI HAR Dataset/train/Y_train.txt"
subject_train.txt<-"UCI HAR Dataset/train/subject_train.txt"
features.txt<-"UCI HAR Dataset/features.txt"

X_test <- read.table(unz(zipfile, X_test.txt))
Y_test <- read.table(unz(zipfile, Y_test.txt))
subject_test.txt <- read.table(unz(zipfile, subject_test.txt))


X_train <- read.table(unz(zipfile, X_train.txt))
Y_train <- read.table(unz(zipfile, Y_train.txt))
subject_train <- read.table(unz(zipfile, subject_train.txt))

X_test<-cbind(X_test,Y_test,subject_test)
X_train<-cbind(X_train,Y_train,subject_train)
merge<-rbind(X_test,X_train)

rm(X_train,X_test) # Tidying up to release resources and avoid clutter

# Now to extract mean and standard deviation columns
# Names are defined in the features.txt file
features<-read.table(unz(zipfile, features.txt))
# My interpretation of columns with mean and standard deviations for each 
# measurement is precisely those that include -mean() and -std() in them (there 
# are other occurrences of mean, but this definition is as good as any other for
# the purposes of learning, and could easily be redefined in the real world if
# it turned out not to be exactly what is required)
# features[grep(".*-mean\\(|.*-std\\(",features$V2),]

# The regular expression for matching is therefore ".*-mean\\(|.*-std\\("
}