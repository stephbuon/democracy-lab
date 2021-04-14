##### BASELINE SETUP
parallel <- FALSE
computer <- "loaner" # amend setfolders.R to give universal names to your own machine
description <- "NULL"

# folder locations -- set variables codedir, datafolder, vizfolder, wordcount_data and wordcount_visualizations to match locations in your own machine.
setwd("~/Box Sync/#learningtocode/hansard/")
setwd("~/Box/#learningtocode/hansard")
setwd("/Volumes/Land/storage/Data/Box Sync/#learningtocode/hansard")
source("setfolders.R")
setfolders(computer)

# load some functions & libraries
setwd(codedir)
source("wordcount-functions.R")
standard_library()

#read in hansard
if (!exists("hansard")) {
  hansard <- readhansard()
}

# #hansard <- hansard %>% filter(year > 1880) %>% filter(year <= 1890)
#hans1850 <- hansard %>% filter(year >1840, year < 1860)
#tidyhans <- tidyhansard(hans1850, TRUE)
# #setwd("datadir")
# #write_csv(tidyhans)

