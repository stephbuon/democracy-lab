## count entity debugging script

library(tidyverse)

keyword <- "crimean war"
interval <- 10

hansard_named_temporal_events_triples <- read_csv("hansard_named_temporal_events_triples.csv") %>%
  mutate(decade = year - year %% interval)

return_entity_count <- function(variable, pattern) {
  out <- variable %>%
    filter(str_detect(entity, regex(pattern, ignore_case = TRUE)) %>%
    group_by(entity) %>%
    add_count(entity) %>%
    select(entity, n) %>%
    ungroup()
  return(out) }


count_1 <- return_entity_count(hansard_named_events, keyword)

count_2 <- return_entity_count(hansard_named_times, keyword)

count_3 <- return_entity_count(hansard_named_temporal_triples, keyword)

