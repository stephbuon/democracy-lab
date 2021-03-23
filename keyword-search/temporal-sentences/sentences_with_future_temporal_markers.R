# filter the C19 Hansard debates for sentences with future tense temporal markers. 

library(tidyverse)

setwd("~/triples_in_hansard")

hansard <- read_csv("hansard_justnine_12192019.csv")

keywords <- read_csv("future_temporal_markers.csv")

keywords_value <- keywords$temporal_marker

temporal_sentences <- tibble()

for(i in 1:length(keywords_value)) {
  
  keyword <- keywords_value[i]
  
  filtered_hansard <- hansard %>%
    filter(str_detect(text, fixed(keyword, ignore_case = TRUE)))
  
  temporal_sentences <- bind_rows(temporal_sentences, filtered_hansard) }

write.csv(temporal_sentences, "hansard_c19_sentences_with_future_temporal_markers_03232021.csv")
