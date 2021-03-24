library(tidyverse)
library(tidytext)

property_triples <- read_csv("hansard_c19_property_triples_debate_text_03232021.csv")

property_triples$triple <- str_remove(property_triples$triple, "^-")
property_triples$triple <- str_remove(property_triples$triple, "\"")

property_triples <- property_triples %>%
  select(triple, year)

# need to remove gather or whatever it is from dictionary
property_triples <- property_triples %>%
  filter(str_detect(triple, "magistrate-have-power", negate = T)) %>%
  filter(str_detect(triple, "i-gather-from-speech", negate = T)) %>%
  filter(str_detect(triple, "magistrate-have-right", negate = T)) %>%
  filter(str_detect(triple, "magistrates-have-right", negate = T)) %>%
  filter(str_detect(triple, "which-be-common", negate = T)) %>%
  filter(str_detect(triple, "it-be-common", negate = T)) %>%
  filter(str_detect(triple, "i-gather-what", negate = T)) %>%
  filter(str_detect(triple, "i-gather-from-speech", negate = T)) %>%
  filter(str_detect(triple, "magistrate", negate = T)) %>%
  filter(str_detect(triple, "he-be-common", negate = T)) %>%
  filter(str_detect(triple, "he-gather-from-speech", negate = T)) %>%
  filter(str_detect(triple, "it-consolidate-law", negate = T)) %>%
  filter(str_detect(triple, "property-be-to-which", negate = T)) %>%
  filter(str_detect(triple, "which-affect-property", negate = T))


interval <- 10

property_triples <- property_triples %>%
  mutate(decade = year - year %% interval)

property_triples <- property_triples %>%
  group_by(decade, triple) %>%
  count(triple)

top_property_triples <- property_triples %>%
  group_by(decade) %>%
  arrange(desc(n)) %>%
  slice(seq_len(20)) %>%
  #top_n(10) %>%
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
