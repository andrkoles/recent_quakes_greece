library(shiny)
library(leaflet)
library(leaflet.extras)
library(gt)
library(dplyr)

source("R/awesome_icon.R")
source("R/palette.R")

updateMapServer <- function(input,
                            output,
                            session,
                            row_data,
                            map) {
  
  observeEvent(row_data$row_data(), {
    leafletProxy("map", session) |>
      removeMarker(layerId = "highlight") |>
      addAwesomeMarkers(
        icon = awesome,
        data = row_data$row_data(),
        ~longitude,
        ~latitude,
        layerId = "highlight",
        popup = ~ paste(
          "Place:", place, "<br/>",
          "Time:", time, "<br/>",
          "Magnitude:", round(magnitude, 1), "<br/>",
          "Depth:",  round(depth), " km", "<br/>",
          "Latitude", latitude, "<br/>",
          "Longitude", longitude
        )|> map(gt::html),
        popupOptions = popupOptions()
      ) |>
      setView(
        lng = row_data$row_data()$longitude,
        lat = row_data$row_data()$latitude,
        zoom = map$zoom(),
      )
  })
}