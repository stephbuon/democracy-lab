library(tidyverse)
library(tidytext)

future_tense_triples <- read_csv("hansard_c19_future_tense_triples_debate_text_03232021.csv")

future_tense_triples <- future_tense_triples %>%
  select(triple, year)

#future_tense_triples$triple <- str_remove(future_tense_triples$triple, "\\.")
future_tense_triples$triple <- str_remove(future_tense_triples$triple, "^-")
future_tense_triples$triple <- str_remove(future_tense_triples$triple, "\"")


filter_out <- c("i-", "-allow-", "opinion", "-attention", "-agree-", "-impossible", "-table", "-resolve-", "inquiry",
                "-step-", "convenient", "-ask-", "-necessary", "-unnecessary", "-able", "-obvious", "-pleased", "take-into", 
                "-be-satisfied", "-permit-me", "-be-well", "-state-reason", "-have-effect", "-tell-us", "-instruction", "-take-step",
                "take-in-step", "-bear-with-me", "house", "-grant-return", "-have-opportunity", "in-recollection", "-be-of-course",
                "-lay-in-copy", "-put-question", "-see-way", "-in-position", "-be-open", "-state-number", "view", "-be-possible",
                "-in-course", "which-", "-be-easy", "-be-good", "consider", "convenience", "-report", "-state-amount", "-give-assurance",
                "-be-ready", "it-will-", "-bill", "-copy", "-mean", "-lay-", "-what", "-state-name", "-forgive-me", "-use-influence",
                "-give-information", "-tell-me", "-forgive-me", "-on-paper", "-appoint-committee", "-direction", "-have-objection",
                "-excuse-me", "-inform-you", "act-will-", "-to-division", "he-will-be-prepared") 

future_tense_triples <- future_tense_triples %>% 
  filter(!(str_detect(triple, paste(filter_out, collapse = '|'))))

future_tense_triples <- future_tense_triples %>% 
  filter(!(str_detect(triple, regex("[[:digit:]]-"))))


interval <- 10

future_tense_triples <- future_tense_triples %>%
  mutate(decade = year - year %% interval)

future_tense_triples <- future_tense_triples %>%
  group_by(decade, triple) %>%
  count(triple)

top_future_tense_triples <- future_tense_triples %>%
  group_by(decade) %>%
  arrange(desc(n)) %>%
  slice(seq_len(20)) %>%
  #top_n(10) %>%
  ungroup()

ggplot(data = top_future_tense_triples) +
  geom_col(aes(x = reorder_within(triple, n, decade), 
               y = n),
           fill = "steel blue") +
  labs(title = "Top Future Tense Triples by Decade",
       #subtitle = "From Hansard 19th-century British Parliamentary Debates",
       caption = "Searching the Hansard Parliamentary Debates",
       x = "triple",
       y = "n") +
  scale_x_reordered() +
  facet_wrap(~ decade, scales = "free") +
  coord_flip()
