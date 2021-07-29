## Please note that by default the googleVis plot command
## will open a browser window and requires Internet
## connection to display the visualisation.

library(tidyverse)
library(googleVis)
library(tidytext)

#triples <- read_csv("~/posextractr/c19_hansard_debate_text_triples_07232021.csv")
triples <- read_csv("~/Downloads/landlord_have_power.csv")

#triples_out <- triples %>%
#  filter(str_detect(triple, "landlord-have-power"))

#decade <- 10

#triples_out <- triples_out %>%
#  mutate(decade = year - year %% decade, text)

triples_date <- triples %>%
  filter(decade == 1890) %>%
  select(text)

j = 5 # how many words constitute a phrase?

out <- triples_date %>%
  unnest_tokens(text, text, token = "ngrams", n = j)

out <- out %>%
  filter(str_detect(text, "power$"))

#wt1 <- gvisWordTree(out, textvar = "text")
#plot(wt1)

wt2 <- gvisWordTree(out, textvar = "text",
                    options = list(fontName = "Times-Roman",
                                   wordtree = "{word: 'landlord'}"))
plot(wt2)
