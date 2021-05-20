library(tidyverse)
library(tidytext)

setwd("/scratch/group/pract-txt-mine")

named_temporal_events <- read_csv("hansard_named_temporal_events.csv")

named_temporal_events$entity <- named_temporal_events$entity %>%
  tolower()

decade <- 10

named_temporal_events <- named_temporal_events %>%
  mutate(decade = year - year %% decade)

named_temporal_events_count <- named_temporal_events %>%
  group_by(decade, entity) %>%
  count(entity, decade) %>%
  arrange(desc(n)) %>%
  ungroup() 

top_named_temporal_events <- named_temporal_events_count %>%
  group_by(decade) %>%
  arrange(desc(n)) %>%
  slice(seq_len(25)) %>%
  ungroup() 

ggplot(data = top_named_temporal_events) +
  geom_col(aes(x = reorder_within(entity, n, decade), 
               y = n),
           fill = "steel blue") +
  labs(title = "Top Named Temporal Events by Decade",
       subtitle = "From the Hansard Parliamentary Debate Text",
       x = "Named Temporal Entity",
       y = "n") +
  scale_x_reordered() +
  facet_wrap(~ decade, scales = "free") + 
  coord_flip() 
