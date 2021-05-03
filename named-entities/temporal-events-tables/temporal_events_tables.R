 # setwd("~/hansard_ner")


# I haven't tested if all the FALSE combos work yet 
select_events <- TRUE
select_triples <- TRUE
ocr_handling <- TRUE
fact_checking <- FALSE 

library(tidyverse)
library(gt)
library(ngram)


if (file.exists("hansard_named_temporal_events.csv")) {
  hansard_named_temporal_events <- read_csv("hansard_named_temporal_events.csv") } else {
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
  source("events_list.R") }

if(select_triples == TRUE) {
  source("triples_list.R") }


decades <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900")

for (i in 1:length(decades)) {
  d <- decades[i]
  
  decade_of_interest <- temporal_events_w_decade %>%
    filter(decade == d)
  
  if(ocr_handling == TRUE) {
    pattern_regex <- paste0("events_for_", d)
    patterns_to_match <- get(pattern_regex)
    
    entity_count <- tibble()
    for(i in 1:length(patterns_to_match)) {
      pattern <- patterns_to_match[i]
      matches <- decade_of_interest %>%
        filter(str_detect(entity, regex(pattern, ignore_case = TRUE)))
      
      matches_count <- matches %>%
        select(-year, -decade) %>%
        add_tally() %>%
        mutate(entity = pattern)
      
      entity_count <- bind_rows(entity_count, matches_count) }
    
    decade_of_interest <- decade_of_interest %>%
      select(sentence_id, year, decade)
    
    entites_w_event_count <- left_join(entity_count, decade_of_interest, on = "sentence_id")
  } else {
    entity_count <- decade_of_interest %>%
      select(sentence_id, entity) %>%
      group_by(entity) %>% 
      add_count(entity) %>%
      select(-entity) %>%
      ungroup() 
    
    entites_w_event_count <- left_join(decade_of_interest, entity_count, on = "sentence_id") }
  
  
  if(select_events == TRUE){
    source("regex_list.R")
    regex <- paste0("regex_for_", d)
    regexes_to_match <- get(regex)
    
    matched_events <- tibble()
    for(i in 1:length(regexes_to_match)) {
      regex_to_matches <- regexes_to_match[i]
      filtered_hansard <- entites_w_event_count %>%
        filter(str_detect(entity, regex_to_matches))
      matched_events <- bind_rows(matched_events, filtered_hansard) } } else {
        matched_events <- entites_w_event_count }
  
  
  if(!exists("hansard_triples")) {
    hansard_triples <- read_csv("hansard_c19_triples_debate_text_03232021.csv") %>%
      rename(sentence_id = doc_id) %>%
      select(sentence_id, triple) }
  
  if(fact_checking == TRUE) {
    fact_checking_triples <- read_csv("hansard_c19_triples_debate_text_03232021.csv") %>%
      rename(sentence_id = doc_id) %>%
      select(sentence_id, triple, text) 
    
    fact_checking_triples <- left_join(matched_events, fact_checking_triples, on = "sentence_id")
    fact_checking_triples <- fact_checking_triples %>%
      drop_na(c("triple", "entity"))
    
    fact_checking_triples <- distinct(fact_checking_triples) 
    write_csv(fact_checking_triples, paste0("fact_checking_triples_", d, ".csv")) }
  
  
  hansard_events_triples <- left_join(matched_events, hansard_triples, on = "sentence_id")
  
  hansard_events_triples <- hansard_events_triples %>%
    drop_na(c("triple", "entity"))
  
  hansard_events_triples <- distinct(hansard_events_triples) # confusing -- come back to -- this might be the first instance of the problem, but check 
  
  
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
        matched_triples <- bind_rows(matched_triples, matched_events) } # is this right? 
  
  matched_triples <- distinct(matched_triples) # confusing -- come back to 
  
  
  if(ocr_handling == TRUE) { 
    
    regex <- paste0("regex_for_", d)
    regexes_to_match <- get(regex)
    
    pattern_regex_2 <- paste0("triples_for_", d)
    patterns_to_match_2 <- get(pattern_regex_2)
    
    triples_count_per_entity <- tibble()
    for(i in 1:length(regexes_to_match)) {
      regex_to_match <- regexes_to_match[i]
      event <- matched_triples %>%
        filter(str_detect(entity, regex_to_match))
      
      for(i in 1:length(patterns_to_match_2)) {
        pattern_2 <- patterns_to_match_2[i]
        matches <- event %>%
          filter(str_detect(triple, regex(pattern_2, ignore_case = TRUE)))
        
        matches_count <- matches %>%
          add_tally() %>%
          rename(triples_count = nn) %>%
          select(-c("decade", "n", "year", "sentence_id")) %>%
          mutate(triple = pattern_2) 
        
        triples_count_per_entity <- bind_rows(triples_count_per_entity, matches_count) } }
  } else {
    triples_count_per_entity <- matched_triples %>% 
      group_by(entity, triple) %>%
      add_count(entity, triple) %>%
      ungroup() %>%
      rename(triples_count = nn) %>%
      select(-c("decade", "n", "year", "sentence_id")) }
  
  
  triples_count_per_entity <- distinct(triples_count_per_entity) # confusing -- come back to 
  
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
  
