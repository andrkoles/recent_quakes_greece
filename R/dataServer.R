library(shiny)

source("R/extract_data.r")

dataServer <- function(input, output, session) {
  return(list(
    quakes = reactive({
      # 1 sec = 1000 ms
      invalidateLater(2 * 1000 * 60)
      data <- extract_data()
      return(data)
    })
  ))
}
