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
                "-excuse-me", "-inform-you", "act-will-", "-to-division", "he-will-be-prepared", "-which", "do-to-justice", 
                "-present-to-parliament", "-to-appointment", "-take-care", "-do-good", "member-will", "-have-goodness", "-be-in-hand",
                "-accept-ammendment", "-give-name", "-make-statement", "-will-be-prepared", "-make-statement", "-state-rate", "-state-for-year",
                "bill-", "-bill", "-question", "-amendment", "pardon-me", "-give-return", "-into-case", "-in-order", "-take-action",
                "-be-surprised", "that-", "-that", "give-reading", "forgive-for-me", "-facility", "-give-number", "-be-great",
                "state-to-reason", "-take-measure", "-continue-same", "give-figure", "give-notice", "get-return", "in-return", 
                "-commend-itself", "order-will", "into-circumstance", "committee-will-be-glad", "-into-matter", "-term", "-opportunity",
                "-matter", "-state-nature", "-legislation", "-available", "-do-", "-be-kind", "bear-me", "in-matter", "be-prepare", "be-willing",
                "state-gound", "bear-in-mind", "make-representation", "give-for-year", "-will-correct-me", "-motion", "-be-willing", "-state-cause",
                "fix-day", "be-liable", "be-aware", "be-of-advantage", "have-right", "give-answer", "take-course", "communicate-with-me",
                "tell-you", "take-by-", "have-power", "take-trouble", "-be-glad", "-board", "find-it", "-have-nothing", "-state-date", 
                "per-hour", "issue-to-owner", "state-ground", "in-case", "for-it", "make-arrangment",) 

newest_filter_out <- c("i-", "-allow-", "opinion", "-attention", "-agree-", "-impossible", "-table", "-resolve-", "inquiry",
                "-step-", "convenient", "-ask-", "-necessary", "-unnecessary", "-able", "-obvious", "-pleased", "take-into", 
                "-be-satisfied", "-permit-me", "-be-well", "-state-reason", "-have-effect", "-tell-us", "-instruction", "-take-step",
                "take-in-step", "-bear-with-me", "house", "-grant-return", "-have-opportunity", "in-recollection", "-be-of-course",
                "-lay-in-copy", "-put-question", "-see-way", "-in-position", "-be-open", "-state-number", "view", "-be-possible",
                "-in-course", "which-", "-be-easy", "-be-good", "consider", "convenience", "-report", "-state-amount", "-give-assurance",
                "-be-ready", "it-will-", "-bill", "-copy", "-mean", "-lay-", "-what", "-state-name", "-forgive-me", "-use-influence",
                "-give-information", "-tell-me", "-forgive-me", "-on-paper", "-appoint-committee", "-direction", "-have-objection",
                "-excuse-me", "-inform-you", "act-will-", "-to-division", "he-will-be-prepared", "-which", "do-to-justice", 
                "-present-to-parliament", "-to-appointment", "-take-care", "-do-good", "member-will", "-have-goodness", "-be-in-hand",
                "-accept-ammendment", "-give-name", "-make-statement", "-will-be-prepared", "-make-statement", "-state-rate", "-state-for-year",
                "bill-", "-bill", "-question", "-amendment", "pardon-me", "-give-return", "-into-case", "-in-order", "-take-action",
                "-be-surprised", "that-", "-that", "give-reading", "forgive-for-me", "-facility", "-give-number", "-be-great",
                "state-to-reason", "-take-measure", "-continue-same", "give-figure", "give-notice", "get-return", "in-return", 
                "-commend-itself", "order-will", "into-circumstance", "committee-will-be-glad", "-into-matter", "-term", "-opportunity",
                "-matter", "-state-nature", "-legislation", "-available", "-do-", "-be-kind", "bear-me", "in-matter", "be-prepare", "be-willing",
                "state-gound", "bear-in-mind", "make-representation", "give-for-year", "-will-correct-me", "-motion", "-be-willing", "-state-cause",
                "fix-day", "be-liable", "be-aware", "be-of-advantage", "have-right", "give-answer", "take-course", "communicate-with-me",
                "tell-you", "take-by-", "have-power", "take-trouble", "-be-glad", "-board", "find-it", "-have-nothing", "-state-date", 
                "per-hour", "issue-to-owner", "state-ground", "in-case", "for-it", "make-arrangment", "concern", "satisfaction", "explanation",
                "-state-", "submit", "accept", "conclusion", "advisability", "hear", "give-order", "difficulty", "impossible", "unable",
                "attention", "adhere", "conclusion", "introduce", "pursue", "adopt-course", "intereset", "give-detail", "give-data", "issue-order",
                "furnish", "take-case", "give-effect", "put-vote", "take-in-action", "-advise-", "take-under-circumstance", "give-burden",
                "investigation", "consent", "give-day") 

future_tense_triples <- future_tense_triples %>% 
  filter(!(str_detect(triple, paste(filter_out, collapse = '|')))) %>%
  filter(!(str_detect(triple, regex("[[:digit:]]-")))) %>%
  filter(!(str_detect(triple, regex("-[[:digit:]]"))))


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
