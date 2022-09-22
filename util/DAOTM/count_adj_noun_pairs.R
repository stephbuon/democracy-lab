
# if you do not already have posextractr installed, you will need to install it:
# require(devtools)
# install_github("stephbuon/posextractr")

library(data.table)
library(tidyverse)
library(posextractr)
library(reticulate)

posextract_initialize()

hansard <- fread("/home/stephbuon/data/hansard_justnine_w_year.csv") 

hansard <- hansard %>% 
  select(sentence_id, text, year) %>% 
  filter(str_detect(text, regex("woman|women", ignore_case = T))) %>% 
  mutate(decade = year - year %% 10) %>% 
  select(-year)

decades <- c(1800, 1810, 1820, 1830, 1840, 1850, 1860, 1870, 1880, 1890, 1900)

out <- data.frame()

for(d in decades) {
  
  filtered_hansard <- hansard %>%
    filter(decade == d)
  
  adjective_noun_pairs <- extract_adj_noun_pairs(filtered_hansard$text)
  
  adjective_noun_pairs <- adjective_noun_pairs %>%
    mutate(adj_noun_pair = paste(adjective, noun))
  
  adjective_noun_pairs$adj_noun_pair <- str_to_lower(adjective_noun_pairs$adj_noun_pair)  
  
  adjective_noun_pairs$adj_noun_pair <- str_replace(adjective_noun_pairs$adj_noun_pair, "women", "woman")
  
  adjective_noun_pairs <- adjective_noun_pairs %>% 
    filter(str_detect(adj_noun_pair, regex("ignorant(.*)woman")))
  
  adjective_noun_pairs <- adjective_noun_pairs %>% 
    count(adj_noun_pair) %>%
    mutate(decade = paste(d))
  
  out <- bind_rows(out, adjective_noun_pairs)
}

k <- out 

dput(k)

ignorant_woman_df <- structure(list(adj_noun_pair = c("ignorant woman", "ignorant woman", 
                                      "ignorant woman", "ignorant womanhood", "ignorant woman", "ignorant woman", 
                                      "ignorant woman"), n = c(1L, 2L, 2L, 1L, 2L, 1L, 3L), decade = c("1830", 
                                                                                                       "1840", "1870", "1870", "1880", "1890", "1900")), row.names = c(NA, 
                                                                                                                                                                       -7L), class = "data.frame")

ggplot(out, 
       aes(x = decade, y = n, group = 1)) +
  geom_line() + 
  ggtitle("Count of the Adjective \"Ignorant\" Modifying Lemma \"Woman\"") 

ggsave("plot.png", dpi=700)

ggplot(out, 
       aes(x = decade, y = n, group = 1)) +
  geom_line() + 
  geom_point() +
  ggtitle("Count of the Adjective \"Ignorant\" Modifying Lemma \"Woman\"") 

ggsave("plot_w_dots.png", dpi=700)

ggplot(out, 
       aes(x = decade, y = n, group = 1)) +
  geom_point() +
  geom_smooth() +
  ggtitle("Count of the Adjective \"Ignorant\" Modifying Lemma \"Woman\"") 

ggsave("plot_w_smooth.png", dpi=700)
