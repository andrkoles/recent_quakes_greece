library(shiny)
library(bslib)
library(bsicons)

source("R/tableUI.R")
source("R/tableServer.R")
source("R/dataServer.R")
source("R/mapUI.R")
source("R/mapServer.R")
source("R/rowDataServer.R")
source("R/updateMapServer.R")

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
      mapUI("map"),
      full_screen = TRUE
    ),
    card(
      card_header("Select an entry to highlight it on the map"),
      tableUI("table"),
      full_screen = TRUE
    ),
    height = 770
  )
)

server <- function(input, output, session) {

  df <- callModule(dataServer, "data")

  table <- callModule(tableServer, "table", dataset = df)

  map <- callModule(mapServer, "map", dataset = df)

  row_data <- callModule(rowDataServer, "row_data",
                         dataset = df, table = table)

  callModule(updateMapServer, "map", row_data = row_data, map = map)

  latest <- reactive({
    df$quakes() |>
      slice_max(order_by = time) |>
      select(magnitude, place) |>
      paste()
  })

  output$latest <- renderText({
    paste0(latest()[1], " Magnitude, ", latest()[2])
  })
}

shinyApp(ui, server)
