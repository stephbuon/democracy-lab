library(tidyverse)
library(ngram)

setwd("/scratch/group/pract-txt-mine")

hansard <- read_csv("hansard_c19_triples_debate_text_02022021.csv")

hansard$triple <- hansard$triple %>%
tolower()

keywords <- read_csv("propertywords.csv")

keywords_value <- keywords$adscription

property_triples <- tibble()

for(i in 1:length(keywords_value)) {

  keyword <- keywords_value[i]

  filtered_hansard <- hansard %>%
    filter(str_detect(triple, keyword))

property_triples <- bind_rows(property_triples, filtered_hansard) }

write.csv(property_triples, "hansard_c19_debate_text_property_triples.csv")
