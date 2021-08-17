library(tidyverse)

triples <- read_csv("~/posextractr/c19_hansard_debate_text_triples_07232021.csv")

triples_out <- triples %>%
  filter(str_detect(triple, "landlord-have-power"))

decade <- 10

triples_out <- triples_out %>%
  mutate(decade = year - year %% decade, text)

write_csv(triples_out, "~/landlord_have_power.csv")
