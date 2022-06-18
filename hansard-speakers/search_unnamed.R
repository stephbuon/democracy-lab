library(tidyverse)
library(lubridate)
library(data.table)

hansard <- fread("~/data/hansard_c19_improved_speaker_names_2.csv") %>%
  select(sentence_id, speaker, new_speaker, speechdate)

### Search for people 

search <- hansard %>%
  mutate(n = str_count(new_speaker)) %>%
  filter(n < 1)

search <- search %>%
  select(-sentence_id, -speechdate) %>%
  distinct()

ignore <- c("mr\\.", "sir ", "chancellor", "lord ", "earl ", "duke ", 'bishop', "colonel", "captain", "marquess", 
            "secretary", "viscount", "general", "admiral", "the ", "baron ", "^mr ", "Dr\\. ", "major", "capt\\.",
            "col\\. ")

ignore <- paste0(ignore, collapse = "|")

search <- search %>%
  filter(!str_detect(speaker, regex(ignore, ignore_case = T)))

#### Find dates 

hansard <- hansard %>%
  mutate(year = year(speechdate)) %>%
  select(-speechdate, -sentence_id)

hansard$speaker <- tolower(hansard$speaker)

hansard <- distinct(hansard)
  
find_dates <- hansard %>%
  filter(str_detect(speaker, regex("An Hon. and Gallant Member", ignore_case = T)))

