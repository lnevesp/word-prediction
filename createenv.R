# load library
if (!require("tm")) install.packages("tm"); library(tm);
if (!require("RWeka")) install.packages("RWeka"); library(RWeka);
if (!require("stringi")) install.packages("stringi"); library(stringi);
if (!require("stringr")) install.packages("stringr"); library(stringr);
if (!require("Rmisc")) install.packages("Rmisc"); library(Rmisc);
if (!require("rJava")) install.packages("rJava");

# load data
load("../data/ngram_data/2gram.rda")
load("../data/ngram_data/3gram.rda")
load("../data/ngram_data/4gram.rda")
load("../data/ngram_data/5gram.rda")
load("../data/ngram_data/6gram.rda")

setwd()

# Save image
save.image(file = "../data/appdata/shinydata.RData")