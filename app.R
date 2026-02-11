library(shiny)
library(dplyr)
library(leaflet)
library(leaflet.extras)
library(bslib)
library(gt)
library(bsicons)

ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "cosmo"),
  h1(""),
  layout_column_wrap(
    value_box(
      title = "Map:",
      value = "Recent Seismic Activity in Greece",
      showcase = bs_icon("activity"),
      theme = "teal"
    ),
    value_box(
      title = "Latest Earthquake:",
      value = textOutput("latest"),
      showcase = bs_icon("clock"),
      theme = "danger",
    ),
    value_box(
      title = markdown("##### Data Source:"),
      showcase = bs_icon("database-fill"),
      theme = "dark",
      value = markdown("#### Seismological Laboratory of National and Kapodistrian University of Athens")
    ),
    height = 180
  ),
  layout_columns(
    card(
      card_header("Click a marker for additional information"),
      leafletOutput("map"),
      full_screen = TRUE
    ),
    card(
      card_header("Select an entry to highlight it on the map"),
      dataTableOutput("table"),
      full_screen = TRUE
    ),
    height = 770
  )
)

server <- function(input, output, session) {
  
  # The RSS feed is read every one minute to stay up to date with latest earth-
  # quakes
  quakes <- reactive({
    # 1 sec = 1000 ms
    invalidateLater(1000 * 60)
    source("R/extract_data.r")
    return(data)
  })
  
  # Show the earthquakes table, except for the id column
  output$table <- DT::renderDataTable(
    quakes() |> select(-id),
    server = FALSE,
    selection = 'single',
  )
  
  # Latest earthquake
  latest <- reactive({
    quakes() |> 
      slice_max(order_by = time) |> 
      select(magnitude, place) |> 
      paste()
  })
  
  # Latest earthquake value box
  output$latest <- renderText({
    paste0(latest()[1], " Magnitude, ", latest()[2])
  })
  
  # Earthquake map.
  output$map <- renderLeaflet({
    # All earthquakes except the first-latest
    leaflet(data = quakes()[-1, ]) |>
      addProviderTiles(provider = providers$Esri.WorldImagery) |>
      addCircleMarkers(
        ~longitude,
        ~latitude,
        layerId = ~id,
        fillColor = "orange",
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
        data = quakes()[1, ],
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
      addFullscreenControl()
  })
  
  # Row selected from earthquakes table
  row_selected <- reactiveVal(NaN)
  
  # Update row_selected() when user clicks a row from the table
  observeEvent(input$table_rows_selected, {
    row_selected(input$table_rows_selected)
  })
  
  # Extracts data for the selected row and the zoom level at the moment of 
  # selection
  data_row <- reactive({
    row <- quakes() |> 
      filter(id == row_selected())
    row["zoom"] <- input$map_zoom
    return(row)
  })

  # Modify the map to highlight the user selected table entry
  observeEvent(input$table_rows_selected, {
    leafletProxy("map") |>
      removeMarker(layerId = "highlight") |>
      addCircleMarkers(
        data = data_row(),
        ~longitude,
        ~latitude,
        layerId = "highlight",
        fillColor = "white",
        stroke = TRUE,
        weight = 1,
        color = "black",
        fillOpacity = 2,
        radius = ~sqrt(magnitude) * 5,
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
        lng = data_row()$longitude,
        lat = data_row()$latitude,
        zoom = data_row()$zoom
      )
  })
}

shinyApp(ui, server)