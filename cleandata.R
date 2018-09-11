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
if (!require("rJava")) install.packages("rJava"); library(rJava);
if (!require("parallel")) install.packages("parallel"); library(parallel);

# Set Work Directory
dir <- "../data"
setwd(dir)

# Set Seed
set.seed(171516)

# Load Corpus
load("./data/corpus_data/TrainData.rda")

# Remove URL
RemoveURL <- function(x) {
  gsub("http.*?( |$)", "", x)
}

# Convert Special Characters 
ConvertSpecial <- function(x) {
  x <- gsub("<U.0092>","'",x)
  x <- gsub("’","'",x)
  gsub("<.+?>"," ",x)
}

# Remove Numbers
RemoveNumbers <- function(x) {
  gsub("\\S*[0-9]+\\S*", " ", x)
}

# Remove Punctuation 
RemovePunct <- function(x) {
  gsub("[^[:alnum:][:space:]'*-]", " ", x)
}

# Handle Dashes and apostrophes
RemoveDash <- function(x) {
  x <- gsub("--+", " ", x)
  x <- gsub("(\\w['-]\\w)|[[:punct:]]", "\\1", x)
  gsub("-", " ", x)
}

# Trim whitspaces  
Trim <- function(x) {
  # trim leading and trailing whitespace
  gsub("^\\s+|\\s+$", "", x)
}

# Create Function to get Corpus
getCorpus <- function (data)
{
  # build corpus
  corpus <- Corpus(VectorSource(data))
  
  # convert strings to lower case
  corpus  <- tm_map(corpus, content_transformer(tolower))
  
  # Remove URL
  corpus  <- tm_map(corpus, content_transformer(RemoveURL))
  
  # Convert Special Characters
  corpus  <- tm_map(corpus, content_transformer(ConvertSpecial))
  
  # Handle Dashes and apostrophes
  corpus  <- tm_map(corpus, content_transformer(RemoveDash))
  
  # Strip Whitespaces
  corpus  <- tm_map(corpus, content_transformer(Trim))
  corpus <- tm_map(corpus, stripWhitespace)
  
  # Remove Punctuation
  corpus <- tm_map(corpus, content_transformer(RemovePunct))
  corpus <- tm_map(corpus, removePunctuation)
  
  # Remove Numbers
  corpus <- tm_map(corpus, content_transformer(RemoveNumbers))
  
  return (corpus)  
}

# Create clean corpus for train data
Train.Corpus <- getCorpus(Train.Data)

# Remove objects to save memory
rm(list=c("Train.Data", "getCorpus", "RemoveURL", "ConvertSpecial", "RemoveNumbers", "RemovePunct", "RemoveDash", "Trim"))


# Create function to get n-grams
getNGrams <-function(corpus, size)
{
  options(mc.cores=4)
  tokenizer <- function(x) NGramTokenizer(x, Weka_control(min = size, max = size))
  
  tdm <- TermDocumentMatrix(corpus, control = list(tokenize = tokenizer))
  
  # aggregate term frequencies
  tf <- sort(rowSums(as.matrix(tdm)), decreasing=TRUE)
  
  return(data.frame(term=names(tf), frequency=tf))
}

## 1-gram
if (!file.exists("~/SwiftKeyCapstone/data/ngram_data/2gram.rda")) {
  start.time <- Sys.time()
  print(paste("Creating 1-gram - Start Time: ", start.time))
  Ngram.1 <- getNGrams(Train.Corpus, 1)
  words <- str_split_fixed(Ngram.1$term, " ", 1)
  Ngram.1 <- data.frame(cbind(Ngram.1$frequency,
                              words))
  colnames(Ngram.1) <- c("frequency", "word.1") 
  Ngram.1$frequency <- as.numeric(as.character(Ngram.1$frequency))
  
  # Drop n-gram with frequency less or equal 1
  LowFreqWord <- Ngram.1[Ngram.1$frequency < 1,]
  LowFreqWord <- as.character(LowFreqWord$word.1)
  
  save(Ngram.1, file = "~/SwiftKeyCapstone/data/ngram_data/1gram.rda")
  Ngram.Time <- round(difftime( Sys.time(), start.time, units = 'min'),0)
  print(paste("1-gram created in: ", Ngram.Time))
  rm(list=c("words", "Ngram.1", "Ngram.Time"))
} else {
  print("1-gram already created")
}

# Remove objects to save memory
rm(list=c("getNGrams"))

# Convert corpus to text
Train.text <- data.frame(text=unlist(sapply(Train.Corpus,
                                            `[`, "content")), stringsAsFactors=F)
Train.text <- Train.text$text

# Change Low frequency words by unk
ReplaceLowFreq <- function(x, LowFreqWord) {
  words <- unlist(strsplit(x, " "))
  funk <- function(x, matches) {
    if (x %in% matches) {
      x <- "unk"
    } else {
      x
    }
  }
  rv <- lapply(words, funk, matches=LowFreqWord)
  paste(unlist(rv), collapse=" ")
}

# Runs it in parallel
cl <- makeCluster(detectCores())
df.clean = parLapply(cl, Train.text, ReplaceLowFreq, LowFreqWord)
stopCluster(cl)

df.clean <- unlist(df.clean)

# Convert to Corpus and Delete unk
RemoveLowFreq <- function (data)
{
  # build corpus
  corpus <- Corpus(VectorSource(data))
  
  # Remove Low Frequency Words
  corpus <- tm_map(corpus, removeWords, "unk")
  
  return (corpus)  
}

Train.Corpus <- RemoveLowFreq(df.clean)
save(Train.Corpus, file = "../data/corpus_data/DataCorpus.rda")

# Print Time eplase
Final.Time <- round(difftime( Sys.time(), start_time.global, units = 'min'),0)
print(paste("Time(minutes) to Preprocess the data: ", Final.Time))

# Remove objects to save memory
rm(list=ls(all=TRUE))
