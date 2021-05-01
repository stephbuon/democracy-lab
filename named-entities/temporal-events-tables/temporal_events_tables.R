# remember that "d" is currently set to a decade, not the loop 
# setwd("~/hansard_ner")
# is my event count correct? it is radically different 


select_events <- TRUE 
select_triples <- TRUE

library(tidyverse)
library(gt)
library(ngram)
library(mgsub)


if (file.exists("hansard_named_temporal_events_triples.csv")) {
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
    
    hansard_w_year <- read_csv("hansard_justnine_w_year.csv")
    hansard_triples <- read_csv("hansard_c19_triples_debate_text_03232021.csv") %>%
      rename(sentence_id = doc_id) %>%
      select(sentence_id, triple)
    
    year <- hansard_w_year %>%
      select(sentence_id, year)
    rm(hansard_w_year)
    
    hansard_named_events <- left_join(hansard_named_events, year, on = "sentence_id")
    hansard_named_times <- left_join(hansard_named_times_to_keep, year, on = "sentence_id")
    all_named_entities <- bind_rows(hansard_named_events, hansard_named_times)
    hansard_named_temporal_events_triples <- left_join(all_named_entities, hansard_triples, on = "sentence_id")
    
    hansard_named_temporal_events_triples <- hansard_named_temporal_events_triples %>%
      drop_na("triple")
    
    hansard_named_temporal_events_triples <- hansard_named_temporal_events_triples[,c(1,2,4,3)] 
    
    hansard_named_temporal_events_triples[2:3] <- lapply(hansard_named_temporal_events_triples[2:3], tolower)
    
    write_csv(hansard_named_temporal_events_triples, "hansard_named_temporal_events_triples.csv") }


interval <- 10
hansard_named_temporal_events_triples <- hansard_named_temporal_events_triples %>%
  mutate(decade = year - year %% interval)


if(select_events == TRUE) {
  source(events_list.R) }

if(select_triples == TRUE) {
  source(triples_list.R) }


decades <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900")

