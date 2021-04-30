library(tidyverse)

hansard <- read_csv("~/triples_in_hansard/hansard_1870_9_adjnoun_pairs.csv")

hansard$pair <- hansard$pair %>%
  tolower()

hansard <- hansard %>%
  filter(str_detect(pair, "woman"))

hansard <- hansard %>%
  filter(str_detect(pair, "many", negate = TRUE)) %>%
  filter(str_detect(pair, "such", negate = TRUE)) %>%
  filter(str_detect(pair, "few", negate = TRUE)) %>%
  filter(str_detect(pair, "other", negate = TRUE)) %>%
  filter(str_detect(pair, "more", negate = TRUE)) 

hansard <- hansard %>%
  select(pair)

hansard <- hansard %>%
  count(pair)

hansard <- hansard %>%
  arrange(desc(n)) %>%
  slice(seq_len(45)) 

hansard$pair <- hansard$pair %>%
  str_to_title()

ggplot(data = hansard) +
  geom_col(aes(x = reorder(pair, n), 
               y = n),
           fill = "steel blue") +
  coord_flip() +
  labs(title = "Top Lemmatized Adjective-Noun Pairs with Woman",
       #subtitle = "From 19th-century British Parliamentary Debate Text",
       caption = "Searching the Hansard Parliamentary Debates from 1870-79",
       x = "Adjective-Noun Pair",
       y = "Count") 
