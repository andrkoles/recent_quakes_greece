library(shiny)

dataServer <- function(input, output, session) {
  return(list(
    quakes = reactive({
      # 1 sec = 1000 ms
      invalidateLater(2 * 1000 * 60)
      source("R/extract_data.r")
      return(data)
    })
  ))
}
