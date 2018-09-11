# if (!require("shiny")) install.packages("shiny");
# if (!require("shinydashboard")) install.packages("shinydashboard");
# if (!require("XML")) install.packages("XML");
# if (!require("markdown")) install.packages("markdown");
# if (!require("mlxR")) install.packages("mlxR");
# if (!require("wordcloud")) install.packages("wordcloud");
# if (!require("RColorBrewer")) install.packages("RColorBrewer");
# if (!require("DT")) install.packages('DT'); 
# if (!require("RMySQL")) install.packages('RMySQL');

library(shiny)
library(shinydashboard)
library(XML)
library(markdown)
library(mlxR)
library(wordcloud)
library(RColorBrewer)
library(DT)
library(RMySQL)



load("shinydata.RData", envir=.GlobalEnv)
source("stupidbackoff.R")

nextw <- function(phrase){
  return(StupidBackoff(phrase))
}

shinyServer(function(input, output) {
  
  phraseGo <- eventReactive(input$goButton, {
    input$phrase
  })
  output$stats <- renderText({
    numword <- length(strsplit(input$phrase," ")[[1]])
    numchar <- nchar(input$phrase)
    paste("You've written ", numword, " words and ", numchar, "characters")
  })
  output$nextword <- renderText({
    result <- nextw(phraseGo())
    # result <- nextw(input$phrase, input$lang)
    paste0(result)
  })
  
})