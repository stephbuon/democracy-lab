#test codeowner script
library("tidyverse")
library("lubridate")
library("scales")
library("tidytext")

hansard <- read_csv("/scratch/group/pract-txt-mine/tokenized_hansard.csv")

hansard <- hansard %>%
  rename(word = ngrams)

hansard <- hansard %>%
  anti_join(get_stopwords())

hansard <- hansard %>%
  mutate(year = year(as.Date(hansard$speechdate)))

hansard <- hansard %>%
  mutate(decade = year - year %% 10) %>%
  group_by(decade, word) %>%
  summarize(n = n()) %>%
  top_n(5) %>%
  ungroup()

ggplot(data = hansard) +
  geom_col(aes(x = reorder_within(word, n, decade), 
               y = n),
           fill = "steel blue") +
  labs(title = "Top Words by Decade",
       subtitle = "From 19th-century British Parliamentary Debate Text",
       x = "word",
       y = "raw count") +
  scale_x_reordered() +
  facet_wrap(~ decade, scales = "free") + 
  coord_flip() +
  scale_y_continuous(labels = comma)
  
  
setwd("~/")
ggsave("top_words_by_decade.pdf", h = 4, w = 6, units = "in", dpi = 500)
