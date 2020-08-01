library(shiny)
library(shinythemes)
library(shinyWidgets)
library(DT)
library(googlesheets4)
library(dplyr)
source('configure.R')

log <- googlesheets4::read_sheet(sheetId, sheet="log")
lastupdatetime <- max(log$UpdateTime)

diseaseOfInterest <- as.data.frame(googlesheets4::read_sheet(sheetId, sheet="diseaseOfInterest"))[,1]
drugOfInterest <- as.data.frame(googlesheets4::read_sheet(sheetId, sheet="drugOfInterest"))[,1]

clinicalStudyList <- RMySQL::dbReadTable(con, "ReLiSyRClinicalStudies") 
invivoStudyList <- RMySQL::dbReadTable(con, "ReLiSyRinvivoStudies")
  