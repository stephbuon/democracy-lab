library(tidyverse)

hansard <- read_csv("hansard_c19_triples_debate_text_03232021.csv")

filtered_hansard <- hansard %>%
filter(str_detect(triple, regex("-will-", ignore_case = TRUE)))

write.csv(filtered_hansard, "hansard_c19_future_tense_triples_debate_text_03232021.csv")