for (i in 1:length(decades)) {
  
  #d <- decades[i]
  d <- 1860
  
  decade_of_interest <- hansard_named_temporal_events_triples %>%
    filter(decade == d)
  
  decade_of_interest$entity <- mgsub(decade_of_interest$entity,
                                     c("[[:punct:]]", "the year ", "the ", "end of ", "january ", "february ", "march ", "april", "may ", "june ", "july ","august ", "september ", "october ", "november ", "december "), 
                                     c("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""), 
                                     ignore.case = TRUE)
  
  decade_of_interest$entity <- gsub("these contagious diseases acts", "contagious diseases acts", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("this act of 1869", "act of 1869", decade_of_interest$entity) # this could be swaped out with contagious disease acts
  
  decade_of_interest$entity <- gsub("service of protestant chaplains on", "service of protestant chaplains", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("zulu war of", "zulu war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("no zulu war", "zulu war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("this zulu war", "zulu war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("a zulu war", "zulu war", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("crimean war a commission", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean war i", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the crimean war", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("a crimean war", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the crimean war two", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the crimean war the turks", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the crimean war—eleven years and a half", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean war been reduced to", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean war turks", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean wareleven and a half", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean warlarge reductions", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("another crimean war", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean war 198 millions of debt", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean war fund", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean war two", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean wareleven and a half", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("war malt duty of crimean war", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean war about", "crimean war", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("crofters acts", "crofters act", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("american warthe", "american war", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("year ", "", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("years ", "", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("year ", "", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the year ", "", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the years ", "", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the afghan war", "afghan war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("this afghan war", "afghan war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("affghan war", "afghan war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the affghan war", "afghan war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("this affghan war", "afghan war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("afghan war liberal party", "afghan war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("afghan war as", "afghan war", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the indian mutiny war", "indian mutiny", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the indian mutiny", "indian mutiny", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("indian mutiny war", "indian mutiny", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the lent", "lent", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("lent assizes", "lent", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the yorkshire lent assizes", "lent", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the lent assizes", "lent", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("yorkshire lent", "lent", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the french revolution", "french revolution", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the then french revolution", "french revolution", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the revolution of france", "french revolution", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("revolution of france", "french revolution", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("then french revolution", "french revolution", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the french war", "french war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the french war against", "french war", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the vietriples_counta conferences", "the vietriples_counta conference", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the conference at vietriples_counta", "the vietriples_counta conference", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the american war", "american war", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("st. domingo)", "st. domingo", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("st domingo", "st. domingo", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("st domingo and guadaloupe", "st. domingo and guadaloupe", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the convention of cintra", "convention of cintra", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the convention of cintra", "convention of cintra", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the revolution", "revolution", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("this revolution", "revolution", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("revolutionthat", "revolution", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the spanish revolution", "spanish revolution", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the national convention", "national convention", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("a national convention", "national convention", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("the vietriples_counta conference", "vietriples_counta conference", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("revolution of 1688down", "revolution of 1688", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("revolution of 1688it", "revolution of 1688", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the revolution of 1688", "revolution of 1688", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("revolution of 1688parliament", "revolution of 1688", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("exhibition of 1851", "great exhibition", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("contagious diseases act", "contagious diseases acts", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("contagious diseases actss", "contagious diseases acts", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("clause of land act", "land act", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("land acts", "land act", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("a boer war", "boer war", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub(" 1881", "1881", decade_of_interest$entity)
  
  decade_of_interest$entity <- gsub("this amendment", "amendment", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("paper an amendment", "amendment", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("this amendment government", "amendment", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("amendment of hon", "amendment", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("amendment acts", "amendment", decade_of_interest$entity)
  
  entity_count <- decade_of_interest %>%
    group_by(entity) %>%
    add_count(entity) %>%
    ungroup()
  
  entites_triples_w_event_count <- left_join(decade_of_interest, entity_count)
  
  ##############################################
  # test : see which triples are the same
  # I don't think this is working
  
  #test <- counted %>%
  #  group_by(event, triple) %>%
  #  distinct(.keep_all = TRUE) %>%
  #  group_by(event) %>%
  #  filter(n() == 1)
  #  ungroup()
  
  #clean_counted <- counted %>% # is this if I want the triple count to show up? 
  #  group_by(triple) %>%
  #  add_count(triple) %>%
  #filter(triples_count >= 2) %>%
  #  ungroup()
  
  
  if(select_events == TRUE){
    event_regex <- paste0("events_for_", d)
    events_to_match <- get(event_regex)
    
    matched_events <- tibble()
    for(i in 1:length(events_to_match)) {
      event_to_match <- events_to_match[i]
      filtered_hansard <- entites_triples_w_event_count %>% # change from counted to clean_counted if I want triples said 2 or more times  
        filter(str_detect(entity, event_to_match))
      matched_events <- bind_rows(matched_events, filtered_hansard) } } else {
        matched_events <- entites_triples_w_event_count }
  
  
  if(select_triples == TRUE) {
    triples_regex <- paste0("triples_for_", d)
    triples_to_match <- get(triples_regex)
    
    matched_triples <- tibble()
    for(i in 1:length(triples_to_match)) {
      triple_to_match <- triples_to_match[i]
      filtered_hansard <- matched_events %>%
        filter(str_detect(triple, triple_to_match))
      matched_triples <- bind_rows(matched_triples, filtered_hansard) } } else {
        matched_triples <- entites_triples_w_event_count
        matched_triples <- bind_rows(matched_triples, matched_events) }
  
  
  triples_count_per_entity <- entites_triples_w_event_count %>%
    group_by(entity, triple) %>%
    add_count(entity, triple) %>%
    ungroup() %>%
    rename(triples_count = nn) %>%
    select(-c("decade", "n", "year", "sentence_id"))
  
  
  include_triples_count <- left_join(matched_triples, triples_count_per_entity, by = c("entity", "triple")) # optional for including triples count 
  
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
    rename(triple = flattened)
  
  option_2 <- viz_option_2 %>%
    arrange(desc(n)) %>%
    slice(seq_len(15)) %>%
    select(-decade)  %>%
    rename(`event count` = n)
  
  # maybe include an empty column so this is aligned better 
  
  # do this for entity and triple -- are the columns right? 
  option_2[1:3] <- lapply(option_2[1:3], str_to_title)
  
  # contents can be copied/pasted into a word doc
  # inside the word doc, the user can highlight the contents and go to table -> convert -> convert text to table 
  write.table(option_2, paste0(file = "triples_table_", d, ".txt"), sep = ",", quote = FALSE, row.names = F)
  
  html <- option_2 %>%
    gt() %>%
    tab_header(title = md(paste0("Lemmatized Triples Co-Occuring with Temporal Events in ", d)),
               subtitle = md("Searching the Hansard Parliamentary Debates")) %>%
    tab_source_note(source_note = md("Description: Three triples per event chosen for exemplarity. Triple count is in parentheses.")) %>%
    cols_width(vars(triple) ~ px(800),
               #vars(`temporal event`) ~ px(200),
               #vars(time) ~ px(200),
               vars(entity) ~ px(200)) %>% #,
    #vars(decade) ~ px(100)) %>%
    cols_align(align = "left") # do right for event, left for triple 
  
  gtsave(html, paste0("triples_table_", d, ".html"))
  
  
}


# IDK: 


# test <- str_replace(test, ".*(1.*)$", "\\1")

#clean_decade_count$event <- gsub(".*1", "", clean_decade_count$event)
#clean_decade_count$event <- gsub(".*[[:digit:]]", "", clean_decade_count$event)
