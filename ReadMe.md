---
title: "ReadMe"
author: "Christopher Arnold"
date: "February 14, 2017"
output: html_document
---
This repo contains all the necessary files associated with the final project for 
the **Getting and Cleaning Data** course on Coursera

## Files in Repo

* Codebook.md
* ```run_analysis.R```
* ```SubjectAndActivityMeans.txt```
* ```AllMeansAndSTD.txt```

### Codebook.md

This codebook contains a detailed breakdown of all the variables, data, code, and transformations
used to get the data found in the two attached data text files. Please refer to the codebook 
if there are any questions.

### run_analysis.R

This is the code to go from the original dataset contained here 
<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>
to the two text files in this repo. The single function in this code only requires
that all the files from the above location be unzipped into your working directory


### SubjectAndActivityMeans.txt

This table contains the means of the requested data points for each activity for each subject. 

### AllMeansAndSTD.txt

This table contains all the records for each subject and each activity for the requested data points.

