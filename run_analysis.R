#Download the file and put the file in the data folder

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

#Unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#unzipped files are in the folder UCI HAR Dataset. Get the list of the files
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

#See the README.txt file for the detailed information on the dataset. For the purposes of this project, the files in the Inertial Signals folders are not used. The files that will be used to load data are listed as follows:

#test/subject_test.txt
#test/X_test.txt
#test/y_test.txt
#train/subject_train.txt
#train/X_train.txt
#train/y_train.txt

#Read data from the files into the variables
#Read the Activity files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

#Read the Subject files
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#Read Features files
dataFeaturesTest  <- read.table(file.path(path_rf,"X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf,"X_train.txt"),header = FALSE)

#Look at the properties of the above variables
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

#Merges the training and the test sets to create one data set
#Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#Merge columns to get the data frame Data for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#Extracts only the measurements on the mean and standard deviation for each measurement
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]


#Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#Check the structures of the data frame Data
str(Data)

#Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

#factorize Variale activity in the data frame Data using descriptive activity names
#check
head(Data$activity,30)

#Appropriately labels the data set with descriptive variable names
#prefix t is replaced by time
#Acc is replaced by Accelerometer
#Gyro is replaced by Gyroscope
#prefix f is replaced by frequency
#Mag is replaced by Magnitude
#BodyBody is replaced by Body

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

#check Structure
names(Data)

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "Tidydata.txt",row.name=FALSE)

#Producing CodeBook
library(knitr)
knit2html("codebook.Rmd")


