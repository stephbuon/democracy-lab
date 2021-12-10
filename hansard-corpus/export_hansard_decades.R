library(data.table)
library(dplyr)

export_split_data <- function(input_dir, export_name) {
  
  hansard_corpus <- fread(input_dir)
  
  # temp
  hansard_corpus <- hansard_corpus %>%
    rename(bigram = ngrams)
  
  decades <- c(1800, 1810, 1820, 1830, 1840, 1850, 1860, 1870, 1880, 1890, 1900, 1910)
  
  for(d in decades) {
    
    hansard_decade <- hansard_corpus %>%
      filter(decade == d)
    
    dir.create(file.path(paste0("./", export_name)))
    
    full_export_name <- paste0("./", export_name, "/", export_name, "_", d, ".csv")
    
    fwrite(hansard_decade, full_export_name) } }


export_split_data("/scratch/group/pract-txt-mine/sbuongiorno/bigrams_hansard_improved_speaker_names_w_decade.csv", "hansard_bigrams")
