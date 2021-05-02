library(tidyverse)

keyword <- "crimean war"

if(!exists("hansard_named_temporal_events")) {
  interval <- 10
  hansard_named_temporal_events <- read_csv("hansard_named_temporal_events.csv") %>%
    mutate(decade = year - year %% interval) }

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

count_3 <- return_entity_count(entity_count, keyword, filter_decade = FALSE)


