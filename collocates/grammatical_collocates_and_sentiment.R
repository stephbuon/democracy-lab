library(tidyverse)
library(tidytext)

hansard <- read_csv("~/hansard_justnine_12192019.csv")


# import the property keywords, and don't trim white space upon reading in? 

# only keep sentences that have a property word

# parse the hansard corpus w spacy

# keep tokens that are the heads or children of property terms
# - check if this is what jo wants -- or if she wants just words sharing a grammatical relationship with property terms, 
# regardless of where they are in the sentence 
# # do str_detect on both the unlemmatized and lemmatized versions of the term 
# acutally, I think the collocate can be someplace else in the sentence 

# run sentimenet annalyses on these (all libraries)

# export a csv file with 1) property term, 2) collocate, 3) head or child, 4) part-of-speech (noun? verb? adj)
# include lemmatized and non-lemmatized versions of the words? 


grammatical_collocates_sentiment <- grammatical_collocates %>% # does this work? 
  inner_join(get_sentiments(c("bing", "afinn", "nrc")))
