library("tidyverse")

collocates_sentiment <- read_csv("~/collocates_sentiment_hansard_06132021.csv")

remove_list <- c("^attorney ", "^landed ", "^landing ", "^eminent", "^perpetual")

for(i in 1:length(remove_list)) {
  
  remove <- remove_list[i]
  
  collocates_sentiment <- collocates_sentiment %>%
    filter(!str_detect(grammatical_collocates, remove)) }

write_csv(collocates_sentiment, "~/cleaned_collocates_sentiment_hansard.csv")
