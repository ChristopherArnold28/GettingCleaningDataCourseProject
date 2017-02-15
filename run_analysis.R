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