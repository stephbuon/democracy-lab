library("tidyverse")

collocates_sentiment <- read_csv("~/collocates_sentiment_hansard_06132021.csv")

remove_list <- c("^attorney ", "^landed ", "^landing ", "^eminent", "^perpetual")

clean_collocates_sentiment <- tibble()

for(i in 1:length(remove_list)) {
  
  remove <- remove_list[i]
  
  filtered_gc <- collocates_sentiment %>%
    filter(!str_detect(grammatical_collocates, remove))
  
  clean_collocates_sentiment <- bind_rows(clean_collocates_sentiment, filtered_gc) }

  
write_csv(clean_collocates_sentiment, "~/cleaned_collocates_sentiment_hansard.csv")


clean_collocates_sentiment <- collocates_sentiment %>%
  filter(!str_detect(grammatical_collocates, "^attorney ")) %>%
  filter(!str_detect(grammatical_collocates, "^landed ")) %>%
  filter(!str_detect(grammatical_collocates, "^landing ")) %>%
  filter(!str_detect(grammatical_collocates, "^eminent")) %>%
  filter(!str_detect(grammatical_collocates, "^perpetual"))
