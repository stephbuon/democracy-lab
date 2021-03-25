library(tidyverse)
library(tidytext)

future_tense_triples <- read_csv("hansard_c19_future_tense_triples_debate_text_03232021.csv")

future_tense_triples <- future_tense_triples %>%
  select(triple, year)

future_tense_triples$triple <- str_remove(future_tense_triples$triple, "^-")
future_tense_triples$triple <- str_remove(future_tense_triples$triple, "\"")

# hash to see all future tense triples 
future_tense_triples <- future_tense_triples %>%
  filter(str_detect(triple, "i-", negate = T)) %>%
  filter(str_detect(triple, "-allow-", negate = T)) %>%
  filter(str_detect(triple, "-opinion", negate = T)) %>%
  filter(str_detect(triple, "-attention", negate = T)) %>%
  filter(str_detect(triple, "-agree-", negate = T)) %>%
  filter(str_detect(triple, "-impossible", negate = T)) %>%
  filter(str_detect(triple, "-table-", negate = T)) %>%
  filter(str_detect(triple, "-resolve-", negate = T)) %>%
  filter(str_detect(triple, "-inquiry", negate = T)) %>%
  filter(str_detect(triple, "-step-", negate = T)) %>%
  filter(str_detect(triple, "-convenient", negate = T)) %>%
  filter(str_detect(triple, "-ask-", negate = T)) %>%
  filter(str_detect(triple, "-necessary", negate = T)) %>%
  filter(str_detect(triple, "-unnecessary", negate = T)) %>%
  filter(str_detect(triple, "-able", negate = T)) %>%
  filter(str_detect(triple, "-obvious", negate = T)) 

interval <- 10

future_tense_triples <- future_tense_triples %>%
  mutate(decade = year - year %% interval)

future_tense_triples <- future_tense_triples %>%
  group_by(decade, triple) %>%
  count(triple)

top_future_tense_triples <- future_tense_triples %>%
  group_by(decade) %>%
  arrange(desc(n)) %>%
  slice(seq_len(20)) %>%
  #top_n(10) %>%
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
