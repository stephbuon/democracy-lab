# notes from jo: https://docs.google.com/document/d/1pezD4soeb-Xy1OPAnX0_LLS_tsp30GVOYh9W-HwC0D4/edit

# add this other type of data input for the handler: https://docs.google.com/spreadsheets/d/1vFiKxCPdwp2HRsh_zFrLzF4f8ZBbsGEA4Wjh9vMWeL0/edit#gid=0
# so change how the str_detect function works here? 

library(tidyverse)


clean_export <- function(out) {
  if ("events_mentioned_by_name_in_parliament" %in% ls(envir = .GlobalEnv)) { 
    out <- out %>%
      str_replace(keyword, "american war", "american war of independence") 
    out$keyword <- str_to_title(out$keyword) } }


count_entities <- function(total) {
  counted_entities <- total %>%
    group_by(keyword, period, occurances) %>%
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
    
    keyword_date_dictionary <- read_csv(keywords_csv)
    colnames(subset_csv)[1] <- "keyword" 
    patterns_to_match <- keyword_date_dictionary$keyword
        
    keyword_count <- tibble()
    for(i in 1:length(patterns_to_match)) {
      pattern <- patterns_to_match[i]
      
      matches <- period_of_interest %>%
        filter(str_detect(keyword, regex(pattern, ignore_case = TRUE)))
      
      matches$occurances <- str_count(matches$keyword, regex(pattern, ignore_case = TRUE))
      matches$keyword <- paste0(pattern)
      keyword_count <- bind_rows(keyword_count, matches) }
    
    period_of_interest <- period_of_interest %>%
      select(sentence_id, year, period)
    
    keyword_count <- left_join(keyword_count, period_of_interest, on = "sentence_id")
    
    total <- bind_rows(total, keyword_count) }
  
  total <- left_join(total, keyword_date_dictionary, on = "keyword")
  
  total <- total %>%
    select(sentence_id, keyword, period, scholar_assigned_date, occurances) %>%
    distinct() %>%
    select(-sentence_id)
  
  total$keyword <- str_to_title(total$keyword)
  return(total) }


string_replace <- function(hansard_named_temporal_events, find, replace) {
  for(i in seq_along(find)) {
    hansard_named_temporal_events$keyword <- str_replace_all(hansard_named_temporal_events$keyword, regex(find[[i]], ignore_case = TRUE), regex(replace[[i]], ignore_case = TRUE)) }
  return(hansard_named_temporal_events) }



subset_data <- function(dataframe, keywords_csv) {
  dataframe <- read_csv(dataframe) # have a handler -- whether to read csv or use existing variable
  subset_csv <- read_csv(subset_csv)
  
  colnames(subset_csv)[1] <- "keyword" # just added 
  
  keywords_value <- subset_csv$keyword
  
  hansard_named_temporal_events <- tibble()
  for(i in 1:length(keywords_value)) {
    keyword <- keywords_value[i]
    
    filtered_hansard <- dataframe %>%
      filter(str_detect(text, regex(keyword, ignore_case = TRUE))) %>%
      rename(keyword = text)
    
    hansard_named_temporal_events <- bind_rows(hansard_named_temporal_events, filtered_hansard) } 
  return(hansard_named_temporal_events) }


format_data <- function(data) {
  out <- data %>%
  str_detect(data, ".csv|.tsv") # add something that indicates first column 
  # if out is not none: do code 
  # else, treat like variable 
  # either way -- have rename column in here 
  
}


ocr_handler <- function(dataframe, keywords_csv, subset_csv = 0, find = 0, replace = 0) {
  print("Searching for sentences that contain a keyword.")
  # if subset csv has an argument: 
  hansard_named_temporal_events <- subset_data(dataframe, subset_csv) 
  
  print("Substituting strings.")
  if(is.character(find) & is.character(replace)) {
    hansard_named_temporal_events <- string_replace(hansard_named_temporal_events, find, replace) }
  
  interval <- 10
  temporal_events_w_period <- hansard_named_temporal_events %>%
    mutate(period = year - year %% interval)
  
  if(interval == 10) {
    periods <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900") }
  if(interval == 1) {
    periods <- 1800:1910 }  # (I should not get a different summarization between these, check and then delete unecessary code!)
  
  print("Finding occurances of keywords with ocr handler.")
  total <- detect_with_ocr_handler(periods, temporal_events_w_period, keywords_csv)
  
  print("Counting keywords by period.")
  counted_entities <- count_entities(total)
  
  export <- clean_export(counted_entities)
  
  print("Writing entities count to csv.")
  write_csv(export, paste0("entities_count", format(Sys.time(), "_%Y%m%d"), ".csv")) 
  
  return(export) }

test <- ocr_handler("hansard_justnine_w_year.csv", "entity_date_dictionary.csv")

find <- c("russian war", "great southern and western line", "great northern bill", "china war", "scottish code", "affghan war", "afghanistan war", "ashantee", "transvaal war", "kafir", "english constitution", "franco german war", "franco - german war", "german war", "british constitution")
replace <- c("crimean war", "great southern and western railway company", "great northern railway", "chinese war", "scotch code", "afghan war", "afghan war", "ashanti", "boer war", "kaffir", "magna carta", "franco-german war", "franco-german war", "franco-german war", "magna carta") 

