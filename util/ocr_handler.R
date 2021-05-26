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


patterns_to_match <- c("the")

test <- read_csv("hansard_justnine_w_year.csv")

test <- test %>%
  sample_n(20)

keyword_count <- tibble()
for(i in 1:length(patterns_to_match)) {
  pattern <- patterns_to_match[i]
  
  matches <- test %>%
    filter(str_detect(text, regex(pattern, ignore_case = TRUE)))
  
  matches$occurances <- str_count(matches$text, regex(pattern, ignore_case = TRUE))
  matches$text <- paste0(pattern)
  print("this is matches")
  print(matches)
  keyword_count <- bind_rows(keyword_count, matches) }












detect_with_ocr_handler <- function(periods, temporal_events_w_period, date_dictionary) {
  total <- tibble()
  
  for (i in 1:length(periods)) {
    d <- periods[i]
    
    period_of_interest <- temporal_events_w_period %>%
      filter(period == d)
    
    keyword_date_dictionary <- read_csv(date_dictionary)
    colnames(keyword_date_dictionary)[1] <- "keyword" 
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



subset_data <- function(dataframe, subset_csv) {
  dataframe <- read_entire_dataset(dataframe)
  keywords_value <- read_dictionary(subset_csv)
  
  hansard_named_temporal_events <- tibble()
  for(i in 1:length(keywords_value)) {
    keyword <- keywords_value[i]
    
    filtered_hansard <- dataframe %>%
      filter(str_detect(text, regex(keyword, ignore_case = TRUE))) %>%
      rename(keyword = text)
    
    hansard_named_temporal_events <- bind_rows(hansard_named_temporal_events, filtered_hansard) } 
  return(hansard_named_temporal_events) }


read_entire_dataset <- function(name) {
  boolean <- str_detect(name, ".csv|.tsv") 
  if(boolean == TRUE) {
    name <- read_csv(name) } else { }
  return(name) }



read_dictionary <- function(name) { # this should be properly handled 
  boolean <- str_detect(name, ".csv|.tsv")
  if(boolean == TRUE) {
    name <- read_csv(name) }
  
  boolean_2 <- is.data.frame(name)
  if(boolean_2 == TRUE) {
    name <- name[,1] } else { }
  return(name) }




ocr_handler <- function(dataframe, date_dictionary, subset_csv = 0, find = 0, replace = 0) { # rename from csv to something more inclusive 
  print("Using OCR handler to search for sentences containing a keyword.")
  
  print("Subsetting data.") # works
  if(is.character(subset_csv)) {
    print("registered character")
    hansard_named_temporal_events <- subset_data(dataframe, subset_csv) }
  
  
  print("Substituting strings.") # works
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
  total <- detect_with_ocr_handler(periods, temporal_events_w_period, date_dictionary)
  
  return(total) }

  print("Counting keywords by period.")
  counted_entities <- count_entities(total)
  
  print(counted_entities)
  
  print("Cleaning counted  keywords for export.")
  export <- clean_export(counted_entities)
  
  #print("Writing entities count to csv.")
  #write_csv(export, paste0("entities_count", format(Sys.time(), "_%Y%m%d"), ".csv")) 
  
  return(counted_entities) }


a <- ocr_handler(dataframe = "hansard_justnine_w_year.csv", date_dictionary = "entity_date_dictionary.csv", 
                 subset_csv = "potato famine", find = "potato famine", replace = "potato_famine")


# change subset_cv to subset_by 

# make this so can handle just strings, too 
# x <- data.frame("SN" = c("american war", "potato famine"))

