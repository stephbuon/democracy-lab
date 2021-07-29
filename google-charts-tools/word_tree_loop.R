## Please note that by default the googleVis plot command
## will open a browser window and requires Internet
## connection to display the visualisation.

library(tidyverse)
library(googleVis)
library(tidytext)

#triples <- read_csv("~/posextractr/c19_hansard_debate_text_triples_07232021.csv")

#triples_out <- triples %>%
#  filter(str_detect(triple, "landlord-have-power"))

#decade <- 10

#triples_out <- triples_out %>%
#  mutate(decade = year - year %% decade, text)

triples <- read_csv("~/Downloads/landlord_have_power.csv")

phrase_lengths <- c(10, 25) 
regexes <- c("^landlord", "landlord$", "^power", "power$")
decades <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900", "1910")

for (a in 1:length(phrase_lengths)) {
  p <- phrase_lengths[a]
  
  for (i in 1:length(decades)) {
    d <- decades[i]
    
    filtered <- triples %>%
      filter(decade == d) %>%
      select(text)
    
    filtered <- filtered %>%
      unnest_tokens(text, text, token = "ngrams", n = p)
    
    for (b in 1:length(regexes)) {
      r <- regexes[b]
      
      filtered_2 <- filtered %>%
        filter(str_detect(text, r))
      print(filtered_2)
      
      wt2 <- gvisWordTree(filtered_2, 
                          textvar = "text",
                          options = list(fontName = "Times-Roman",
                                         maxFontSize = 10,
                                         wordtree = "{word: 'power'}",
                                         width = 700)) 
      
      if (NROW(filtered_2)!=0) {
        plot(wt2) } 
      
      wt2 <- gvisWordTree(filtered_2, 
                          textvar = "text",
                          options = list(fontName = "Times-Roman",
                                         maxFontSize = 10,
                                         wordtree = "{word: 'landlord'}",
                                         width = 700)) 
      
      if (NROW(filtered_2)!=0) {
        plot(wt2) } } } }




