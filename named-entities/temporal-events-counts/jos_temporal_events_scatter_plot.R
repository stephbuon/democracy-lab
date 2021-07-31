library(ggrepel)
library(tidyverse)
library(viridis)
setwd("/Users/joguldi/Dropbox")
counted_events <- read_csv("entity_count_05242021.csv")
counted_events <- counted_events %>%
  group_by(entity, period, occurances) %>%
  add_count() %>%
  select(-occurances)
ungroup()
subset <- counted_events %>% 
  filter(scholar_assigned_date < 1770)
​
by_event_totals <- subset %>% group_by(entity) %>% summarize(total = sum(n)) %>%
  filter(!str_detect(entity, "Chinese")) %>%
  filter(!str_detect(entity,"Southern")) %>%
  filter(!str_detect(entity,"Scotch Code")) %>%
  filter(!str_detect(entity,"North Sea Convention")) %>%
  top_n(25, wt = total) %>% 
  select(entity)
​
subset2 <- subset %>% ungroup() %>% inner_join(by_event_totals) 
​
# All labels should be to the right of 1900.
x_limits <- c(1920, NA)
​
ggplot(data = subset2,  aes(x = period, y = scholar_assigned_date, size = n*5, color = n)) + #, 
  #label = paste0(entity, ' (', scholar_assigned_date, ')') )) + 
  scale_color_viridis(breaks = round, 
                      trans = "log", 
                      option = "B", 
                      discrete = F,
                      direction = 1) +
  geom_point(
             alpha = .1, 
             shape = 15
            ) +
 # scale_x_discrete(expand=c(0, 1)) +
  coord_cartesian(clip = 'off') +
  geom_text(data = subset2 %>%
                    group_by(entity) %>%
                    arrange(desc(n)) %>%
                    slice(2),
                  aes(color = 1,
                      label = paste0(entity, ' (', scholar_assigned_date, ')'),
                      y = scholar_assigned_date
                  ),
                  x = 1918,
                  size = 3,
                  hjust = 0
  ) +
  # geom_text_repel(data = subset2 %>%
  #             group_by(entity) %>%
  #             arrange(desc(n)) %>%
  #             slice(2),
  #           aes(color = 1,
  #               label = paste0(entity, ' (', scholar_assigned_date, ')'),
  #               x = Inf,
  #               y = scholar_assigned_date,
  #               size = n,
  #               hjust = -1/n
  #              ),
  #           xlim = x_limits,
  #           force = 0.3,
  #           segment.size = 0.05
  #           ) +
  theme(legend.position = "bottom", plot.margin = unit(c(1,10,1,1), "lines")) +
  guides(shape = "none") +
  labs(x = "when parliament spoke", y = "events mentioned in the past") +
  ggtitle("Events Mentioned by Name in Parliament")
ggsave("events-mentioned-before-1770.pdf", h = 7, w = 5, units = "in")
