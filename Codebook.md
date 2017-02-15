---
title: "Codebook"
author: "Christopher Arnold"
date: "February 14, 2017"
output: html_document
---

###This code book describes the data created through the use of the following function from the file: run_analysis.R
```readdata()```

## Data Background information

The final data was transformed from the original data set found here <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>
This data was collected from the accelerometers from a Samsung Galaxy S smartphone. A full description of this data sampling and process can be found 
here: <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>. 

## Variables

The measurements were taken over 30 different subjects as listed by the column:

```subject``` 

These subjects were divided into two groups during initial testing. These are defined by the column:

```testid```

The testid can be ```test``` or ```train``` signifying which group they were in.

Each subject participated in 6 activities where the data was gathered. These are found in the column:

```activity```

The activity can be one of the following:

* STANDING

* SITTING

* LAYING

* WALKING

* WALKING_DOWNSTAIRS

* WALKING_UPSTAIRS

The remainder of the variables and columns in the data set represent the different data points that were taken. The first of the two tidy datasets ```AllMeansAndSTD.txt``` contains all the mean measurements of the samples taken
from the following. The labels are broken into three parts. The type of measurement (t/f), the signals, whether it is direction or magnitude, and the type of value (Mean/Standard deviation)

* tBodyAcc-XYZ

* tGravityAcc-XYZ

* tBodyAccJerk-XYZ

* tBodyGyro-XYZ

* tBodyGyroJerk-XYZ

* tBodyAccMag

* tGravityAccMag

* tBodyAccJerkMag

* tBodyGyroMag

* tBodyGyroJerkMag

* fBodyAcc-XYZ

* fBodyAccJerk-XYZ

* fBodyGyro-XYZ

* fBodyAccMag

* fBodyAccJerkMag

* fBodyGyroMag

* fBodyGyroJerkMag

2 examples of this breakdown are as follows

```tBodyAccMeanX```

This column signifies that it is the mean of a small set of time domain signals from the Body Accelerometer in the X direction

```fBodyAccMagSTD```

This column signifies that is the standard deviation of a small set of Fast Fourier Transform processed signals of the magnitude from the Body Accelerometer
More details of these breakdowns can be found in the original data set in file named ```features_info.txt```

## Transformations

The first data set ```AllMeansAndSTD.txt``` is a subset of the original data that contains all the rows of data gathered from the original data set found in <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>
but it is only the columns that return the Mean and Standard deviation of each set. 

This data set is also a merge of the train and test data sets.

The inclusion of the ```testid``` variable is used to denote the results of this merge

The second data set ```SubjectAndActivityMeans.txt``` is a further subset of ```AllMeansAndSTD.txt```

This data set finds reports the mean values for each activity on each subject.

For example in ```AllMeansAndSTD.txt``` the "Walking" activity for subject "1" contained over 100 samples. The ```SubjectAndActivityMeans.txt```
data set returns a single mean value for that situation for each type of measurement.

This transformation was done as follows

    
    meantable <- data.frame()
    subjects <- unique(sortedtable$subject)
    for(i in 1:length(subjects))
    {
      subject <- subjects[[i]]
      subjectspecific <- sortedtable[sortedtable$subject == subject,]
      activities <- unique(subjectspecific$activity)
      for(j in 1:length(activities))
      {
          currentactivity <- as.character(activities[[j]])
          temptable <- subjectspecific[subjectspecific$activity == currentactivity,]
          numerictemp <- temptable[, -c(1,2, length(colnames(subjectspecific)))]
          meanstemp <- as.data.frame.list(colMeans(numerictemp))
          meanrowtemp <- data.frame(currentactivity, subject, meanstemp,subjectspecific[[1,length(colnames(sortedtable))]])
          #return(meanrowtemp)
          
          colnames(meanrowtemp)<- colnames(sortedtable)
          meantable <- rbind(meantable,meanrowtemp)
          
      }
    }

  
  
The ```meantable``` represents this aggregation of just the calculated means for each data point. 
This will condense the final result to only 180 rows, and the same number of columns in the ```AllMeansAndSTD.txt```

##Cleanup

The raw data was supplied with the activities separate from the data points, those were merged and the id was replaced
with a descriptive title of the activity.

All the renaming can be seen in these lines

    
    occurances <- c(1,2,grep("mean", columns), grep("std", columns), length(columns))
    meanandstdonly <- finalframe[,occurances]
    sortedtable <- arrange(meanandstdonly, subject)
  
    sortedtable[,1] <- trimws(gsub("[*0-9]","",sortedtable[,1]))
    colnames(sortedtable) <- trimws(gsub("[0-9]","",colnames(sortedtable)))
    colnames(sortedtable) <- gsub("-mean()", "Mean", colnames(sortedtable))
    colnames(sortedtable) <- gsub("-std()", "STD", colnames(sortedtable))
    colnames(sortedtable) <- gsub("[[:punct:]]","",colnames(sortedtable))
    colnames(sortedtable) <- gsub("()", "",colnames(sortedtable))


The column titles indicating the type of measurement were cleaned of any strange punctuations and ambiguous labels

The data column was sorted in the end by the subject id. 



##Full code

For reference here is all the code contained in ```run_analysis.R```. 

