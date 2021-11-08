library(tidyverse)

top_speakers <- read_csv("/scratch/group/pract-txt-mine/sbuongiorno/top_speakers_by_decade_improved_speaker_names.csv")



new_speakers <- read_csv("/scratch/group/pract-txt-mine/new_speakers.csv", col_names = F) %>%
  rename(sentence_id = X1,
         new_speaker = X2)


hansard <- read_csv("/scratch/group/pract-txt-mine/sbuongiorno/hansard_data/hansard_justnine_w_year.csv") 
# %>%
  #select(sentence_id, speaker)


out <- left_join(hansard, new_speakers, by = "sentence_id")

out <- out %>%
  count(speaker, new_speaker)

write_csv(out, "/scratch/group/pract-txt-mine/hansard_c19_improved_speaker_names_2.csv")
