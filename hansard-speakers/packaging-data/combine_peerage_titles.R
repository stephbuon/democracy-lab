library(tidyverse)

dir <- "~/Downloads/redo/"

main <- read_csv("~/Downloads/redo/name_aliases.csv") %>%
  select(corresponding_id, alias, real_name, start, end)
main_2 <- read_csv("~/Downloads/redo/etc_oneoffs.csv") %>%
  select(corresponding_id, alias, real_name, start, end)

main <- bind_rows(main, main_2)

files <- list.files(path=dir, pattern="*.csv")

for(file in files) {
  temp <- read_csv(paste0(dir, file)) %>%
    select(corresponding_id,	alias, real_name, start, end)
  
  temp$start <- as.character(temp$start)
  temp$end <- as.character(temp$end)
  
  main <- bind_rows(main, temp) }

main <- main %>%
  filter(!is.na(alias == T))

main$alias <- str_to_title(main$alias)
main$real_name <- str_to_title(main$real_name)

main <- unique(main)

main <- main %>%
  arrange(alias)

write_csv(main, "~/Downloads/peerage_titles.csv")
