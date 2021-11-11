library(tidyverse)

df <- read_csv("/scratch/group/pract-txt-mine/sbuongiorno/NER_22730187/concat_data.csv")

category_list <- c("GPE", "LAW", "PERSON", "LOC", "DATE", "ORG", "EVENT")

for(c in category_list){
  
  filtered_df <- df %>%
    filter(str_detect(named_entities, c))
  
  #regex <- "(?=\\().*?(?<=\\))"
  regex <- paste0("(?=\\(", c, ").*?(?<=\\))")
  
  df$clean_NE <- str_extract_all(df$named_entities, regex)
  
  df <- df %>% 
    mutate(clean_NE = map_chr(clean_NE, toString))
  
  df <- df %>% 
    filter(!clean_NE == "")
  
  write_csv(filtered_df, paste0("/scratch/group/history/hist_3368-jguldi/stanford_congressional_records_named_entities_", c, ".csv")) }