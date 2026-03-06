library(shiny)
library(dplyr)

rowDataServer <- function(input, 
                          output,
                          session,
                          dataset,
                          table) {
  return(
    list(
      row_data = reactive({
        r <- dataset$quakes() |>
          filter(id == table$row())

        return(r)
      })
    )
  )
}
