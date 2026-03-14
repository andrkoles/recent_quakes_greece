library(shiny)
library(leaflet)
library(leaflet.extras)
library(gt)
library(dplyr)

mapServer <- function(input,
                      output,
                      session,
                      dataset) {
  
  output$map <- renderLeaflet({
    # All earthquakes except the first-latest
    leaflet(data = dataset$quakes()[-1, ]) |>
      addProviderTiles(provider = providers$Esri.WorldImagery) |>
      addCircleMarkers(
        ~longitude,
        ~latitude,
        layerId = ~id,
        fillColor = ~pal(cut(ago, breaks = c(0, 1, 2, 6, 12, 24, 48))),
        stroke = TRUE,
        weight = 1,
        color = "black",
        fillOpacity = 1,
        radius = ~sqrt(magnitude) * 5,
        popup = ~paste(
          "Place:", place, "<br/>",
          "Time:", time, "<br/>",
          "Magnitude:", round(magnitude, 1), "<br/>",
          "Depth:",  round(depth), " km", "<br/>",
          "Latitude", latitude, "<br/>",
          "Longitude", longitude
        )|> map(gt::html),
        popupOptions = c(textsize = 20)) |>
      # Most recent earthquake is shown with a pulse marker
      addPulseMarkers(
        data = dataset$quakes()[1, ],
        ~longitude,
        ~latitude,
        layerId = ~ id,
        icon = makePulseIcon(heartbeat = ~  (1 / sqrt(magnitude))),
        popup = ~ paste(
          "Place:", place, "<br/>",
          "Time:", time, "<br/>",
          "Magnitude:", round(magnitude, 1), "<br/>",
          "Depth:",  round(depth), " km", "<br/>",
          "Latitude", latitude, "<br/>",
          "Longitude", longitude
        )|> map(gt::html),
        popupOptions = c(textsize = "15px")
      ) |>
      addLegend(
        "topright",
        colors = palette,
        labels = c("0 - 1h ago", "1 - 2h ago", "2 - 6h ago", "6 - 12h ago",
                   "12 - 24h ago", "24 - 48h ago"),
        values = ~ago,
        bins = 6,
        opacity = 1
      ) |>
      addFullscreenControl()
  })
  
  return(
    list(
      zoom = reactive({
        req(input$`map_zoom`)
        input$`map_zoom`
      })
    )
  )
}