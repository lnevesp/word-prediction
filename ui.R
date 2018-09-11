library(shinydashboard)

## Configure Sidebar
sidebar <- dashboardSidebar(
  hr(),
  sidebarMenu(id="tabs",
              menuItem("Word App", tabName="WordApp", icon=icon("commenting-o"), selected=TRUE),
              menuItem("Description", tabName="description", icon=icon("line-chart")),
              menuItem("Codes", icon = icon("file-text-o"),
                       menuSubItem("Codebook", tabName = "CodeBook", icon = icon("file-text-o")),
                       menuSubItem("getdata.R", tabName = "getdata", icon = icon("code")),
                       menuSubItem("cleandata.R", tabName = "cleandata", icon = icon("code")),
                       menuSubItem("getngram.R", tabName = "getngram", icon = icon("code")),
                       menuSubItem("stupidbackoff.R", tabName = "stupidbf", icon = icon("code")),
                       menuSubItem("ui.R", tabName = "ui", icon = icon("code")),
                       menuSubItem("server.R", tabName = "server", icon = icon("code"))
              )
              # ,
              # menuItem("About me", tabName = "about", icon=icon("mortar-board"))
  ),
  hr())
  
body <- dashboardBody(
   tabItems(
     ## Word Prediction
     tabItem(tabName = "WordApp",
             textInput("phrase", label = "Write your text", value = ""),
             fluidRow(
               column(6,
                      actionButton("goButton", "Predict the next word!"),
                      br(), br(),
                      p("Prediction...")
               ),
               column(6,
                      p(textOutput("stats")),
                      h2(textOutput("nextword"))
                      )
               )
             ),
     ## Codebook Tab
     tabItem(tabName = "description",
             includeMarkdown("description.Rmd")
     ),
     ## About Tab
     # tabItem(tabName = "about",
     #         includeHTML("CVinfografico-v2.html")
     # ),
     ## Codebook Tab
     tabItem(tabName = "CodeBook",
             includeMarkdown("codebook.Rmd")
     ),
     ## Getdata Code
     tabItem(tabName = "getdata",
             box( width = NULL, status = "primary", solidHeader = TRUE, title="getdata.R",
                  br(),br(),
                  pre(includeText("getdata.R"))
             )
     ),
     ## cleandata Code
     tabItem(tabName = "cleandata",
             box( width = NULL, status = "primary", solidHeader = TRUE, title="cleandata.R",
                  br(),br(),
                  pre(includeText("cleandata.R"))
             )
     ),
     ## getngram.R Code
     tabItem(tabName = "getngram",
             box( width = NULL, status = "primary", solidHeader = TRUE, title="getngram.R",
                  br(),br(),
                  pre(includeText("getngram.R"))
             )
     ),
     ## stupidbackoff.R Code
     tabItem(tabName = "stupidbf",
             box( width = NULL, status = "primary", solidHeader = TRUE, title="stupidbackoff.R",
                  br(),br(),
                  pre(includeText("stupidbackoff.R"))
             )
     ),
     ## User Interface Code
     tabItem(tabName = "ui",
             box( width = NULL, status = "primary", solidHeader = TRUE, title="Users Interface Code (ui.R)",
                  pre(includeText("ui.R"))
             )
     ),
     ## Server Code
     tabItem(tabName = "server",
             box(width = NULL, status = "primary", solidHeader = TRUE, title="Server Code (server.R)",
                 br(),br(),
                 pre(includeText("server.R"))
             )
     )
   )
)

dashboardPage(
  dashboardHeader(title = "Word Prediction"),
  sidebar,
  body,
  skin = 'purple'
)