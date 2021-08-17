library(tidyverse)

hansard <- read_csv("~/hansard_justnine_w_year.csv")

remove <- c("\\[", "]", "—$", "^—", "\"", "^ ", "^'")

for(i in 1:length(remove)) {
  r <- remove[i]

  hansard$debate <- hansard$debate %>%
    str_replace(r, "") }

hansard$debate[is.na(hansard$debate)] <- "NA"

write_csv(hansard, "hansard_c19_12192019.csv")
