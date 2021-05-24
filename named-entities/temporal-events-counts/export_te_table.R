library(ggrepel)
library(tidyverse)
library(viridis)

counted_events <- read_csv("~/entity_count_05242021.csv")
 put correct file path 

out <- counted_events %>%
  group_by(entity, scholar_assigned_date) %>%
  summarize(total = sum(occurances))

# contents can be copied/pasted into a word doc
# inside the word doc, the user can highlight the contents and go to table -> convert -> convert text to table 
write.table(out, paste0(file = "entities_count_table.txt"), sep = ",", quote = FALSE, row.names = F)

