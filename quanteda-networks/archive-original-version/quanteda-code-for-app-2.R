############
### Long Quanteda loop for making data files about expert vocabularies

# Version 2.0 uses one large master dictionary.

# this loop uses the quantedafy() function from wordcount_functions.R,
# which creates a Quanteda corpus, tokenizes it, and outputs a tidy
# list of debate/id/date locations where each vocabulary appears.

# Multiple passes through the "Nations" spreadsheet are important
# to capture the nuances of a few groups such as "Irish American" 
# (empire: British, geography: North American; resolves to nation: Irish)

# The spreadsheets are such that "dual" can be further annotated,
# e.g. "Lagos" is both British, French, and Kanem-Bornu.  
# However, the present code does not at present take advantage of any columns 
# in the spreadsheets past the fourth. 

# I would love to add a few more categories based on Quanteda's 
# own dictionaries -- for instance abstract/concrete, sentiments, 
# colors, parts of the body, action verbs.  The Quantedafy() 
# function should make this trivial.

stemmed <- TRUE

# change to match computer
library(quanteda)
quanteda_options(threads = 5, verbose = T)

setwd("~/projects/code")
source("wordcount-functions.R")
fulldict <- produce_dictionary(stemmed)
gen_classifier()

hansard <- read_csv("hansard_justnine_w_year.csv")
# st <- Sys.time()
quantedafy_hansard(hansard, stemmed) 
  # t1 <- st - Sys.time()
# st2 <- Sys.time()

## maybe i can just read in all csv files from here -- try that
# I should save this as R data 

library(tidytext)

load("~/projects/data/.RData")


# graph top entities per yr, makes semantic network
for(target in c(
  "debate", 
  "text")){
  
  classified_results <- load_classified_results(target)
  
for(cat1 in c("nations", 
  "concern", "office", "class", "trait", 
  "phenomena", "sentiment")){
    entities_per_yr(classified_results, cat1, target, gen_classifier) # makes bargraphs, tidygraph, and visualizes the tidygraph
  }
}

t2 <- st2 - Sys.time()


# generate semantic network of two entities at the same time 
for(target in c("text", "debate")){
  classified_results <- load_classified_results(target)
  
  for(cat1 in c("nations", 
                "cities", "concern")){
 for (cat2 in c(  "concern", "sentiment", "phenomena", "office", "class", "trait")) {
   gendescription2 <- paste0(cat2, target)   
   two_entities_network(classified_results, cat1, cat2, target, gen_classifier) # makes a 2-entity tidygraph and visualizes it
 }}
  }
