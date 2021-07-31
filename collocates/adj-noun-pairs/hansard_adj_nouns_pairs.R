library(tidyverse)

hansard <- read_csv(file.path(dir, "/scratch/group/pract-txt-mine/democracy-lab/adjective-noun-pairs-woman/hansard_1870_79_adjective_noun_pairs.csv"))

hansard$pair <- hansard$pair %>%
  tolower()

hansard <- hansard %>%
  filter(str_detect(pair, "woman"))


remove_list <- c("many", "such", "few", "other", "more")

clean_hansard <- tibble()

for(i in 1:length(remove_list)) {
  
  remove <- remove_list[i]
  
  filtered_hansard <- hansard %>%
    filter(str_detect(triple, remove, negate = TRUE)) }

clean_hansard <- clean_hansard %>%
  select(pair) %>%
  count(pair)

top_pairs <- clean_hansard %>%
  arrange(desc(n)) %>%
  slice(seq_len(45)) 

top_pairs$pair <- top_pairs$pair %>%
  str_to_title()

ggplot(data = top_pairs) +
  geom_col(aes(x = reorder(pair, n), 
               y = n),
           fill = "steel blue") +
  coord_flip() +
  labs(title = "Top Lemmatized Adjective-Noun Pairs with Woman",
       #subtitle = "From 19th-century British Parliamentary Debate Text",
       caption = "Searching the Hansard Parliamentary Debates from 1870-79",
       x = "Adjective-Noun Pair",
       y = "Count") 

# this ggsave w/ systime is not working on M2 
ggsave(file.path(dir, paste("hansard_adjective_noun_pairs_woman_1870_79_", format(Sys.time(), "%Y-%m-%d_%H-%M"), ".png"), dpi = 1000))
