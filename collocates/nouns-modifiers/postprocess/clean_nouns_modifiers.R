library(tidyverse)

collocates_sentiment <- read_csv("~/collocates_sentiment_laden_noun_modifiers_property_keywords_07222021.csv")

remove_list <- c(" attorney$", " attornies$",  " landing$", " eminenet$", " perpetual$", " splendor$ ", " landsman$", " feud$", 
                 " feudatory$", " feudalism", " vassalage$")

for(i in 1:length(remove_list)) {
  
  remove <- remove_list[i]
  
  collocates_sentiment <- collocates_sentiment %>%
    filter(!str_detect(grammatical_collocates, remove)) }

write_csv(collocates_sentiment, "~/cleaned_collocates_sentiment_laden_noun_modifiers_property_keywords_07222021.csv")
