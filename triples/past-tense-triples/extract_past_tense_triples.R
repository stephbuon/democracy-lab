library(tidyverse)

triples <- read_csv("~/c19_hansard_debate_text_triples_07232021.csv")

triples$triple <- triples$triple %>%
  tolower()

# since I do not yet have negation before objects I only go up to six possibilities
matches <- c(".*-.*ed-.*", ".*-.*-.*ed-.*", ".*-.*-.*-.*ed-.*", ".*-.*-.*-.*ed-.*") 

past_tense_triples <- tibble()

for(i in 1:length(keywords_value)) {
  
  match <- matches[i]
  
  filtered_triples <- triples %>%
    filter(str_detect(triple, match))
  
  past_tense_triples <- bind_rows(past_tense_triples, filtered_triples) }

#TODO: 
# went -- look up list of past tense words without -ed 
# add these irregular verbs: https://www.ecenglish.com/learnenglish/lessons/irregular-verb-list

write_csv(past_tense_triples, "~/past_tense_triples_08192021.csv")


#library(tidyverse)

#triples <- read_csv("")

#out <- triples %>%
#  filter(str_detect("[]-[]ed-*"))

#out_2 <- triples %>%
#  filter(str_detect("[]-will-[]ed-*"))

# merge the two data sets

# export data sets 
