library(tidyr)
library(purrr)
library(dplyr)
library(tidyRSS)

# RSS feed URL
rss <- "http://www.geophysics.geol.uoa.gr/stations/maps/seismicity.xml"

# Data source:
# Seismological Laboratory of National and Kapodistrian University
# of Athens (http://dggsl.geol.uoa.gr/en_index.html)

# Read the RSS feed
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
      time = "[0-9]+\\-[A-z]{3}-[0-9]+\\s[0-9]+\\:[0-9]+\\:[0-9]+\\s\\(UTC\\)",
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

# Creates an id column, which facilitates the row to map interaction feature
data$id <- 1:nrow(data)

# Converts the following columns to numeric type 
columns <- c("latitude", "longitude", "depth", "magnitude")
data[columns] <- map(data[columns], as.numeric)