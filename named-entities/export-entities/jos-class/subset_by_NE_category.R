library(tidyverse)

#df <- read_csv("/scratch/group/pract-txt-mine/sbuongiorno/NER_22730187/concat_data.csv")
df <- read_csv("~/test_NER.csv")

df <- df %>%
  filter(named_entities != "[]")

category_list <- c("GPE", "LAW", "PERSON", "LOC", "DATE", "ORG", "EVENT")
#category_list <- c("NORP", "FAC", "PRODUCT", "WORK_OF_ART", "LANGUAGE", "TIME", "PERCENT", "MONEY", "QUANTITY", "ORDINAL", "CARDINAL")

for(c in category_list){
  
  filtered_df <- df %>%
    filter(str_detect(named_entities, c))
  
  #regex <- "(?=\\().*?(?<=\\))"
  regex <- paste0("[^']+(?=',\\s*'",c,"'\\))")
  filtered_df$clean_NE <- str_extract_all(filtered_df$named_entities, regex)
  
  filtered_df <- filtered_df %>% 
    mutate(clean_NE = map_chr(clean_NE, toString))
  
  filtered_df <- filtered_df %>% 
    filter(clean_NE != "")
  
  filtered_df <- filtered_df %>%
    select(-named_entities, -parsed_text)
  
  write_csv(filtered_df, paste0("/scratch/group/history/hist_3368-jguldi/stanford_congressional_records_named_entities_", c, ".csv")) }
