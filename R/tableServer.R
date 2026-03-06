library(shiny)
library(DT)
library(dplyr)

tableServer <- function(input, 
                        output, 
                        session,
                        dataset) {
  
  output$table <- DT::renderDataTable(
    dataset$quakes() |> select(-c(id, ago)),
    server = FALSE,
    selection = 'single'
  )
  
  return(
    list(row = reactive({
      req(input$`table_rows_selected`)
      
      input$`table_rows_selected`
    }))
  )
}