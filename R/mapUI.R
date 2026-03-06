library(shiny)
library(leaflet)

mapUI <- function(id) {
  tagList(
    leaflet::leafletOutput(NS(id, "map"))
  )
}