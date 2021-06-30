library(tidyverse)
library(lubridate)

setwd("/scratch/group/pract-txt-mine/data_sets/hansard/")
hansard <- read_tsv("hansard_20191119.tsv")

firstyear = 1799 # although, the first recorded date is acutally 1803
lastyear = 1911

hansard <- hansard %>%
  filter(year(speechdate) > firstyear) %>%
  filter(year(speechdate) < lastyear)

hansard <- hansard %>%
  mutate(year = year(as.Date(hansard$speechdate))

dir <- setwd("~/")
write_csv(hansard, file.path(dir, "hansard_c19_12192019.csv"))
