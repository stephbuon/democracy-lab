library(tidyverse)
library(tidytext)

future_tense_triples <- read_csv("hansard_c19_future_tense_triples_debate_text_03232021.csv")

future_tense_triples$triple <- str_remove(future_tense_triples$triple, "^-")

interval <- 10

future_tense_triples <- future_tense_triples %>%
  mutate(decade = year - year %% interval)

future_tense_triples <- future_tense_triples %>%
  group_by(decade, triple) %>%
  count(triple)

top_future_tense_triples <- future_tense_triples %>%
  group_by(decade) %>%
  #arrange(desc(n)) %>%
  #slice(seq_len(15)) %>%
  top_n(10) %>%
  ungroup()

ggplot(data = top_future_tense_triples) +
  geom_col(aes(x = reorder_within(triple, n, decade), 
               y = n),
           fill = "steel blue") +
  labs(title = "Top Future Tense Triples by Decade",
       #subtitle = "From Hansard 19th-century British Parliamentary Debates",
       caption = "Searching the Hansard Parliamentary Debates",
       x = "triple",
       y = "n") +
  scale_x_reordered() +
  facet_wrap(~ decade, scales = "free") +
  coord_flip()
