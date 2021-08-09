library(tidyverse)
library(ngram)

sentences <- read_csv("~/projects/democracy-lab/google-charts-tools/triples-explorer/landlord_have_power.csv")

sentences <- sentences %>%
  filter(year == 1881) %>%
  select(text)

sentences$text <- str_replace_all(sentences$text, "\"", "")
sentences$text <- str_replace_all(sentences$text, "\'", "")

out <- paste0(concatenate(sentences$text, collapse = " "))

writeLines(out, "~/projects/democracy-lab/google-charts-tools/wordtree/wordtreetext.txt")
