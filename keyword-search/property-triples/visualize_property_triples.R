library(tidyverse)
library(tidytext)

property_triples <- read_csv("hansard_c19_property_triples_debate_text_03232021.csv")

property_triples$triple <- str_remove(property_triples$triple, "^-")

property_triples <- property_triples %>%
  select(triple, n, year)

#property_triples <- property_triples %>%
#  filter(str_detect(triple, "\\b-land-\\b", negate = T))

interval <- 10

property_triples <- property_triples %>%
  mutate(decade = year - year %% interval)

property_triples <- property_triples %>%
  group_by(decade, triple) %>%
  count(triple)

top_property_triples <- property_triples %>%
  group_by(decade) %>%
  #arrange(desc(n)) %>%
  #slice(seq_len(15)) %>%
  top_n(10) %>%
  ungroup()

ggplot(data = top_property_triples) +
  geom_col(aes(x = reorder_within(triple, n, decade), 
               y = n),
           fill = "steel blue") +
  labs(title = "Top Triples About Property by Decade",
       #subtitle = "From Hansard 19th-century British Parliamentary Debates",
       caption = "Searching the Hansard Parliamentary Debates",
       x = "triple",
       y = "n") +
  scale_x_reordered() +
  facet_wrap(~ decade, scales = "free") +
  coord_flip()
