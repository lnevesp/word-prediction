if (!require("tm")) install.packages("tm"); library(tm);
if (!require("SnowballC")) install.packages("SnowballC"); library (SnowballC);
if (!require("RWeka")) install.packages("RWeka"); library(RWeka);
if (!require("stringi")) install.packages("stringi"); library(stringi);

# Clean Text
Clean.Text <- function(phrase){
  # build corpus
  phrase <- Corpus(VectorSource(phrase))
  
  # convert strings to lower case
  phrase  <- tm_map(phrase, content_transformer(tolower))
  
  # strip whitespace
  phrase <- tm_map(phrase, stripWhitespace)
  
  # remove punctuation
  phrase <- tm_map(phrase, removePunctuation)
  
  # remove numbers
  phrase <- tm_map(phrase, removeNumbers)
  
  phrase <- (unlist(sapply(phrase, `[`, "content")))
  
  return (phrase)  
}

# Get words
GetWords <- function(phrase, n) {
  phrase <- Clean.Text(phrase)
  words <- unlist(strsplit(phrase, " "))
  len <- length(words)
  if (n < 1) {
    stop("No text to predict")
  }
  if (n > len) {
    n <- len
  }
  if (n==1) {
    return(words[len])
  } else {
    rv <- words[len]
    for (i in 1:(n-1)) {
      rv <- c(words[len-i], rv)
    }
    rv
  }
}

# Check 5-gram
Check5Gram <- function(phrase, Ngram.5, getNrows) {
  words <- GetWords(phrase, 4)
  match <- subset(Ngram.5, word.1 == words[1] & word.2 == words[2] & word.3 == words[3] & 
                    word.4 == words[4])
  match <- subset(match, select=c(word.5, frequency))
  match <- match[order(-match$frequency), ]
  sumfreq <- sum(match$frequency)
  match$frequency <- round(match$frequency / sumfreq * 100)
  colnames(match) <- c("nextword","n5.MLE")
  if (nrow(match) < getNrows) {
    getNrows <- nrow(match)
  }
  match[1:getNrows, ]
}

# Check 4-gram
Check4Gram <- function(phrase, Ngram.4, getNrows) {
  words <- GetWords(phrase, 3)
  match <- subset(Ngram.4, word.1 == words[1] & word.2 == words[2] & word.3 == words[3])
  match <- subset(match, select=c(word.4, frequency))
  match <- match[order(-match$frequency), ]
  sumfreq <- sum(match$frequency)
  match$frequency <- round(match$frequency / sumfreq * 100)
  colnames(match) <- c("nextword","n4.MLE")
  if (nrow(match) < getNrows) {
    getNrows <- nrow(match)
  }
  match[1:getNrows, ]
}

# Check 3-gram
Check3Gram <- function(phrase, Ngram.3, getNrows) {
  words <- GetWords(phrase, 2)
  match <- subset(Ngram.3, word.1 == words[1] & word.2 == words[2])
  match <- subset(match, select=c(word.3, frequency))
  match <- match[order(-match$frequency), ]
  sumfreq <- sum(match$frequency)
  match$frequency <- round(match$frequency / sumfreq * 100)
  colnames(match) <- c("nextword","n3.MLE")
  if (nrow(match) < getNrows) {
    getNrows <- nrow(match)
  }
  match[1:getNrows, ]
}

# Check 2-gram
Check2Gram <- function(phrase, Ngram.2, getNrows) {
  words <- GetWords(phrase, 1)
  match <- subset(Ngram.2, word.1 == words[1])
  match <- subset(match, select=c(word.2, frequency))
  match <- match[order(-match$frequency), ]
  sumfreq <- sum(match$frequency)
  match$frequency <- round(match$frequency / sumfreq * 100)
  colnames(match) <- c("nextword","n2.MLE")
  if (nrow(match) < getNrows) {
    getNrows <- nrow(match)
  }
  match[1:getNrows, ]
}

# Backoff Score
Backoff.Score <- function(alpha=0.4, x5, x4, x3, x2) {
  score <- 0
  if (x5 > 0) {
    score <- x5
  } else if (x4 >= 1) {
    score <- x4 * (alpha)
  } else if (x3 > 0) {
    score <- x3 * (alpha^2)
  } else if (x2 > 0) {
    score <- x2 * (alpha^3)
  } 
  return(round(score,2))
}

# Score N-grams
ScoreNgrams <- function(phrase, nrows=20) {
  
  # get dfs from parent env
  n5.match <- Check5Gram(phrase, Ngram.5, nrows)
  n4.match <- Check4Gram(phrase, Ngram.4, nrows)
  n3.match <- Check3Gram(phrase, Ngram.3, nrows)
  n2.match <- Check2Gram(phrase, Ngram.2, nrows)
  
  # merge dfs, by outer join (fills zeroes with NAs)
  df.merge <- merge(n5.match, n4.match, by="nextword", all = TRUE)
  df.merge <- merge(df.merge, n3.match, by="nextword", all = TRUE)
  df.merge <- merge(df.merge, n2.match, by="nextword", all = TRUE)
  df.merge <- subset(df.merge, !is.na(nextword))  # rm any zero-match results
  if (nrow(df.merge) > 0) {
    df.merge <- df.merge[order(-df.merge$n5.MLE, -df.merge$n4.MLE, 
                               -df.merge$n3.MLE, -df.merge$n2.MLE), ]
    df.merge[is.na(df.merge)] <- 0  # replace all NAs with 0
    # add in scores
    df.merge$score <- mapply(Backoff.Score, alpha=0.4, df.merge$n5.MLE, df.merge$n4.MLE,
                             df.merge$n3.MLE, df.merge$n2.MLE)
    df.merge <- df.merge[order(-df.merge$score), ]
  }
  return(df.merge)  # dataframe
}

## Implement stupid backoff algo
StupidBackoff <- function(x, alpha=0.4, getNrows=20, showNresults=1) {
  nextword <- ""
  if (x == "") {
    return("the")
  }
  df <- ScoreNgrams(x, getNrows)
  if (nrow(df) == 0) {
    return("and")
  }
  if (showNresults > nrow(df)) {
    showNresults <- nrow(df)
  }
  if (showNresults == 1) {
    # check if top overall score is shared by multiple candidates
    topwords <- df[df$score == max(df$score), ]$nextword
    # if multiple candidates, randomly select one
    nextword <- sample(topwords, 1)
  } else {
    nextword <- data.frame(df$nextword[1:showNresults])
  }
  return(nextword)
}