library(tidyverse)
library(googleVis)

triples <- read_csv("~/posextractr/c19_hansard_debate_text_triples_07232021.csv")

triples_out <- triples %>%
  filter(str_detect(triple, "landlord-have-power"))

decade <- 10

triples_out <- triples_out %>%
  mutate(decade = year - year %% decade, text)

triples_date <- triples_out %>%
  filter(decade == 1820)

triples_date <- triples_date %>%
  select(text) 

triples_date <- triples_date %>%
  rename(Phrase = text)

wt1 <- gvisWordTree(triples_date, textvar = "Phrase")

plot(wt1)
