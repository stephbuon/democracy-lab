# notes from jo: https://docs.google.com/document/d/1pezD4soeb-Xy1OPAnX0_LLS_tsp30GVOYh9W-HwC0D4/edit

library(tidyverse)


clean_export <- function(out) {
  if ("events_mentioned_by_name_in_parliament" %in% ls(envir = .GlobalEnv)) { 
    out <- out %>%
      str_replace(entity, "american war", "american war of independence") 
    
    #endings <- c("war", "revolution", "railway", "exhibition", "code", "convention", "constitution", 
    #             "company", "boyne", "waterloo", "laws", "colony", "campaign", "inquisition", "articles", "company")
    # ends_with is not working for me 
    
    #out <- gsub("")
    
    #include_triples_count$triples_count <- gsub("$", ")", include_triples_count$triples_count)
    
    out$entity <- str_to_title(out$entity)
    
    if(interval == 100) {
      out <- out %>%
        rename(century = decade) } } }


ocr_handler <- function(decades, temporal_events_w_decade) {
  total <- tibble()
  
  for (i in 1:length(decades)) {
    d <- decades[i]
    
    decade_of_interest <- temporal_events_w_decade %>%
      filter(decade == d)
    
    if ("temporal_events_counts" %in% ls(envir = .GlobalEnv)) {
    patterns_to_match <- get("entity_value") }
    
    if ("events_for_ner_tables" %in% ls(env = .GlobalEnv)) {
      pattern_regex <- paste0("events_for_", d)
      patterns_to_match <- get(pattern_regex) }
  
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
    
    entity_count <- left_join(entity_count, decade_of_interest, on = "sentence_id") 
    
    total <- bind_rows(total, entity_count) }
  
  out <- left_join(total, entity_date_dictionary, on = "entity")
  
  out <- out %>%
    select(-year, -sentence_id) %>%
    distinct() 
  
  return(out)}


string_replace <- function(hansard_named_temporal_events, find, replace) {
  for(i in seq_along(find)) {
    hansard_named_temporal_events$entity <- str_replace_all(hansard_named_temporal_events$entity, find[[i]], replace[[i]]) }
  return(hansard_named_temporal_events)}

### ADD THIS TO STRING REPLACE: 
# for(i in seq_along(find)) {
#  hansard_named_temporal_events$entity <- str_replace_all(hansard_named_temporal_events$entity, regex(find[[i]], ignore_case = TRUE), regex(replace[[i]], ignore_case = TRUE)) }



import_data <- function(passed_path, data) {
  file_path <- file.path(passed_path)
  imported_data <- read_csv(file.path(file_path, data)) 
  return(imported_data) }




main <- function() {
  
  hansard_named_temporal_events <- import_data("/scratch/group/pract-txt-mine", "hansard_named_temporal_events.csv")
  
  find <- c("russian war", "great southern and western line", "great northern bill", "china war", "scottish code", "affghan war", "afghanistan war", "ashantee", "transvaal war", "kafir", "english constitution", "franco german war", "franco - german war", "german war", "british constitution")
  replace <- c("crimean war", "great southern and western railway company", "great northern railway", "chinese war", "scotch code", "afghan war", "afghan war", "ashanti", "boer war", "kaffir", "magna carta", "franco-german war", "franco-german war", "franco-german war", "magna carta") 
  
  hansard_named_temporal_events <- string_replace(hansard_named_temporal_events, find, replace)
  
  interval <- 10
  temporal_events_w_decade <- hansard_named_temporal_events %>%
    mutate(decade = year - year %% interval)
  
  decades <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900")
  
  out <- ocr_handler(decades, temporal_events_w_decade)
  
  out <- clean_export(out)
  
  return(out) }


write_csv(out, "entity_count.csv")
