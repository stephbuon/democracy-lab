library(data.table)
library(dplyr)
library(tidytext)

export_split_data <- function(input_dir, export_name) {
  
  corpus <- fread(input_dir) %>%
    mutate(year = str_extract(url, regex("[:digit:]{4}")),
           speech_id = row_number()) %>%
    select(-url)
  
  corpus <- corpus %>%
    unnest_tokens(word, text)
  
  years <- 1999:2022
  
  for(y in years) {
    
    corpus_decade <- corpus %>%
      filter(year == y)
    
    dir.create(file.path(paste0("./", export_name)))
    
    full_export_name <- paste0("./", export_name, "/", export_name, "_", y, ".csv")
    
    fwrite(corpus_decade, full_export_name) } }


setwd('/scratch/group/pract-txt-mine/')
export_split_data("/scratch/group/pract-txt-mine/sbuongiorno/congress_climate.csv", "congress_climate_tokens")
