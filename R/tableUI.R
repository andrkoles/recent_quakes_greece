library(DT)
library(shiny)

tableUI <- function(id) {
  tagList(
    DT::dataTableOutput(NS(id, "table"))
  )
}