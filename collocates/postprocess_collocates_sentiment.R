library("tidyverse")

collocates_sentiment <- read_csv("~/collocates_sentiment_hansard.csv")

remove_list <- c("^attorney ", "^landed ", "^landing ", "^eminent")

clean_collocates_sentiment <- tibble()

for(i in 1:length(remove_list)) {
  
  remove <- remove_list[i]
  
  filtered_gc <- collocates_sentiment %>%
    filter(str_detect(grammatical_collocates, regex(remove, ignore_case = TRUE)))

  clean_collocates_sentiment <- bind_rows(clean_collocates_sentiment, filtered_gc) }

  
write_csv(clean_collocates_sentiment, "~/cleaned_collocates_sentiment_hansard.csv")
