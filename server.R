shinyServer(function(input, output, session) {

  output$lastupdatetime <- reactive({
    return(paste0("Data last updated on ", format(as.Date(lastupdatetime), "%Y-%m-%d")))
    })

  outputCrossTable <- reactive({
    clinicalOutputCrossTable <- as.data.frame.matrix(table(clinicalStudyList[,c("Drug","Disease")]))
    return(clinicalOutputCrossTable[, diseaseOfInterest] )
  })
  
  filteredDrugs <-  reactive({
    myOutputCrossTable <- outputCrossTable()
    filteredOutputCrossTable <- myOutputCrossTable
    
    if(input$chosenDiseases != ""){
      myOutputCrossTable$select  <- F
      for(chosenDiease in input$chosenDiseases){
        myOutputCrossTable$score1 <- rowSums(myOutputCrossTable[, chosenDiease, drop = F])
        myOutputCrossTable$score2 <- rowSums(myOutputCrossTable[, setdiff(diseaseOfInterest, chosenDiease), drop=F] > 0)
        myOutputCrossTable$select <- myOutputCrossTable$select | (myOutputCrossTable$score1 > 0 | myOutputCrossTable$score2 >= 2)
      }
      filteredOutputCrossTable <- myOutputCrossTable[which(myOutputCrossTable$select), ]
    }
    chosenDrugs <- rownames(filteredOutputCrossTable)
  
    if(input$OnlyCandiates)  chosenDrugs <- intersect(drugOfInterest, chosenDrugs)

    return(chosenDrugs)
  })
  
  frequencyCorssTable <- reactive({
    myOutputCrossTable <- outputCrossTable()
    filteredDrugs <- filteredDrugs()
    return(myOutputCrossTable[filteredDrugs, ])
  })
  
  output$studyTable <- DT::renderDataTable(DT::datatable({
    myTable <-  filiteredPublicationTable()
    myTable$Title <- paste0(myTable$Title, "(",myTable$Author,")")
    myTable$Title <- paste0("<a href='",myTable$Link ,"'target='_blank'>" , myTable$Title,"</a>" )
    
    index <- which(names(myTable) %in% c("X","Abstract","OldIdStr", "idStr", "Author","Link"))
    return(   
      myTable[,-index]
    )
  }),extensions = 'Buttons'
  , filter = 'top', options = list(
    pageLength = 10,lengthMenu = c(10,25,50,100,1000),autoWidth = TRUE
  ), escape=F)
  
  output$frequencyCorssTable <- DT::renderDataTable(DT::datatable({
    return(    frequencyCorssTable())
  }),extensions = 'Buttons'
  , filter = 'top', options = list(
    pageLength = 50,lengthMenu = c(10,25,50,100,1000)
    , dom = 'Blfrtip',buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
  ))
  
  filiteredPublicationTable <- reactive({
    myOutputCrossTable <- frequencyCorssTable()
    chosenDrugs <- filteredDrugs()
    chosenStudies <- clinicalStudyList[clinicalStudyList$Drug %in% chosenDrugs,] %>%
      group_by(OldIdStr) %>%
      summarise(Title = first(Title),
                Author = first(Author),
                Journal = first(Journal),
                Abstract = first(Abstract),
                Year = first(Year),
                idStr = first(idStr),
                HistoricalID = first(HistoricalID),
                PublicationID = first(PublicationID),
                Disease = paste0(Disease, collapse = "; "),
                Drug = paste0(Drug, collapse = "; "),
                Link = first(Link)
      )
    return(chosenStudies)
  })
  
  output$DownloadFilteredPublications <-  downloadHandler(
    filename = "FilteredPublications.csv", content = function(file){
      write.csv({
        filiteredPublicationTable()
      }
      , file, na = "", row.names = F
      )
    })
  
  selectedPublicationTable <- reactive({
    myOutputCrossTable <- frequencyCorssTable()
    chosenDrugs <- rownames(myOutputCrossTable)[input$frequencyCorssTable_rows_selected]
    chosenStudies <- clinicalStudyList[clinicalStudyList$Drug %in% chosenDrugs,] %>%
      group_by(OldIdStr) %>%
      summarise(Title = first(Title),
                Author = first(Author),
                Journal = first(Journal),
                Abstract = first(Abstract),
                Year = first(Year),
                idStr = first(idStr),
                HistoricalID = first(HistoricalID),
                PublicationID = first(PublicationID),
                Disease = paste0(Disease, collapse = "; "),
                Drug = paste0(Drug, collapse = "; "),
                Link = first(Link)
      )
    return(chosenStudies)
  })
  
  output$DownloadSelectedPublications <-
    downloadHandler(
      filename = "SelectedPublications.csv",
      content = function(file){
        write.csv({
          selectedPublicationTable()
        }
        , file, na = "", row.names = F
        )
      }
    )
  
  ExtractinvivoStudies <- reactive({
    return(invivoStudyList)
  })
  
  filiteredPublicationTableinvivo <- reactive({
    invivoStudyList <- ExtractinvivoStudies()
    chosenDrugs <- filteredDrugs()
    choseninvivoStudies <- invivoStudyList[invivoStudyList$Drug %in% chosenDrugs,] %>%
      group_by(idStr) %>%
      summarise(Title = first(Title),
                Author = first(Author),
                Journal = first(Journal),
                Abstract = first(Abstract),
                Year = first(Year),
                Disease = paste0(Disease, collapse = "; "),
                Drug = paste0(Drug, collapse = "; ")
                )
    
    return(choseninvivoStudies)
  })
  
  output$DownloadFilteredPublicationsinvivo <-  downloadHandler(
    filename = "invivoFilteredPublications.csv", content = function(file){
      write.csv({
        filiteredPublicationTableinvivo()
      }
      , file, na = "", row.names = F
      )
    })
  
  selectedPublicationTableinvivo <- reactive({
    invivoStudyList <- ExtractinvivoStudies()
    myOutputCrossTable <- frequencyCorssTable()
    
    chosenDrugs <- rownames(myOutputCrossTable)[input$frequencyCorssTable_rows_selected] 
    choseninvivoStudies <- invivoStudyList[invivoStudyList$Drug %in% chosenDrugs,] %>%
      group_by(idStr) %>%
      summarise(Title = first(Title),
                Author = first(Author),
                Journal = first(Journal),
                Abstract = first(Abstract),
                Year = first(Year),
                Disease = paste0(Disease, collapse = "; "),
                Drug = paste0(Drug, collapse = "; ")
      )
    
    return(choseninvivoStudies)
  })
  
  output$DownloadSelectedPublicationsinvivo <-
    downloadHandler(
      filename = "invivoSelectedPublications.csv",
      content = function(file){
        write.csv({
          selectedPublicationTableinvivo()
        }
        , file, na = "", row.names = F
        )
      }
    )
})
