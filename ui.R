shinyUI(fluidPage(
  tags$head(
    tags$style(
      "
      .inlineText * {
      display: inline;
      }
      .buff * {
      padding:50px 5px 30px 5px}
      "
    )
  ),
  theme = shinytheme("flatly"),
  navbarPage(
    "ReLiSyR",
    tabPanel(
      "Home"
      ,
      column(
        3
        ,
      selectizeInput(
        "chosenDiseases",
        "Choose disease of interest"
        ,
        diseaseOfInterest,
        multiple = F,
        selected = "MND"
      ),
      br(), br(),
      materialSwitch(inputId = "OnlyCandiates", label = "Only show core drug candidates", value = FALSE, status = "info"),
      br(),hr(),
      downloadButton("DownloadFilteredPublications", label = "Clinical publications for filtered drugs", class = "btn-info"),
      br(),br(),
      downloadButton("DownloadSelectedPublications", label = "Clinical publications for selected drugs", class = "btn-primary"),
      hr(),
      downloadButton("DownloadFilteredPublicationsinvivo", label = "in vivo publications for filtered drugs", class = "btn-info"), 
      br(),br(),
      downloadButton("DownloadSelectedPublicationsinvivo", label = "in vivo publications for selected drugs", class = "btn-primary"),  
      br(),br(),
      tags$p(textOutput("lastupdatetime"))
      )
      ,
      column(
        9
        ,
        tabsetPanel(type = "tabs",
                    tabPanel("Drug Disease Cross Table",   DT::dataTableOutput("frequencyCorssTable")),
                    tabPanel("Study List",   DT::dataTableOutput("studyTable"))
        )
    )),
    tabPanel(
      "About"
      ,
      h3("GOAL")
      ,p("ReLiSyR project is to automate the drug selection procedure for Motor Neuron Disease (MND) through running three concurrent living projects on SyRF platform and create an external API that fetch the data from those three projects for presentation and calculation. ")
    ,
    h3("METHOD"),
    list(
      tags$p("Create living systeamtic review projects using", tags$a(href='http://app.syrf.org.uk', "SyRF web application")), 
      tags$p("Automatic extract disease and drug use predefied regualr expression dictionary"), 
      tags$p("Drug prioritisation with the frequency of drug test in different diseases.")
    )
  )
  )))
