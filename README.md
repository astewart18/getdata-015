# getdata-015
## Introduction
This repo contains my solution for the Coursera Data Science Getting and Cleaning Data course.

The objective was to produce a script that given a zip archive containing data from a study, would consolidate and then summarise the data, producing a tidy dataset  

Further information on the original can be found at:

    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The data for the project come from: 

    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
    
## Procedure

1. Start R and select an appropriate working directory.
2. Download the zip file and place in the working directory.There is no need to unzip it, the script will access the content directly.
3. Download the run_analysis.R from the same repository this file is in, and source it in R.
4. Run the function run_analysis(). It will return a tidy dataset, an explanation of the attributes can be found in CodeBook.md in this same repository. 

For example:
tidy<-run_analysis()

Note that the data.table package will need to have been installed for the script to run, if not, please run the command "install.packages("data.table")" 

The command View(tidy) in RStudio will show that indeed the dataset is tidy in wide form, having only one variable per column, and one row for each combination of subject and activity.

## What the script does

1. Reads in the training files (X_, y_ and subject_) and joins them columnwise, does the same with the test files, and combines the resulting two tables by rows.
2. Reads in the features.txt file to get the list of column names. These column names are not valid in R, so a copy is taken and 
        a. All instances of "()" are dropped
        b. Remaining "(" are replaced with _lb_
        c. Remaining ")" are replaced with _rb_
        d. "-" are replaced with _
        e. "," are replaced with _comma_
3. Columns not required are dropped. The brief states "Extract only the measurements on the mean and standard deviation for each measurement", this has been assumed to include all measures including -mean( or -std(, but not those measurements that simply include mean in the name. If this interpretation of the brief is not the one intended, it will be easy to modify the script, however based on looking at the forums this interpretation seems the most correct to me. To drop the columns, the original features list is searched and used to discard columns that do not meet the criteria.
4. Activity codes are replaced by merging the data from the activity label text file with the activity (numerical value) that was added from the y_ files, dropping the activity code itself.
5. The tidy dataset is produced by grouping by activity and subject, and calculating the mean of each of the other columns using a data.table approach, worth looking at closely because there is a lot going on in just one line of R:

tidy_summary<-dt[order(activity,subject),lapply(.SD,mean),by=list(activity,subject)]

It is worth doing a search on ".SD"" if it is new to you, it refers to each subtable (ie all the values for a particular combination of activity/subject)
