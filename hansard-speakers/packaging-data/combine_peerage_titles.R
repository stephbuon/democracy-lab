library(tidyverse)
library(readxl)

dir <- "~/Downloads/peerage-titles/"
main <- read_csv("~/Downloads/short_list_peerage_titles.csv") 
files <- list.files(path=dir, pattern="*.xlsx")

for(file in files) {
  temp <- read_excel(paste0(dir, file)) 
  
  temp$corresponding_id <- as.character(temp$corresponding_id)
  temp$start <- as.character(temp$start)
  temp$end <- as.character(temp$end)
  
  main <- bind_rows(main, temp) }

main <- main %>%
  filter(!is.na(alias == T))

main$alias <- str_to_title(main$alias)
main$real_name <- str_to_title(main$real_name)

main <- main %>%
  arrange(alias)

write_csv(main, "~/Downloads/peerage_titles.csv")
