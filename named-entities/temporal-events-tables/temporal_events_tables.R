# remember that "d" is currently set to a decade, not the loop 
# setwd("~/hansard_ner")


select_events <- TRUE 
select_triples <- TRUE

library(tidyverse)
library(gt)
library(ngram)


if (file.exists("hansard_named_temporal_events.csv")) {
  hansard_named_temporal_events_triples <- read_csv("hansard_named_temporal_events_triples.csv") } else {
    hansard_named_events <- read_csv("hansard_ner_event.csv")
    hansard_named_times <- read_csv("hansard_ner_time.csv")
    
    keep_times <- c("inquisition", # keep time entities with these patterns 
                    "duties", 
                    "holy", 
                    "seven years", 
                    "revolution", 
                    "war", 
                    "act", 
                    "eleven years", 
                    "ten years", 
                    "century", 
                    "christmas", 
                    "three years", 
                    "easter", 
                    "treaty", 
                    "1s12", 
                    "last parliament", 
                    "code", 
                    "convention", 
                    "dark days", 
                    "late king", 
                    "lent", 
                    "modern days")
    
    filtered_times <- tibble()
    for(i in 1:length(keep_times)) {
      keep <- keep_times[i]
      filtered_hansard <- hansard_named_times %>%
        filter(str_detect(entity, keep))
      filtered_times <- bind_rows(filtered_times, filtered_hansard) }
    
    years <- as.character(1000:1910) # sometimes currency is tagged as a year -- this helps us keep just years 
    
    filtered_years <- tibble()
    for(i in 1:length(years)) {
      year <- years[i]
      filtered_hansard <- hansard_named_times %>%
        filter(str_detect(entity, year))
      filtered_years <- bind_rows(filtered_years, filtered_hansard) }
    
    hansard_named_times_to_keep <- bind_rows(filtered_times, filtered_years)
    all_named_entities <- bind_rows(hansard_named_events, hansard_named_times_to_keep)
    
    year <- read_csv("hansard_justnine_w_year.csv") %>%
      select(sentence_id, year)
    
    hansard_named_temporal_events <- left_join(all_named_entities, year, on = "sentence_id")
    
    hansard_named_temporal_events$entity <- tolower(hansard_named_temporal_events$entity)
    
    write_csv(hansard_named_temporal_events, "hansard_named_temporal_events.csv") }


interval <- 10
temporal_events_w_decade <- hansard_named_temporal_events %>%
  mutate(decade = year - year %% interval)


if(select_events == TRUE) {
  source("entities_list.R") }

if(select_triples == TRUE) {
  source("triples_list.R") }


decades <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900")

for (i in 1:length(decades)) {
  d <- decades[i]
  #d <- 1860
  
  decade_of_interest <- temporal_events_w_decade %>%
    filter(decade == d)
  
  # source("sub_entity_names.R")
  
  entity_count <- decade_of_interest %>%
    select(sentence_id, entity) %>%
    group_by(entity) %>%
    add_count(entity) %>%
    select(-entity) %>%
    ungroup()
  
  entites_w_event_count <- left_join(decade_of_interest, entity_count, on = "sentence_id")
  
  
  if(select_events == TRUE){
    event_regex <- paste0("events_for_", d)
    events_to_match <- get(event_regex)
    
    matched_events <- tibble()
    for(i in 1:length(events_to_match)) {
      event_to_match <- events_to_match[i]
      filtered_hansard <- entites_triples_w_event_count %>%
        filter(str_detect(entity, event_to_match))
      matched_events <- bind_rows(matched_events, filtered_hansard) } } else {
        matched_events <- entites_triples_w_event_count }
  
  
  hansard_triples <- read_csv("hansard_c19_triples_debate_text_03232021.csv") %>%
    rename(sentence_id = doc_id) %>%
    select(sentence_id, triple)
  
  hansard_events_triples <- left_join(entites_w_event_count, hansard_triples, on = "sentence_id")
  
  hansard_events_triples <- hansard_events_triples %>%
    drop_na(c("triple", "entity"))
  
  
  if(select_triples == TRUE) {
    triples_regex <- paste0("triples_for_", d)
    triples_to_match <- get(triples_regex)
    
    matched_triples <- tibble()
    for(i in 1:length(triples_to_match)) {
      triple_to_match <- triples_to_match[i]
      filtered_hansard <- hansard_events_triples %>%
        filter(str_detect(triple, triple_to_match))
      matched_triples <- bind_rows(matched_triples, filtered_hansard) } } else {
        matched_triples <- hansard_events_triples
        matched_triples <- bind_rows(matched_triples, matched_events) }
  
  
  triples_count_per_entity <- matched_triples %>%
    group_by(entity, triple) %>%
    add_count(entity, triple) %>%
    ungroup() %>%
    rename(triples_count = nn) %>%
    select(-c("decade", "n", "year", "sentence_id"))
  
  
  include_triples_count <- left_join(matched_triples, triples_count_per_entity, by = c("entity", "triple")) 
  
  include_triples_count$triples_count <- gsub("^", "(", include_triples_count$triples_count)
  include_triples_count$triples_count <- gsub("$", ")", include_triples_count$triples_count)
  
  include_triples_count$triple_and_count <- paste(include_triples_count$triple, include_triples_count$triples_count)
  
  viz_option_2 <- include_triples_count %>%
    distinct(triple_and_count, .keep_all = TRUE) %>%
    group_by(entity) %>%
    mutate(flattened = paste0(concatenate(triple_and_count, collapse = ": "))) %>%
    select(-triple, -sentence_id, -triples_count, -triple_and_count) %>%
    ungroup() 
  
  viz_option_2 <- viz_option_2 %>%
    distinct(decade, entity, n, flattened)
  
  n <- 3
  pat <- paste0('^([^:]+(?::[^:]+){',n-1,'}).*') 
  viz_option_2$flattened <- sub(pat, '\\1', viz_option_2$flattened)
  
  viz_option_2$flattened <- gsub(":", ";  ", viz_option_2$flattened)
  
  viz_option_2 <- viz_option_2 %>%
    rename(triple = flattened) %>%
    arrange(desc(n)) %>%
    slice(seq_len(15)) %>%
    select(-decade)  %>%
    rename(`event count` = n)
  
  # maybe include an empty column so this is aligned better 
  # hansard_named_temporal_events_triples <- hansard_named_temporal_events_triples[,c(1,2,4,3)] 
  
  viz_option_2[1:3] <- lapply(viz_option_2[1:3], str_to_title)
  
  # contents can be copied/pasted into a word doc
  # inside the word doc, the user can highlight the contents and go to table -> convert -> convert text to table 
  write.table(viz_option_2, paste0(file = "triples_table_", d, ".txt"), sep = ",", quote = FALSE, row.names = F)
  
  html <- viz_option_2 %>%
    gt() %>%
    tab_header(title = md(paste0("Grammatical Triples Co-Occuring with Named Temporal Events in ", d)),
               subtitle = md("Searching the 19th-Century Hansard Parliamentary Debates")) %>%
    tab_source_note(source_note = md("Description: Three triples per event chosen for exemplarity. Triples have been lemmatized and count is in parentheses.")) %>%
    cols_width(vars(triple) ~ px(800),
               vars(entity) ~ px(200)) %>%
    cols_align(align = "left") # do right for event, left for triple 
  
  gtsave(html, paste0("triples_table_", d, ".html"))
  
}
