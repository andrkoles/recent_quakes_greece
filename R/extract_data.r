library(tidyr)
library(purrr)
library(dplyr)
library(tidyRSS)

# RSS feed URL
# 
# Data source:
# Seismological Laboratory of National and Kapodistrian University
# of Athens (http://dggsl.geol.uoa.gr/en_index.html)

rss <- "http://www.geophysics.geol.uoa.gr/stations/maps/seismicity.xml"

rss_df <- tidyRSS::tidyfeed(rss, parse_dates = FALSE)

# The item_description column holds data for each earthquake in string form
description <- rss_df |>
  select(item_description)

# Using regular expressions, extracts six variables for each earthquake
data <-
  description |>
  tidyr::separate_wider_regex(
    item_description,
    patterns = c(
      place = "[0-9]+\\.[0-9]+\\skm\\s[A-Z]+\\sof\\s[A-z]+",
      "\\s+Time:\\s+",
      time = "[0-9]+\\-[A-z]{3}-[0-9]+\\s[0-9]+\\:[0-9]+\\:[0-9]+",
      "\\s\\(UTC\\)",
      "\\s+Latitude:\\s+",
      latitude = "[0-9]{2}\\.[0-9]{2}",
      "[A-Z]\\s+Longitude:\\s+",
      longitude = "[0-9]{2}\\.[0-9]{2}",
      "[A-Z]\\s+Depth:\\s+",
      depth = "[0-9]+",
      "km\\s+M\\s+",
      magnitude = "[0-9]+\\.[0-9]+"
    )
  )

date_format <- "%e-%b-%Y %H:%M:%S"

data <- 
  data |> 
  mutate(
    time = paste0(time, " UTC"),
    ago = difftime(Sys.time(), 
                   as.POSIXct(time, format = date_format, tz = "UTC"),
                   units = "hours")
  )

# The id will facilitate the table row to map interaction 
data$id <- 1:nrow(data)

columns <- c("latitude", "longitude", "depth", "magnitude", "ago")
data[columns] <- map(data[columns], as.numeric)