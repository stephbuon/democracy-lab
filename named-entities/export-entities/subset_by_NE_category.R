library(tidyverse)

df <- read_csv("/scratch/group/pract-txt-mine/sbuongiorno/NER_22730187/concat_data.csv")

df <- df %>%
  filter(named_entities != "[]")

category_list <- c("GPE", "LAW", "PERSON", "LOC", "DATE", "ORG", "EVENT")

for(c in category_list){
  
  filtered_df <- df %>%
    filter(str_detect(named_entities, c))
  
  #regex <- "(?=\\().*?(?<=\\))"
  regex <- paste0("(?=\\(", c, ").*?(?<=\\))")
  
  filtered_df$clean_NE <- str_extract_all(filtered_df$named_entities, regex)
  
  filtered_df <- filtered_df %>% 
    mutate(clean_NE = map_chr(clean_NE, toString))
  
  filtered_df <- filtered_df %>% 
    filter(clean_NE != "")
  
  #df <- df %>%
  #  select(-named_entities)
  
  write_csv(filtered_df, paste0("/scratch/group/history/hist_3368-jguldi/stanford_congressional_records_named_entities_", c, ".csv")) }