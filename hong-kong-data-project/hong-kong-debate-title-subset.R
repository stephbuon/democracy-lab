
library(tidyverse)

setwd("~/democracy-lab/hong-kong-data-project")

hansard <- read_csv("hansard_c20_12192019_w_year.csv")

keywords <- c("hong kong", "hongkong")

hong_kong_debate_titles <- tibble()

for(i in 1:length(keywords)) {
  
  keyword <- keywords[i]
  
  filtered_hansard <- hansard %>%
    filter(str_detect(debate, regex(keyword, ignore_case = TRUE)))
  
  hong_kong_debate_titles <- bind_rows(hong_kong_debate_titles, filtered_hansard) }

write.csv(hong_kong_debate_titles, "hansard_c20_debate_titles_w_hong_kong.csv")
