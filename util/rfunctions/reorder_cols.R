library(data.table)
library(dplyr)

reorder_cols <- function(input_dir) {
  
  files <- list.files(input_dir)
  
  for (file in files) {
    
    data <- fread(paste0(input_dir, file))
    
    data <- data %>%
      select(sentence_id, token, speechdate)
    
    export_name <- paste0(input_path, "/", file)
    fwrite(export_name) } }

reorder_cols("/home/stephbuon/projects/smu_19th_century_hansard_corpus_with_improved_speaker_names/hansard_tokens/")
