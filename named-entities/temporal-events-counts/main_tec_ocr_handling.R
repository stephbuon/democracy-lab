# notes from jo: https://docs.google.com/document/d/1pezD4soeb-Xy1OPAnX0_LLS_tsp30GVOYh9W-HwC0D4/edit
# also: note that not everything is labeled properly in this code 

library(tidyverse)
library(tidytext)

named_temporal_events_subset <- FALSE

entity_date_dictionary <- read_csv("entity_date_dictionary.csv") 

if(named_temporal_events_subset == TRUE) {
  hansard_named_temporal_events <- read_csv("/scratch/group/pract-txt-mine/hansard_named_temporal_events.csv") } else {
    
    if (file.exists("hansard_c19_temporal_events_count.csv")) {
      hansard_named_temporal_events <- read_csv("hansard_c19_temporal_events_count.csv") } else {
        
        hansard_c19 <- read_csv("~/hansard_justnine_w_year.csv") %>%
          select(sentence_id, text, year)
        
        keywords_value <- entity_date_dictionary$entity
        
        hansard_named_temporal_events <- tibble()
        for(i in 1:length(keywords_value)) {
          keyword <- keywords_value[i]
          
          filtered_hansard <- hansard_c19 %>%
            filter(str_detect(text, regex(keyword, ignore_case = TRUE))) %>%
            rename(entity = text)
          
          hansard_named_temporal_events <- bind_rows(hansard_named_temporal_events, filtered_hansard) }
        
        write_csv(subset, "hansard_c19_temporal_events_count.csv") } }

find <- c("russian war", "great southern and western line", "great northern bill", "china war", "scottish code", "affghan war", "afghanistan war", "ashantee", "transvaal war", "kafir", "english constitution", "franco german war", "franco - german war", "german war", "british constitution")
replace <- c("crimean war", "great southern and western railway company", "great northern railway", "chinese war", "scotch code", "afghan war", "afghan war", "ashanti", "boer war", "kaffir", "magna carta", "franco-german war", "franco-german war", "franco-german war", "magna carta") 

for(i in seq_along(find)) {
  hansard_named_temporal_events$entity <- str_replace_all(hansard_named_temporal_events$entity, regex(find[[i]], ignore_case = TRUE), regex(replace[[i]], ignore_case = TRUE)) }

interval <- 1
temporal_events_w_decade <- hansard_named_temporal_events %>%
  mutate(decade = year - year %% interval)

# decades <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900")
decades <- 1800:1910

total <- tibble()
for (i in 1:length(decades)) {
  d <- decades[i]
  
  decade_of_interest <- temporal_events_w_decade %>%
    filter(decade == d)
  
  patterns_to_match <- entity_date_dictionary$entity
  
  entity_count <- tibble()
  for(i in 1:length(patterns_to_match)) {
    pattern <- patterns_to_match[i]
    
    matches <- decade_of_interest %>%
      filter(str_detect(entity, regex(pattern, ignore_case = TRUE)))
    
    if(named_temporal_events_subset == TRUE) {
      matches <- matches %>%
        select(-year, -decade) %>%
        add_tally() %>%
        mutate(entity = pattern) } else {
          
          matches$occurances <- str_count(matches$entity, regex(pattern, ignore_case = TRUE)) }
    matches$entity <- paste0(pattern)
    
    entity_count <- bind_rows(entity_count, matches) } 
  
  decade_of_interest <- decade_of_interest %>%
    select(sentence_id, year, decade)
  
  entity_count <- left_join(entity_count, decade_of_interest, on = "sentence_id") 
  
  total <- bind_rows(total, entity_count) }

out <- left_join(total, entity_date_dictionary, on = "entity")

out <- out %>%
  select(-year, -sentence_id) %>%
  distinct()

#out <- out %>%
#  str_replace(entity, "american war", "american war of independence")

#endings <- c("war", "revolution", "railway", "exhibition", "code", "convention", "constitution", 
#             "company", "boyne", "waterloo", "laws", "colony", "campaign", "inquisition", "articles", "company")
# ends_with is not working for me 

#out <- gsub("")

#include_triples_count$triples_count <- gsub("$", ")", include_triples_count$triples_count)

out$entity <- str_to_title(out$entity)

out <- out %>%
  rename(period = decade)

write_csv(out, "entity_count.csv")
