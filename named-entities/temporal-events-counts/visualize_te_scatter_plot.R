### graphing
library(ggrepel)
library(tidyverse)
library(viridis)

# countedevents <- read_csv("entity_count.csv") # put correct file path 
subset <- countedevents %>% 
  filter(scholar_assigned_date > 1770) 

ggplot(subset, 
       aes(x = period, 
           y = scholar_assigned_date, 
           color = n)) + #, 
           #label = paste0(entity, ' (', scholar_assigned_date, ')') )) + 
  scale_color_viridis(breaks = round, 
                      trans = "log", 
                      option = "B", 
                      discrete = F, 
                      direction = 1) +
  geom_point(shape = 15, 
             alpha = .3, 
             aes(size = n*5)) +
  geom_text_repel(data = subset %>% 
                    group_by(entity) %>% 
                    arrange(desc(n)) %>% 
                    slice(2), 
                  aes(color = 1, 
                      x = period + 0.03, 
                      label = paste0(entity, ' (', scholar_assigned_date, ')'), 
                      size = n*5), #size = rel(4), 
                  hjust=0) +
  labs(x = "timeline", y = "mentions per year") +
  ggtitle("Events Mentioned by Name in Parliament")


ggsave("events-mentioned-after-1770.pdf", h = 7, w = 5, units = "in")
