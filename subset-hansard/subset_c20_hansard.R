library(tidyverse)
library(lubridate)

setwd("/scratch/group/pract-txt-mine/data_sets/hansard/")
hansard <- read_tsv("hansard_20191119.tsv")

firstyear = 1910
lastyear = 2011

hansard <- hansard %>%
  filter(year(speechdate) > firstyear) %>%
  filter(year(speechdate) < lastyear)

dir <- setwd("~/")
write_csv(hansard, file.path(dir, "hansard_c20_12192019.csv"))
