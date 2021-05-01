# verify that entity counts are correct

library(tidyverse)

keyword <- "crimean war"

return_entity_count <- function(variable, kw) {
  out <- variable %>%
    filter(str_detect(entity, regex(kw, ignore_case = TRUE)) %>%
    group_by(entity) %>%
    add_count(entity) %>%
    ungroup()
  return(out) }

count_1 <- hansard_named_events %>%
  filter(str_detect(entity, regex(keyword, ignore_case = TRUE))) %>%
  group_by(entity) %>%
  add_count(entity) %>%
  ungroup()

count_2 <- hansard_named_times %>%
  filter(str_detect(entity, regex(keyword, ignore_case = TRUE))) %>%
  group_by(entity) %>%
  add_count(entity) %>%
  ungroup()

interval <- 10

count_3 <- read_csv("hansard_named_temporal_events_triples.csv") %>%
  mutate(decade = year - year %% interval)


return_entity_count


