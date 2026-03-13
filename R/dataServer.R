library(shiny)

source("R/extract_data.r")

# RSS feed URL
# 
# Data source:
# Seismological Laboratory of National and Kapodistrian University
# of Athens (http://dggsl.geol.uoa.gr/en_index.html)

url <- "http://www.geophysics.geol.uoa.gr/stations/maps/seismicity.xml"

dataServer <- function(input, output, session) {
  return(list(
    quakes = reactive({
      # 1 sec = 1000 ms
      invalidateLater(2 * 1000 * 60)
      data <- read_rss(url) |> 
        extract_data()
      return(data)
    })
  ))
}
