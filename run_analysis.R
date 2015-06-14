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
# Zip file should be present in the current directory
zipfile<-"./getdata-projectfiles-UCI HAR Dataset.zip"
if (!file.exists(zipfile)){
    stop("Could not find zip file in current directory")
}


# Now read all the tables in from the ZIP file, for use in subsequent steps
message("Reading test data...")
test_data <- read.table(unz(zipfile, "UCI HAR Dataset/test/X_test.txt"))
test_activity_codes <- read.table(unz(zipfile, "UCI HAR Dataset/test/y_test.txt"))
test_subject_codes <- read.table(unz(zipfile, "UCI HAR Dataset/test/subject_test.txt"))

message("Reading training data...")
train_data <- read.table(unz(zipfile, "UCI HAR Dataset/train/X_train.txt"))
train_activity_codes <- read.table(unz(zipfile, "UCI HAR Dataset/train/y_train.txt"))
train_subject_codes <- read.table(unz(zipfile, "UCI HAR Dataset/train/subject_train.txt"))

message("Reading other data...")
# Features file contains column headings for the data, note these include
# characters that are not valid in R, so will require some cleanup
column_names_invalid<-read.table(unz(zipfile, "UCI HAR Dataset/features.txt"))

# Activity labels contain a cross-reference between the activity type number and
# the meaningful description, so read it into a table and give the table columns names 
# (activity_code will be used for a merge later, the column name in the
# other table must match)
activity_labels <- read.table(unz(zipfile, "UCI HAR Dataset/activity_labels.txt"))
names(activity_labels)<-c("activity_code","activity")

# To join up the 6 tables, column bind the train data, column bind the test
# data, then row bind the 2 sets together. It is important to remember where the
# activity code and subject codes end up (which for the way I have done it, is
# at the end, they will be moved to the front for the summary tidy dataset
# later)
message("Consolidating data...")

data<-rbind( cbind(train_data,train_activity_codes,train_subject_codes),
             cbind(test_data, test_activity_codes, test_subject_codes))


# Tidying up to release resources and avoid clutter
rm(train_data,train_activity_codes,train_subject_codes,test_data, test_activity_codes, test_subject_codes) 


# Now to extract mean and standard deviation columns
# Names are defined in the features.txt file, which was previously loaded into column_names_invalid table,
# the names are in the second column of that table.
message("Cleaning feature names ...")

# I have to acknowledge some good advice from our CTA David Hood. The following
# removes invalid characters (namely ""()-,"")from the feature descriptions and replaces them
# with something that will not be invalid in R as a column name (
# Note that if there is nothing between brackets, they are just suppressed
# otherwise they are replaced with _lb_ and _rb_ respectively

column_names <- column_names_invalid[,2]
column_names <- gsub("-", "_", column_names)
column_names <- gsub("\\(\\)", "", column_names)
column_names <- gsub("\\(", "_lb_", column_names)
column_names <- gsub("\\)", "_rb_", column_names)
column_names <- gsub(",", "_comma_", column_names)
# now adding the column names for the y and subject columns that were previously
# cbinded
column_names[562]<-"activity_code"
column_names[563]<-"subject"

#now update the names of the dataframe
message("Updating column names ...")
names(data)<-column_names

# 
# My interpretation of columns with mean and standard deviations for each 
# measurement is precisely those that include "-mean(" or ""-std(" in them (there 
# are other occurrences of mean in the features file, but this definition is as 
# good as any other for the purposes of learning, and could easily be redefined 
# in the real world if it turned out not to be exactly what is required)

# column_names_invalid[grep(".*-mean\\(|.*-std\\(",column_names_invalid$V2),] # Used for testing initially

# The regular expression for matching is therefore ".*-mean\\(|.*-std\\("

# So we need to keep in the df only the columns that match AND the last two we
# just added:
data<-data[,c(grep(".*-mean\\(|.*-std\\(",column_names_invalid$V2),562:563)]

# Now need to make the activity labels descriptive. To do this merge in the
# data from the supplied Activity labels file, previously loaded to activity_labels
data<-merge(data,activity_labels)
# There is now a column called activity_code (the merge key) that is no longer
# required, let us remove it

data$activity_code<-NULL
# Now that we have completed steps three and four (not quite in the same order that
# was specified, but that is allowable, the end result is the same), we need to:

# "Create a second, independent tidy data set with the average of each variable
# for each activity and each subject."
library(data.table)
dt<-data.table(data)
tidy_summary<-dt[order(activity,subject),lapply(.SD,mean),by=list(activity,subject)]
# While the spec does not specify any particular order, I like to sort by the
# grouped variables

# Let's write out the copy to upload to Coursera, or use for further analysis
message("Writing output to ./tidy_dataset.txt ...")
write.table(tidy_summary,"./tidy_dataset.txt",row.name=FALSE)
# Just in case someone wants to look at it, lets also return it
message("Analysis Complete")
tidy_summary
}