The ```readdata()``` functions needs only that the zip file from <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip> 
is extracted into the working R directory.


    readdata <- function()
    {
      library(plyr)
      #read in features names
      features <- scan("~/UCI HAR Dataset/features.txt", what = "character", sep = NULL)
      featuresmat <- matrix(features, ncol = 2, byrow = TRUE)
      featureslist <- character()
      for (i in 1: length(featuresmat[,1]))
      {
        tempfil <- paste(featuresmat[i,1], " ",featuresmat[i,2])
        featureslist <- c(featureslist, tempfil)
      }  
      #return(featureslist)
      
      
      #read in labels list
      labels <- scan("~/UCI HAR Dataset/activity_labels.txt", what = "character", sep= NULL)
      labelsmat <- matrix(labels, ncol = 2, byrow = TRUE)
      labelslist <- character()
      for (i in 1: length(labelsmat[,1]))
      {
          templabel <- paste(labelsmat[i,1], " ", labelsmat[i,2])
          labelslist <- c(labelslist, templabel)
      }
      #return(labelslist)
      
      
      #read in the train data
      numfeatures <- 561
      XTrainna <- as.numeric(scan("~/UCI HAR Dataset/train/X_train.txt", sep = " "))
      XTrain <- XTrainna[!is.na(XTrainna)]
      Xtrainmat <- matrix(XTrain, ncol = numfeatures, byrow = TRUE)
      
      ytrain <- scan("~/UCI HAR Dataset/train/y_train.txt")
      
      subjecttrain <- scan("~/UCI HAR Dataset/train/subject_train.txt")
      ytrainnew <- ytrain
      for(i in 1:length(ytrain))
      {
          search <- ytrain[[i]]
          ytrainnew[[i]] <- labelslist[[grep(search,labelslist)]]
      }
      #return(ytrain)
      trainframe <- data.frame(ytrainnew,  subjecttrain, Xtrainmat)
      trainframe$testid <- rep("train", nrow(trainframe))
      colnames(trainframe) <- c("activity",  "subject", featureslist, "testid")
      #return(trainframe)
      
      
      
      #read in the test data
      XTestna <- as.numeric(scan("~/UCI HAR Dataset/test/X_test.txt", sep = " "))
      XTest <- XTestna[!is.na(XTestna)]
      Xtestmat <- matrix(XTest, ncol = numfeatures, byrow = TRUE)
      
      ytest <- scan("~/UCI HAR Dataset/test/y_test.txt")
      
      subjecttest <- scan("~/UCI HAR Dataset/test/subject_test.txt")
      ytestnew <- ytest
      for(i in 1:length(ytest))
      {
          search <- ytest[[i]]
          ytestnew[[i]] <- labelslist[[grep(search,labelslist)]]
      }
      
      testframe <- data.frame(ytestnew,  subjecttest, Xtestmat)
      testframe$testid <- rep("test", nrow(testframe))
      colnames(testframe) <- c("activity", "subject", featureslist, "testid")
      #return(testframe)
      
      
      #merge test and train data and remove everything except mean and std
      finalframe <- rbind(trainframe, testframe)
      columns <- colnames(finalframe)
      occurances <- c(1,2,grep("mean", columns), grep("std", columns), length(columns))
      meanandstdonly <- finalframe[,occurances]
      sortedtable <- arrange(meanandstdonly, subject)
      
      sortedtable[,1] <- trimws(gsub("[*0-9]","",sortedtable[,1]))
      colnames(sortedtable) <- trimws(gsub("[0-9]","",colnames(sortedtable)))
      colnames(sortedtable) <- gsub("-mean()", "Mean", colnames(sortedtable))
      colnames(sortedtable) <- gsub("-std()", "STD", colnames(sortedtable))
      colnames(sortedtable) <- gsub("[[:punct:]]","",colnames(sortedtable))
      colnames(sortedtable) <- gsub("()", "",colnames(sortedtable))
      
      
      write.table(sortedtable, "~/AllMeansAndSTD.txt",row.name = FALSE)
      
      #return(finalframe)
      
      #trim data down to means of specific activity and specific subject
      meantable <- data.frame()
      subjects <- unique(sortedtable$subject)
      for(i in 1:length(subjects))
      {
          subject <- subjects[[i]]
          subjectspecific <- sortedtable[sortedtable$subject == subject,]
          activities <- unique(subjectspecific$activity)
          for(j in 1:length(activities))
          {
              currentactivity <- as.character(activities[[j]])
              temptable <- subjectspecific[subjectspecific$activity == currentactivity,]
              numerictemp <- temptable[, -c(1,2, length(colnames(subjectspecific)))]
              meanstemp <- as.data.frame.list(colMeans(numerictemp))
              meanrowtemp <- data.frame(currentactivity, subject, meanstemp,subjectspecific[[1,length(colnames(sortedtable))]])
              #return(meanrowtemp)
              
              colnames(meanrowtemp)<- colnames(sortedtable)
              meantable <- rbind(meantable,meanrowtemp)
              
          }
      }
      colnames(meantable)<- colnames(sortedtable)
      #remove some unwanted characters from the table
     
      
      
      write.table(meantable, file = "~/SubjectAndActivityMeans.txt", row.name = FALSE)
      
      return(meantable)
      
      
    }
