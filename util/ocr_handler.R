# notes from jo: https://docs.google.com/document/d/1pezD4soeb-Xy1OPAnX0_LLS_tsp30GVOYh9W-HwC0D4/edit

library(tidyverse)


clean_export <- function(out) {
  if ("events_mentioned_by_name_in_parliament" %in% ls(envir = .GlobalEnv)) { 
    out <- out %>%
      str_replace(entity, "american war", "american war of independence") 
    out$entity <- str_to_title(out$entity) } }


count_entities <- function(total) {
  print("Counting keywords by period")
  counted_entities <- total %>%
    group_by(entity, period, occurances) %>%
    add_count() %>%
    select(-occurances) %>%
    ungroup()
  return(counted_entities) }


detect_with_ocr_handler <- function(periods, temporal_events_w_period) {
  total <- tibble()
  
  for (i in 1:length(periods)) {
    d <- periods[i]
    
    period_of_interest <- temporal_events_w_period %>%
      filter(period == d)
    
    patterns_to_match <- entity_date_dictionary$entity
    
    entity_count <- tibble()
    for(i in 1:length(patterns_to_match)) {
      pattern <- patterns_to_match[i]
      
      matches <- period_of_interest %>%
        filter(str_detect(entity, regex(pattern, ignore_case = TRUE)))
      
      matches$occurances <- str_count(matches$entity, regex(pattern, ignore_case = TRUE))
      matches$entity <- paste0(pattern)
      entity_count <- bind_rows(entity_count, matches) }

    period_of_interest <- period_of_interest %>%
      select(sentence_id, year, period)

    entity_count <- left_join(entity_count, period_of_interest, on = "sentence_id")

    total <- bind_rows(total, entity_count) }

  total <- left_join(total, entity_date_dictionary, on = "entity")

  total <- total %>%
    select(sentence_id, entity, period, scholar_assigned_date, occurances) %>%
    distinct() %>%
    select(-sentence_id)

  total$entity <- str_to_title(total$entity)
  return(total) }


string_replace <- function(hansard_named_temporal_events, find, replace) {
  for(i in seq_along(find)) {
    hansard_named_temporal_events$entity <- str_replace_all(hansard_named_temporal_events$entity, regex(find[[i]], ignore_case = TRUE), regex(replace[[i]], ignore_case = TRUE)) }
  return(hansard_named_temporal_events)}


subset_data <- function(dataframe, keywords_csv) {
  
  keywords_csv <- read_csv(keywords_csv) 
  
  hansard_c19 <- read_csv("~/hansard_justnine_w_year.csv") %>%
    select(sentence_id, text, year)
  
  keywords_value <- keywords_csv$entity # change instances of entity to keyword 
  
  hansard_named_temporal_events <- tibble()
  for(i in 1:length(keywords_value)) {
    keyword <- keywords_value[i]
    
    filtered_hansard <- hansard_c19 %>%
      filter(str_detect(text, regex(keyword, ignore_case = TRUE))) %>%
      rename(entity = text)
    
    hansard_named_temporal_events <- bind_rows(hansard_named_temporal_events, filtered_hansard) } 
  return(hansard_named_temporal_events) }


ocr_handler <- function(dataframe, keywords_csv, find = 0, replace = 0) {
  
  hansard_named_temporal_events <- subset_data(dataframe, keywords_csv)
  
  if(is.character(find) & is.character(replace)) {
    hansard_named_temporal_events <- string_replace(hansard_named_temporal_events, find, replace) }
  
  interval <- 10
  temporal_events_w_period <- hansard_named_temporal_events %>%
    mutate(period = year - year %% interval)
  
  if(interval == 10) {
    periods <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900") }
  if(interval == 1) {
    periods <- 1800:1910 }  # (I should not get a different summarization between these, check and then delete unecessary code!)
  
  total <- detect_with_ocr_handler(periods, temporal_events_w_period)
  
  counted_entities <- count_entities(total)
  
  export <- clean_export(counted_entities)
  
  write_csv(export, paste0(format(Sys.time(), "_%Y%m%d"), ".csv")) 
  
  return(export) }

test <- ocr_handler(a, b)

find <- c("russian war", "great southern and western line", "great northern bill", "china war", "scottish code", "affghan war", "afghanistan war", "ashantee", "transvaal war", "kafir", "english constitution", "franco german war", "franco - german war", "german war", "british constitution")
replace <- c("crimean war", "great southern and western railway company", "great northern railway", "chinese war", "scotch code", "afghan war", "afghan war", "ashanti", "boer war", "kaffir", "magna carta", "franco-german war", "franco-german war", "franco-german war", "magna carta") 


