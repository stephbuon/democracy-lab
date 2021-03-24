
library(tidyverse)

setwd("~/triples_in_hansard")

hansard <- read_csv("hansard_c19_triples_debate_text_03232021.csv")

hansard$triple <- hansard$triple %>%
tolower()

keywords <- read_csv("propertywords_cleaned_for_triples.csv")

keywords_value <- keywords$property_keyword

property_triples <- tibble()

for(i in 1:length(keywords_value)) {
  
  keyword <- keywords_value[i]
  
  filtered_hansard <- hansard %>%
    filter(str_detect(triple, regex(keyword, ignore_case = TRUE)))
  
  property_triples <- bind_rows(property_triples, filtered_hansard) }

write.csv(property_triples, "hansard_c19_property_triples.csv")
