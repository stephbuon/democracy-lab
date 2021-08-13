library(tidyverse)

congress_data <- read_csv("/scratch/group/pract-txt-mine/posextractr/clean_stanford_congressional_records_w_year.csv")

congress_data <- congress_data %>%
  select(-chamber, -number_within_file, -first_name, -last_name, -state, -gender, -line_start, -line_end, -char_count, -word_count)

ids <- 1:186642802

ids <- paste0("rid_", ids)

congress_data <- congress_data %>%
   mutate(row_id = ids)

write_csv(congress_data, "/scratch/group/pract-txt-mine/posextractr/clean_stanford_congressional_records_w_year_2.csv")
