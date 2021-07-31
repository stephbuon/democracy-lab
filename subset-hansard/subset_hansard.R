library(tidyverse)
library(lubridate)

subset_hansard <- function(data, first_year, last_year, export_fpath) {

  hansard <- read_tsv(data)

  # i need to fix this -- greater/less than or equal to doesn't wokr -- I also need to change speechdate to a diff col name
  hansard <- hansard %>%
    filter(year(speechdate) >= first_year) %>%
    filter(year(speechdate) =< last_year)
  
  hansard <- hansard %>%
    mutate(year = year(as.Date(hansard$speechdate))
           
  fname <- "hansard_" + "first_year" + "-" + "last_year" + ".csv"

  write_csv(hansard, file.path(export_fpath, fname)) }
           
subset_hansard("/scratch/group/pract-txt-mine/data_sets/hansard/", 1800, 1910, "~/")
