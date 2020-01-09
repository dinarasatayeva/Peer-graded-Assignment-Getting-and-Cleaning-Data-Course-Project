library(dplyr)

#Downloading dataset
if(!file.exists("Coursera_DS3_Final.zip")){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                "Coursera_DS3_Final.zip", method = "curl")
}

if (!file.exists("UCI HAR Dataset")){
  unzip("Coursera_DS3_Final.zip")
}

#Assingning data frames
features<-read.table("UCI HAR Dataset/features.txt", col.names = c("n", "functions"))
activities<-read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test<-read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test<-read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train<-read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train<-read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train<-read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

#Merging traning and testing sets
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
merged_data <- cbind(Subject, Y, X)

#Selecting mean and standard deviation for each measurement
tidy_data <- select(merged_data, subject, code, contains("mean"), contains("std"))

#Applying descriptive activity names
tidy_data$code <- activities[tidy_data$code, 2]

#Applying descriptive variables names
names(tidy_data)[2] = "activity"
names(tidy_data)<-gsub("Acc", "Accelerometer", names(tidy_data))
names(tidy_data)<-gsub("Gyro", "Gyroscope", names(tidy_data))
names(tidy_data)<-gsub("BodyBody", "Body", names(tidy_data))
names(tidy_data)<-gsub("Mag", "Magnitude", names(tidy_data))
names(tidy_data)<-gsub("^t", "Time", names(tidy_data))
names(tidy_data)<-gsub("^f", "Frequency", names(tidy_data))
names(tidy_data)<-gsub("tBody", "TimeBody", names(tidy_data))
names(tidy_data)<-gsub("-mean()", "Mean", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("-std()", "STD", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("-freq()", "Frequency", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("angle", "Angle", names(tidy_data))
names(tidy_data)<-gsub("gravity", "Gravity", names(tidy_data))

#Creating a tidy data set with average of each variable for each activity and subject
final_data <- tidy_data %>%
  group_by(subject, activity) %>%
  summarise_all(list(mean = mean))

write.table(final_data, "FinalData.txt", row.name=FALSE)
