library(tidyverse)

setwd("/scratch/group/pract-txt-mine")

tokenized_hansard <- read_csv("hansard_tokenized.csv")

tokenized_hansard <- tokenized_hansard %>%
select(sentence_id, ngrams)

stopwords <- read_csv("stopwords.csv")

stopwords <- stopwords %>%
rename(ngrams = word)

tokenized_hansard <- tokenized_hansard %>%
group_by(ngrams) %>%
count(ngrams)

tokenized_hansard <- tokenized_hansard %>%
anti_join(stopwords, by = "ngrams")

tokenized_hansard <- tokenized_hansard %>%
filter(count > 500)

dir <- setwd("~/")

write_csv(tokenized_hansard, file.path(dir, "top_1grams_c20_hansard.csv")
