library(tidyverse)
library(lubridate)

congressional_records <- read_csv("~/stanford_congressional_records.csv")

congressional_records$date <- gsub('^(.{4})(.*)$', '\\1-\\2', congressional_records$date)

congressional_records$date <- gsub('^(.{7})(.*)$', '\\1-\\2', congressional_records$date)

congressional_records <- congressional_records %>%
  mutate(year = year(as.Date(congressional_records$date)))

write_csv(congressional_records, "stanford_congressional_records_w_year.csv")
