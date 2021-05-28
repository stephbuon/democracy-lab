library("tidyverse")
library("lubridate")

tidyhans <- read_csv("/scratch/group/pract-txt-mine/tokenized_hansard.csv")

tidyhans <- tidyhans %>%
  mutate(year = year(as.Date(tidyhans$speechdate)))

tidyhans <- tidyhans %>%
  mutate(decade = year - year %% 10) %>%
  group_by(decade) %>%
  summarize(n = n()) %>%
  top_n(5)

tidyhans %>%
  ggplot(aes(x = word, 
             y = n)) +
  geom_bar() +
  facet_wrap(~decade) +
  ggtitle("Top Words by Decade") +
  labs(x = "raw count", y = "word") +
  theme(axis.text.x = element_text(angle = 90)) #+
  #scale_x_continuous(labels = comma)

setwd("~/")
ggsave("top_words_by_decade.pdf", h = 4, w = 6, units = "in", dpi = 500)

