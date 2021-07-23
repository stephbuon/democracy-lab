library(tidyverse)
library(lubridate)

subset_hansard <- function(data, first_year, last_year, export_fpath) {

  hansard <- read_tsv(data)

  hansard <- hansard %>%
    filter(year(speechdate) >= first_year) %>%
    filter(year(speechdate) =< last_year)
  
  hansard <- hansard %>%
    mutate(year = year(as.Date(hansard$speechdate))
           
  fname <- "hansard_" + "first_year" + "-" + "last_year" + ".csv"

  write_csv(hansard, file.path(export_fpath, fname)) }
           
subset_hansard("/scratch/group/pract-txt-mine/data_sets/hansard/", 1800, 1910, "~/")
