library(tidyverse)

hansard <- read_csv("~/hansard_justnine_12192019.csv")

hansard <- hansard %>%
  select(debate) %>%
  unique()

hansard <- as.data.frame(hansard)

write_csv(hansard, "hansard_c19_debate_titles.csv")
