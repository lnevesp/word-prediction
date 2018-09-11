# Clean Environment
rm(list=ls(all=TRUE))

start_time.global <- Sys.time()
print(paste("Process Started at: ", start_time.global))

# By default java uses 512 Mb of memory on its virtual machines, here we change its value to 16Gb
options( java.parameters = "-Xmx16g" )

# Libraries
if (!require("tm")) install.packages("tm"); library(tm);
if (!require("RWeka")) install.packages("RWeka"); library(RWeka);
if (!require("stringi")) install.packages("stringi"); library(stringi);
if (!require("stringr")) install.packages("stringr"); library(stringr);
if (!require("Rmisc")) install.packages("Rmisc"); library(Rmisc);
if (!require("rJava")) install.packages("rJava");

# Set Work Directory
dir <- "../data"
setwd(dir)

# Set Seed
set.seed(171516)

# Load Corpus
load(file = "../data/corpus_data/DataCorpus.rda")

# Create function to get n-grams
getNGrams <-function(corpus, size, pct)
{
  tokenizer <- function(x) NGramTokenizer(x, Weka_control(min = size, max = size))
  
  tdm <- TermDocumentMatrix(corpus, control = list(tokenize = tokenizer))
  
  # remove sparse terms
  # tdm <- removeSparseTerms(tdm, pct)
  
  # aggregate term frequencies
  tf <- sort(rowSums(as.matrix(tdm)), decreasing=TRUE)
  
  return(data.frame(term=names(tf), frequency=tf))
}

## 2-Gram
Ngram.2 <- getNGrams(Train.Corpus, 2, 0.99)
words <- str_split_fixed(Ngram.2$term, " ", 2)
Ngram.2 <- data.frame(cbind(Ngram.2$frequency,
                            words))
colnames(Ngram.2) <- c("frequency", "word.1", "word.2") 
Ngram.2$frequency <- as.numeric(as.character(Ngram.2$frequency))
# Drop n-gram with frequency less or equal 1
Ngram.2 <- Ngram.2[Ngram.2$frequency > 1,]
save(Ngram.2, file = "../data/ngram_data/2gram.rda")
rm(list=c("words", "Ngram.2"))

## 3-Gram
Ngram.3 <- getNGrams(Train.Corpus, 3, 0.99)
words <- str_split_fixed(Ngram.3$term, " ", 3)
Ngram.3 <- data.frame(cbind(Ngram.3$frequency,
                            words))
colnames(Ngram.3) <- c("frequency", "word.1", "word.2", "word.3") 
Ngram.3$frequency <- as.numeric(as.character(Ngram.3$frequency))
# Drop n-gram with frequency less or equal 1
Ngram.3 <- Ngram.3[Ngram.3$frequency > 1,]
save(Ngram.3, file = "../data/ngram_data/3gram.rda")
rm(list=c("words", "Ngram.3"))

## 4-Gram
Ngram.4 <- getNGrams(Train.Corpus, 4, 0.99)
words <- str_split_fixed(Ngram.4$term, " ", 4)
Ngram.4 <- data.frame(cbind(Ngram.4$frequency,
                            words))
colnames(Ngram.4) <- c("frequency", "word.1", "word.2", "word.3", "word.4") 
Ngram.4$frequency <- as.numeric(as.character(Ngram.4$frequency))
# Drop n-gram with frequency less or equal 1
Ngram.4 <- Ngram.4[Ngram.4$frequency > 1,]
save(Ngram.4, file = "../data/ngram_data/4gram.rda")
rm(list=c("words", "Ngram.4"))

## 5-Gram
Ngram.5 <- getNGrams(Train.Corpus, 5, 0.99)
words <- str_split_fixed(Ngram.5$term, " ", 5)
Ngram.5 <- data.frame(cbind(Ngram.5$frequency,
                            words))
colnames(Ngram.5) <- c("frequency", "word.1", "word.2", "word.3", "word.4", "word.5") 
Ngram.5$frequency <- as.numeric(as.character(Ngram.5$frequency))
# Drop n-gram with frequency less or equal 1
Ngram.5 <- Ngram.5[Ngram.5$frequency > 1,]
save(Ngram.5, file = "../data/ngram_data/5gram.rda")
rm(list=c("words", "Ngram.5"))

## 6-Gram
Ngram.6 <- getNGrams(Train.Corpus, 6, 0.99)
words <- str_split_fixed(Ngram.6$term, " ", 6)
Ngram.6 <- data.frame(cbind(Ngram.6$frequency,
                            words))
colnames(Ngram.6) <- c("frequency", "word.1", "word.2", "word.3", "word.4", "word.5", "word.6") 
Ngram.6$frequency <- as.numeric(as.character(Ngram.6$frequency))
# Drop n-gram with frequency less or equal 1
Ngram.6 <- Ngram.6[Ngram.6$frequency > 1,]
save(Ngram.6, file = "../data/ngram_data/6gram.rda")
rm(list=c("words", "Ngram.6"))

# Print Time eplase
Final.Time <- round(difftime( Sys.time(), start_time.global, units = 'min'),0)
print(paste("Time(minutes) Create N-Grams: ", Final.Time))

# Remove objects to save memory
rm(list=ls(all=TRUE))