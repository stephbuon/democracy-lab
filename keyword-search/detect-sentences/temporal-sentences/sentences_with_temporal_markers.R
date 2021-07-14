library(tidyverse)

setwd("~/triples_in_hansard")

detect_keywords <- function(data, col_name, keywords_list, export_name) {
  hansard <- read_csv(data)
  #keywords <- read_csv(keywords_list) # read as a list 
  keywords <- strsplit(readLines(keywords_list), ", ") # is this working? IDK 
  
  temporal_sentences <- tibble()
  
  for(i in 1:length(keywords)) {
    
    keyword <- keywords[i]
    
    filtered_data <- data %>%
      filter(str_detect( {{col_name}} , regex(keyword, ignore_case = TRUE)))
    
    temporal_sentences <- bind_rows(temporal_sentences, filtered_data) }
  
  write_csv(temporal_sentences, export_name)
  
}

detect_keywords("hansard_justnine_w_year.csv", text, "property_keywords.csv", "hansard_c19_sentences_with_past_temporal_markers.csv")

