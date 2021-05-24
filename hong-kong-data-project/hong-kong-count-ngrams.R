
library(tidyverse)


setwd("/scratch/group/pract-txt-mine")
hansard <- read_csv("hansard_c20_2_grams.csv")

stopwords <- read_csv("stopwords.csv")

stopwords <- stopwords %>%
rename(ngrams = word)

# for 2-grams
hansard <- hansard %>%
  separate(ngrams, c("word_1", "word_2"), sep = " ")

hansard <- hansard %>%
  filter(!word_1 %in% stopwords$ngrams) %>%
  filter(!word_2 %in% stopwords$ngrams) %>%
  transmute(ngrams = paste(word_1, word_2))

# for 1-grams
#hansard <- hansard %>%
#anti_join(stopwords, by = "ngrams")

hansard <- hansard %>%
group_by(ngrams) %>%
count(ngrams)

hansard <- hansard %>%
arrange(desc(n))

hansard <- hansard %>%
top_n(800)

hansard <- hansard %>%
select(ngrams, n)

#setwd("~/")
write.csv(hansard, "top_2_grams_c20_hansard.csv", row.names = F)

