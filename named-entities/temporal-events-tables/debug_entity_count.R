# count entity debugging script

library(tidyverse)

keyword <- "crimean war"
interval <- 10

#hansard_named_temporal_events_triples <- read_csv("hansard_named_temporal_events_triples.csv") %>%

#hansard_named_temporal_events_triples
#  mutate(decade = year - year %% interval)

return_entity_count <- function(variable, pattern, filter_decade = 0) {
  if(filter_decade == TRUE) {
    variable <- variable %>%
      filter(decade == "1860") }
  
  variable <- variable %>%
    filter(str_detect(entity, regex(pattern, ignore_case = TRUE)))
  
  entity_count <- variable %>%
    count() %>%
    mutate(entity = pattern)
  return(entity_count) }

    

count_1 <- return_entity_count(hansard_named_events, keyword)

count_2 <- return_entity_count(hansard_named_times, keyword)

count_3 <- return_entity_count(entites_triples_w_event_count, keyword, filter_decade = FALSE)

