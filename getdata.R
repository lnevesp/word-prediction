# Clean Environment
rm(list=ls(all=TRUE))

start_time.global <- Sys.time()
print(paste("Process Started at: ", start_time.global))

# By default java uses 512 Mb of memory on its virtual machines, here we change its value to 16Gb
options( java.parameters = "-Xmx16g" )

# Libraries
if (!require("tm")) install.packages("tm"); library(tm);
if (!require("SnowballC")) install.packages("SnowballC"); library (SnowballC);
if (!require("RWeka")) install.packages("RWeka"); library(RWeka);
if (!require("stringi")) install.packages("stringi"); library(stringi);
if (!require("stringr")) install.packages("stringr"); library(stringr);
if (!require("Rmisc")) install.packages("Rmisc"); library(Rmisc);
if (!require("rJava")) install.packages("rJava");
if (!require("parallel")) install.packages("parallel");

# Set Work Directory
dir <- "../data"
if (!dir.exists(dir)) {
  dir.create(dir)  
}
setwd(dir)

# Set Seed
set.seed(171516)

# Download and unzip the data
CapstoneData <- "Coursera-SwiftKey.zip"
if (!file.exists(CapstoneData)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
  download.file(fileURL, CapstoneData, method="auto")
}  

#Unzip the file
if (!dir.exists("../data/final")) {
  unzip(CapstoneData)  
}

# Read Blogs Data
blogs <- readLines("../data/final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul=TRUE)
blogs <- iconv(blogs, from = "latin1", to = "UTF-8", sub="")
blogs <- stri_replace_all_regex(blogs, "\u2019|`","")
blogs <- stri_replace_all_regex(blogs, "\u201c|\u201d|u201f|``",'')
blogs <- stri_replace_all_regex(blogs, "ð\u009f\u0098±ð\u009f\u0098±ð\u009f\u0098¨",'')

# Import the news dataset in binary mode
con <- file("../data/final/en_US/en_US.news.txt", open="rb")
news <- readLines(con, encoding="UTF-8", skipNul=TRUE)
news <- iconv(news, from = "latin1", to = "UTF-8", sub="")
news <- stri_replace_all_regex(news, "\u2019|`","")
news <- stri_replace_all_regex(news, "\u201c|\u201d|u201f|``",'')
news <- stri_replace_all_regex(news, "ð\u009f\u0098±ð\u009f\u0098±ð\u009f\u0098¨",'')
close(con)

# Import twitter dataset
twitter <- readLines("../data/final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul=TRUE)

# Drop non UTF-8 characters from twitter dataset
twitter <- iconv(twitter, from = "latin1", to = "UTF-8", sub="")
twitter <- stri_replace_all_regex(twitter, "\u2019|`","")
twitter <- stri_replace_all_regex(twitter, "\u201c|\u201d|u201f|``",'')
twitter <- stri_replace_all_regex(twitter, "ð\u009f\u0098±ð\u009f\u0098±ð\u009f\u0098¨",'')

# Remove objects to save memory
rm(list=c("CapstoneData", "CapstoneDir", "con"))

# Full data
full.data <- data.frame(c(blogs, news, twitter))

# Sample Size
size.sample <- floor(0.60 * nrow(full.data))

# Select Sample
set.seed(171516)
sample.id <- sample(seq_len(nrow(full.data)), size = size.sample)
Train.Data <- data.frame(full.data[sample.id,])
colnames(Train.Data) <- "Text"

# Check Data
head(Train.Data, 5)

# Save Data
save(Train.Data, file = "../data/corpus_data/TrainData.rda")

# Remove objects to save memory
rm(list=c("blogs", "news", "twitter", "full.data", "size.sample", "sample.id"))