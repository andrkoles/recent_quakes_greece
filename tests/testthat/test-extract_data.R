test_that("extract_data() extracts earthquake data", {
  input <- tibble::tibble(
    item_description = paste0(
      # The number of spaces is important, as it reflects the number of spaces
      # in the elements of the item_description column 
      "29.7 km NNE of Igoumenitsa Time: 11-Mar-2026 22:55:24 (UTC)",  
      "  Latitude: 39.77N  Longitude: 20.33E  Depth: 2km  M 1.9")
  )
  
  date_format <- "%e-%b-%Y %H:%M:%S"
  
  output <- tibble::tibble(
    place = "29.7 km NNE of Igoumenitsa",
    time = "11-Mar-2026 22:55:24 UTC",
    latitude = 39.77,
    longitude = 20.33,
    depth = 2,
    magnitude = 1.9,
    ago = as.numeric(
      difftime(
        Sys.time(),
        as.POSIXct("11-Mar-2026 22:55:24 UTC", format = date_format, tz = "UTC"),
        units = "hours"
      )
    ),
    id = 1
  )
  
  source("R/extract_data.r")
  
  # The tolerance argument is important for the 'ago' column
  expect_equal(extract_data(input), output, tolerance = 1e-5)
})
