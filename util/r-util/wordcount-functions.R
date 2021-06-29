######## Wordcount Functions
# This document contains the following functions :
#
# SETUP FUNCTIONS
### setup_parallel()

# LOADING DATA
### loadterminology(termcsv)
### readhansard()
### loadfrequencies() -- frequency of individual words by debate, speech, and sentence
### hansardwordcounts() -- words per year, for computing proportions over time
### loadsignificantwords(hansard) -- a list of words that appear at least once out of every 20000 words
# as Ben Blatt explains in his book on statistics and novelists,
# there are various measures of word significance, but a good 
# arbitrary cut-off is words that appear at least 1/20,000 words

# FORMATTING FUNCTIONS
### clean_list(c) -- remove redundancies within a list of keywords, organize from longest to shortest
### unnest_parallel(sample,numwords, parallel) -- tokenize a sample into numwords-long ngrams
### unnest_sentences(hansard) -- unnests sentences (better than tidytext app does)
### number_ticks(n) -- format graphics 
### reorder_within(x, y, group) -- reorder x graphics by y within facet-wrap by group
### facet_nested(x ~ y + hierarchy) -- facet_grid such that the strips give a nested hierarchy of terms, for instance weeknumber ~ year + decade

# BASIC WORDCOUNT TOOLS
### wordcount(string)
### tidyhansard(hansard, parallel)
### produce_dictionary()
### quantedafy_hansard() 
### entities_per_yr(gendescription, target)

# PAIRS/NETWORK
### toolongpairs(toolong) -- go sentence-by-sentence to extract pairs
### findpairs(df1) - finds pairs in df1 as a chunk (will break if df1 is too big) 
  ## this could be refined with a T/F option for filtering pairs that span categories
### generate_nodes(edges) -- given a list of edges, generate a list of nodes
### generate_tidygraph(edges) -- given a list of edges, visualize and save a tidygraph

# TABLE-MAKING FUNCTIONS
### printterms(term, n)

# DIACHRONIC FUNCTIONS
### find_term(term1, hansard, parallel) -- counts appearances/yr, calculates proportion
### find_term_list(term_list, hansard, parallel) -- returns database of word counts/proportions/yr for a term list
### find_term_list_parallel(term_list, hansard) -- same as above but with a foreach loop
### read_term_list(term_list) -- reads previously generated files
### tfidf_associations_by_year(list1, firstyear, lastyear, level, parallel)
### tfidf_comparison_by_year(list1, firstyear, lastyear, level, parallel)
### loglike_associations_by_year()

# COLLOCATE FUNCTIONS
### find_collocates(term1, firstyear, lastyear, level) -- finds collocates at level
### find_associations(test_terms, firstyear, lastyear, level, parallel) -- applies find collocates to a list
### tfidf_associations(list1, firstyear, lastyear, level, parallel) -- ranks collocates by uniqueness to each term in list1 against all other terms in the corpus
### tfidf_comparison(list1, firstyear, lastyear, level, parallel) -- ranks collocates by uniqueness to each term in list1 against all other terms in the list
### tidy_logl(df, group_key, token_key, threshold = 3, wcount) 
### loglike_associations()
### loglike_comparison()

# IMPORTANT NOTES
# tfidf_associations returns the words statistically distinct for each word in list1:
# that is, collocates that are likely to *only* show up with those words in contrast
# with any other sentence/speech/debate in Hansard.  That is, if list1 contains
# Ireland, the results of tfidf_assocations will tell us about collocates for 
# Ireland that almost never appeared when parliament was discussing other subjects
# (for instance India or England or poverty in general terms without Ireland being
# explicitly mentioned)

# tfidf_comparison instead only does a statistical comparison for collocates
# between the items of list1.  Thus if list1 contains potato and famine,
# the results of tfidf_comparison will tell us how potatoes were spoken about
# when famine wasn't mentioned, and how famine was spoken about when potatoes weren't
# mentioned.  

# CLEANUP
### entity_consolidate_heraldic(text2)
### clean_nations(nation_debates)

# OLD
### findcontext(term1, numwords)
###term_context <- function(term1, hansard, level, parallel) 


# require(dplyr)
# require(tidyr)
# require(tidytext)
# require(data.table)
# require(dplyr)
# require(tidyr)
# require(tidytext)
# require(gridExtra)
# require(grid)
# require(lubridate)
# require(grid)
# require(gtable)
# require(readr)

# if(parallel==TRUE){
#   require(doParallel)
#   require(foreach)
#   require(itertools)
#   
# }

library(tidyverse)

hansardwordcounts <- function() {
  print("calling function HANSARDWORDCOUNTS")
  setwd("~/projects/data")
  all_hansard_wordcounts_by_year <- read.csv2("all_hansard_wordcounts_by_year.csv")
  print("the variable all_hansard_wordcounts_by_year has been created.")
  return(all_hansard_wordcounts_by_year)
}

loadfrequencies <- function(level) {
  
  print("calling function LOADFREQUENCIES")
  setwd("~/projects/data")
  
  if(level == "debate"){
   
      if(exists("debatecounts")){
        test <- (abs(max(debatecounts$year)- min(debatecounts$year) - (lastyear - firstyear)) <10)
      }else{test <- FALSE} 
      if(test == FALSE){
        print(paste0("counting the appearances of keywords per ", level))
        debatecounts <- hansard %>% filter(year > firstyear) %>%
          filter(year < lastyear) %>%
          unnest_tokens(output = word, input = text) %>%
          group_by(year, debate_id, word) %>%
          summarize(wordsperdebate = n())
        assign("debatecounts", debatecounts, envir = .GlobalEnv)}else(print("debatecounts for the required years already exists."))
    }
  
  if(level == "speech"){
       if(exists("speechcounts")){
        test <- (abs(max(speechcounts$year)- min(speechcounts$year) - (lastyear - firstyear)) <10)
      }else{test <- FALSE} 
      
      if(test == FALSE){
        print(paste0("counting the appearances of keywords per ", level))
        
        speechcounts <-hansard %>% filter(year > firstyear) %>%
          filter(year < lastyear) %>%
          unnest_tokens(output = word, input = text) %>%
          group_by(year, speech_id, word) %>%
          summarize(wordsperspeech = n())
        
        assign("speechcounts", speechcounts, envir = .GlobalEnv)}else(print("speechcounts for the required years already exists."))
    }
  
  if(level == "sentence"){
    
  
      if(exists("sentencecounts")){
        test <- (abs(max(sentencecounts$year)- min(sentencecounts$year) - (lastyear - firstyear)) <10)
      }else{test <- FALSE}
      if(test == FALSE){
        print("loading sentencecounts")
        print(paste0("counting the appearances of keywords per ", level))
        
        sentencecounts <-hansard %>% filter(year > firstyear) %>%
          filter(year < lastyear) %>%
          unnest_tokens(output = word, input = text) %>%
          group_by(year, sentence_id, word) %>%
          summarize(wordspersentence = n())  
        assign("sentencecounts", sentencecounts, envir = .GlobalEnv)
      }else{(print("sentencecounts for the required years already exists."))
      }
      
    }
}


readhansard <- function() {
  print("calling function READHANSARD")
  setwd("~/projects/data")
  
  print("reading in hansard...")
  
  hansard <-
    # readr::read_tsv("hansard_20191029_10m.tsv")
    readr::read_csv("hansard_justnine_w_year.csv") 
#  readr::read_csv("hansard_justnine_11.08.2019.csv") #
  #readr::read_tsv("membercontributions-20181210.tsv")#"unlemmatized_hansard_sentences.csv")
  #   fread("hansard_20190912.tsv")
  hansard <- hansard %>% 
    #rename(speaker = speaker_name, text = speaker_text,
    # sentence_id = unique_speaker_text_ID,
    #  debate = section_title, debate_id = file_section_ID, 
    #  entities = speaker_ententies, labels = speaker_labels,
    # speechdate = src_date) %>%
    select(-src_image, -src_column, -sentence_errata,
           -section_category, -file_section_id,
           -section_sentence_id, -section_monologue_id
    )
  
  #"#c("debate_id", "speechdate", "debate", "speaker", "constituency", "text")
  #hansard <- hansard %>% #rename(sentence_id = X) %>% 
  # rename(text = sentence) %>% filter(nchar(as.character(text))>12)
  hansard <- hansard %>% mutate(year = year(speechdate))
  assign("hansard", hansard, envir = .GlobalEnv)
  print("hansard read.")
  hansard
  
}




tidyhansard <- function(hansard, parallel) {
  
  print("calling function TIDYHANSARD")
  
  if(parallel==FALSE){
    all_hansard_words <- 
      unnest_tokens(hansard, word, text, token = "words")
    
    # all_hansard_wordcounts_by_year <- all_hansard_words %>%
    #   group_by(year) %>%
    #   summarise(words_per_yr = n()) %>%
    #   select(year, words_per_yr)
  }
  
  if(parallel == TRUE){ 
    require(doParallel)
    require(itertools)
    require(parallel)
    require(foreach)
    
    cores=detectCores()-2
    cl <- makeCluster(cores, outfile = "tidyhansardoutput.txt") #not to overload your computer
    registerDoParallel(cl)
    
    all_hansard_words <- foreach(
      m = isplitRows(hansard, chunks = 100),
      .combine = 'rbind',
      .packages = 'tidytext'
    ) %dopar% {
      unnest_tokens(m, word, text, token = "words")
    }
    
    stopCluster(cl)
  }
  
  all_hansard_words
}




wordcount <- function(str1) {
  print("calling function WORDCOUNT")
  print(paste0("measuring the length, in words, of a string"))
  #  sapply(strsplit(as.character(str1), " "), length) 
  lengths(strsplit(as.character(str1), "\\W+"))
}




count_words_per_debate <- function(debate1, year1) {
  print(paste0("calling function COUNT_WORDS_PER_DEBATE: counting the number of words in ", debate1, " during ", year1))
  alldebates <- hansard %>% 
    filter(year == year1) %>% 
    filter(debate == debate1) 
  wordcounts <- alldebates %>% filter(!is.na(debate)) %>%
    mutate(wordcount = wordcount(as.character(debate)))
  total <- sum(wordcounts$wordcount)
  return(total)
}

term_context <- function(term1, hansard, level, parallel) {
  
  print(paste0("calling function TERM_CONTEXT: finding the hansard debates that contain term ", term1))
  
  # find just the sentences where term1 appears
  print("finding just the debates where the term appears")
  hansard3 <- hansard %>%
    filter(grepl(term1, text))
  
  #term_numwords <- wordcount(term)
  
  if (nrow(hansard3) > 0){
    print("instances of the term have been found")
    print("unpacking the relevant hansard debates into individual words... ")
    
    if(level == "sentence"){
      hansard_words <- hansard3 %>% 
        inner_join(sentencecounts, by = "sentence_id")
      hansard_words <- hansard_words %>%
        select(sentence_id, word, n, year, speechdate, text)
    }
    
    if(level == "speech"){
      hansard_words <- hansard3 %>% select(speech_id, speechdate, text)
      inner_join(speechcounts, by = "speech_id")
      hansard_words <- hansard_words %>%
        select(speech_id, word, wordsperspeech, year, speechdate)
    }
    
    if(level == "debate"){
      hansard_words <- hansard3 %>% select(debate_id, speechdate, text) %>%
        inner_join(debatecounts, by = "debate_id")
      
      hansard_words <- hansard_words %>%
        select(debate_id, word, wordsperdebate, year, speechdate)
    }
    
  }else{hansard_words <- data.frame()}
  
  return(hansard_words)
}



find_term <- function(term1, hansard, parallel) {
  
  print(paste0("calling function FIND_TERM for ", term1))
  
  if(wordcount(term1)==1){   
    
    # find just the debates where term1 appears
    print(paste0("finding the hansard debates that contain term ", term1))
    appearances <- sentencecounts %>% filter(word == term1) %>%
      mutate(n = 1) %>%
      filter(!is.na(year))
  }
  
  
  
  if(wordcount(term1)>1){   
    # find just the debates where term1 appears
    print(paste0("finding the hansard debates that contain term ", term1))
    
    appearances1 <- hansard %>% filter(grepl(term1, text)) %>%
      select(sentence_id)
    
    allwordappearances <- appearances1 %>% 
      left_join(hansard, by = "sentence_id") #if adding levels, work here
    
    if(nrow(allwordappearances)>0){
      unnested <- unnest_tokens(allwordappearances, word, text, token = "ngrams", n = wordcount(term1)) 
      
      appearances <- unnested %>%
        filter(word == term1) %>%
        mutate(n = 1) %>%
        group_by(year, speechdate, sentence_id, word) %>%
        dplyr::mutate(wordspersentence = sum(n))%>%
        ungroup() %>%
        filter(!is.na(year)) %>%
        group_by(year) %>%
        dplyr::mutate(wordspryr = sum(n))%>%
        ungroup()
      
      
    }else{appearances <- data.frame()
    
    }
  }
  
  if(nrow(appearances) > 0){
    
    hansard$sentence_id <- as.integer(hansard$sentence_id)
    appearances$sentence_id <- as.integer(appearances$sentence_id)
    hansard$year <- year(hansard$speechdate)
    appearances$year <- year(appearances$speechdate)
    
    print("appearances have been found.  counting appearances by sentence")
    full_string_appearances <- appearances %>% 
      ungroup() %>%
      select(sentence_id, word, wordspersentence) %>%
      inner_join(hansard, by = "sentence_id") %>% #if adding levels, work here
      group_by(year, speechdate, sentence_id, word) %>%
      dplyr::summarize(wordsprsentence = sum(wordspersentence)) %>%
      ungroup()
    
    print("counting appearances by year")
    appearances_per_yr <- full_string_appearances %>% 
      group_by(year) %>%
      dplyr::summarize(term_mentions_per_year = sum(wordsprsentence)) %>%
      ungroup()
    
    print(paste0("calculating the proportion of ", term1))
    
    # Calculate the word count as a proportion of all words spoken in a single year
    term_proportions <- appearances_per_yr %>%
      left_join(all_hansard_wordcounts_by_year,  by = "year") %>%
      left_join(full_string_appearances) %>%
      mutate(proportion = term_mentions_per_year / words_per_yr) %>%
      mutate(term = term1)
    
  }else{print("-- no instances of the term have been found")
    missing <- c(missing, term1)
    term_proportions <- data.frame()}
  
  return(term_proportions)
}



printterms <- function(term_proportions, n){
  # select just the top appearances for documentation in the table
  top_term_wordcount <- term_proportions %>%
    top_n(n, wt = proportion) %>%
    arrange(desc(proportion)) %>%
    select(term, wordcount, proportion)
  
  # generate visual tables listing the debates with the highest count for term1
  setwd(wordcount_visualizations)
  table <- tableGrob(top_term_wordcount)
  title <-
    textGrob(
      paste0(
        "Debates With Highest Wordcounts for '",
        stringr::str_to_title(term1),
        "'"
      ),
      gp = gpar(fontsize = 20)
    )
  padding <- unit(0.8, "line")
  footnote <- textGrob(
    "",
    x = 0,
    hjust = 0,
    gp = gpar(fontface = "italic")
  )
  table <- gtable_add_rows(table,
                           heights = grobHeight(title) + padding,
                           pos = 0)
  table <- gtable_add_rows(table,
                           heights = grobHeight(footnote) + padding)
  table <- gtable_add_grob(
    table,
    list(title, footnote),
    t = c(1, nrow(table)),
    l = c(1, 2),
    r = ncol(table)
  )
  g <- grid.newpage()
  g <- grid.draw(table)
  
  # save the tables
  setwd(wordcount_visualizations)
  jpg(
    paste0("top-debates-per-term-",
           term1,
           ".jpg"),
    height = 11,
    width = 8.5,
    paper = "letter"
  )
  print(table)
  grid.draw(table)
  dev.off()
}


unnest_parallel <- function(sample, numwords, parallel){ 
  print("calling function UNNEST_PARALLEL")
  if (nrow(sample) > 0){
    
    print("unpacking the relevant hansard debates into individual words... ")
    
    if (parallel == TRUE) {
      require(doParallel)
      require(itertools)
      require(parallel)
      require(foreach)
      
      cores=detectCores()-1
      cl <- makeCluster(cores, outfile = "speaker-entropy.txt") #not to overload your computer
      registerDoParallel(cl)
      
      # tokenize the debates into a dataframe of individual words
      sample_ngrams <-
        foreach(
          m = isplitRows(sample, chunks = cores),
          .combine = 'rbind',
          .packages = 'tidytext'
        ) %dopar% {
          if(numwords > 1){
            unnest_tokens(m, word, text, "ngrams", n = numwords)
          }else{unnest_tokens(m, word, text, "words")}
        }
      
      
      stopCluster(cl)
      
    }else{
      sample_ngrams <- unnest_tokens(sample, word, text, "ngrams", n = numwords)
    }
  }
  return(sample_ngrams)
}

# cleans list with column 'term'
clean_list <- function(c) {
  cat("calling function CLEAN_LIST") 
  
  c <- data.frame(c, stringsAsFactors = FALSE) %>%
    unique()
  
  #delete any remaining parentheses
  c$term <- gsub("\\(\\)", "", c$term)
  c$term <- gsub("\\[\\]", "", c$term)
  c$term <- gsub("\\'", "", c$term)
  c$term <- gsub("\\,", "", c$term)
  c$term <- gsub("\\.", "", c$term)
  
  
  # normalizes white space between the words
  c$term <- gsub("\\s+", " ", c$term)
  c <- c %>%
    mutate(term = trimws(term)) 
  
  c <- c %>% 
    mutate(num = nchar(term)) %>%
    arrange(desc(term))
  
  c <- c %>%
    select(-num)
  c <- c %>%
    filter(!is.na(term)) %>%
    unique()
  c
}

# a function to help label the Y axis
number_ticks <- function(n) {
  function(limits)
    pretty(limits, n)
  
}


reorder_within <- function(x, by, within, fun = mean, sep = "___", ...) {
  new_x <- paste(x, within, sep = sep)
  stats::reorder(new_x, by, FUN = fun)
}


scale_x_reordered <- function(..., sep = "___") {
  reg <- paste0(sep, ".+$")
  ggplot2::scale_x_discrete(labels = function(x) gsub(reg, "", x), ...)
}



scale_y_reordered <- function(..., sep = "___") {
  reg <- paste0(sep, ".+$")
  ggplot2::scale_y_discrete(labels = function(x) gsub(reg, "", x), ...)
}


# next, find n-word context for each
findcontext <- function(term1, numwords){
  print("calling function FINDCONTEXT")
  
  print(paste0("looking for debates where the word ", term1, " appears in hansard"))
  sentence_numbers <- sentencecounts %>% filter(word == term1) %>% select(sentence_id)
  context <- sentencecounts %>% inner_join(sentence_numbers)
  
  sample <- hansard %>%
    filter(grepl(term1, text))
  
  print(paste0("unpacking the context of ", term1, " into ", numwords, "-long phrases"))
  
  sample_ngrams <- unnest_parallel(sample, numwords, parallel)
  
  print(paste0("looking for the ", numwords, "-long phrases where ", term1, " appears in hansard"))
  sample_ngrams2 <- sample_ngrams %>%
    filter(grepl(term1, word)) %>%
    rename(text = word)
  
  print(paste0("unpacking the ", numwords, "-long phrases into single words"))
  sample_ngram3 <- 
    unnest_parallel(sample_ngrams2, 1, parallel)
  
  print("counting the top words")
  top_ngrams <- sample_ngram3 %>%
    count(word) %>%
    top_n(10) %>%
    mutate(term = paste0(term1))
  
  return(top_ngrams)
}

# next, find n-word context for each
findsentence <- function(term1){
  
  print("calling function FINDSENTENCE")  
  print(paste0("looking for debates where the word ", term1, " appears in hansard"))
  sample <- hansard %>%
    filter(grepl(term1, text))
  
  
  if (nrow(sample) > 0){
    
    print("sample found. unpacking the relevant hansard debates into individual words... ")
    
    if (parallel == TRUE) {
      require(doParallel)
      require(itertools)
      require(parallel)
      require(foreach)
      
      cores=detectCores()-1
      cl <- makeCluster(cores, outfile = "speaker-entropy.txt") #not to overload your computer
      registerDoParallel(cl)
      
      # tokenize the debates into a dataframe of individual words
      sentences <-
        foreach(
          m = isplitRows(sample, chunks = cores),
          .combine = 'rbind',
          .packages = 'tidytext'
        ) %dopar% {
          
          unnest_tokens(m, word, text, "sentences")
          
        }
      
      
      stopCluster(cl)
      
      print("sentences unpacked")
      
    }else{
      sentences <- unnest_tokens(sample, word, text, "sentences")
    }
  }
  
  print(paste0("looking for the sentences where ", term1, " appears in hansard"))
  sentences2 <- sentences %>%
    filter(grepl(term1, word)) %>%
    rename(text = word)
  
  print(paste0("unpacking the sentences into single words"))
  sentences3 <- 
    unnest_parallel(sentences2, 1, parallel)
  
  print("counting the top words")
  top_ngrams <- sentences3 %>%
    count(word) %>%
    anti_join(stop_words) %>%
    top_n(10) %>%
    mutate(term = paste0(term1))
  
  return(top_ngrams)
}


loadterminology <- function(termcsv, custom_stop_words) {
  print("calling function LOADTERMINOLOGY")
  print("loading terminology")
  setwd("~/projects/data")
  terms <- read.csv(paste0(description, ".csv")) 
  if(grepl(";", terms)){
    terms <- read.csv2(paste0(description, ".csv"))
  }
  if("X" %in% colnames(terms)){
    terms <- terms %>% select(-X)
  }
  if("X1" %in% colnames(terms)){
    terms <- terms %>% select(-X1)
  }
  names(terms) <- "term"
  terms <- terms %>%
    clean_list() %>%
    anti_join(custom_stop_words) %>%
    mutate(term = tolower(as.character(term))) %>%
    select(term)
  
  print("terminology loaded into a dataframe TERMS with column named TERM")
  return(terms)
  
}








setup_parallel <- function(){
  print("calling function SETUP_PARALLEL")
  closeAllConnections()
  if (parallel == TRUE) {
    require(doParallel)
    require(itertools)
    require(parallel)
    require(foreach)
    
    assign("cores", detectCores() - 2, envir = .GlobalEnv )
    assign("cl", makeCluster(cores, outfile = "speaker-entropy.txt"),  envir = .GlobalEnv) #not to overload your computer
    registerDoParallel(cl)
  }
}


#termscraper_list works like termscraper, but it goes through a list of keywords, with
# a column called 'term' describing each keyword
find_term_list <- function(terms, hansard, parallel){
  print("calling function FIND_TERM_LIST")
  loadfrequencies(level)
  if(parallel == TRUE){all_terms_wordcount <- find_term_list_parallel(terms, hansard)}
  if(parallel == FALSE){
    
    all_terms_wordcount  <- data.frame()
    
    for(i in 1:nrow(terms)){
      
      term1 <- terms[i,1]
      
      filename <- paste0("all-debates-containing-term-", term1, ".csv")
      setwd(wordcount_data)
      
      if(file.exists(filename)){
        print(paste0("loading ", filename))
        (term_proportions <- read.csv2(filename))
      }
      
      if(!file.exists(filename)){
        
        term_proportions <- find_term(term1, hansard, parallel)
        print("back in function FIND_TERM_LIST")
        
        if(nrow(term_proportions)>1){
          # save the wordcounts for later use
          print(paste0(nrow(term_proportions), " instances of ", term1, " have been scraped"))
          
          print(paste0("saving file called ", filename))
          setwd(wordcount_data)
          write.csv2(term_proportions, filename)
        }
        
        if(nrow(term_proportions)<=1){
          print(paste0("no date information any appearances. dropping ", term1, " from the record."))
          missingdate <- c(missingdate, term1)
        }
        
        if(nrow(term_proportions)>1){
          if(exists("all_terms_wordcount")){
            if(nrow(all_terms_wordcount)>1){
              all_terms_wordcount$year = as.integer(all_terms_wordcount$year) # not sure why this got thrown off
            }
            
            if("speechdate" %in% colnames(term_proportions)){
              term_proportions <- term_proportions %>% 
                select(year, term, term_mentions_per_year, words_per_yr, proportion)
              term_proportions$year = as.integer(term_proportions$year)
            }# not sure why this got thrown off
            
            "adding information to a list of all termcounts "
          }}
      }
      all_terms_wordcount <- all_terms_wordcount %>% bind_rows(term_proportions)
      
      
    }
  }
  print("done counting terms. returning all_terms_wordcount")
  return(all_terms_wordcount)
}


find_term_list_parallel <- function(terms, hansard){
  print("calling function FIND_TERM_LIST_PARALLEL")
  setup_parallel()
  
  all_terms_wordcount  <- foreach(i = 1:nrow(terms), 
                                  .combine = rbind,
                                  .packages = c("dplyr", "tidytext", "lubridate")
  )%dopar%{
    
    term1 <- terms[i,1]
    
    setwd(wordcount_data)
    if(file.exists(paste0("top-debates-containing-term-", term1, ".csv"))){
      (term_proportions <- read.csv2(paste0("top-debates-containing-term-", term1, ".csv")))
    }
    
    
    if(!file.exists(paste0("top-debates-containing-term-", term1, ".csv"))){
      
      term_proportions <- find_term(term1, hansard, parallel)
      print("back in function FIND_TERM_LIST")
      
      if(nrow(term_proportions)>1){
        # save the wordcounts for later use
        print("instances of the term have been scraped")
        
        print(paste0("saving a csv file for ", term1))
        setwd(wordcount_data)
        write.csv2(term_proportions,
                   paste0("top-debates-containing-term-", term1, ".csv"))
      }
      
      if(nrow(term_proportions)<=1){
        print("no date information about those appearances. dropping them from the record.")
      }
      
      if(nrow(term_proportions)>1){
        if(exists("all_terms_wordcount")){
          if(nrow(all_terms_wordcount)>1){
            all_terms_wordcount$year = as.integer(all_terms_wordcount$year) # not sure why this got thrown off
          }
          
          if("speechdate" %in% colnames(term_proportions)){
            term_proportions <- term_proportions %>% select(year, term, term_mentions_per_year, words_per_yr, proportion)
            term_proportions$year = as.integer(term_proportions$year)
          }
          
          term_proportions
        }}}}
  
  stopCluster(cl)
  return(all_terms_wordcount)
}


read_term_list <- function(terms){
  print("calling function READ_TERM_LIST")
  #if(parallel == FALSE){
  all_terms_wordcount  <- data.frame()
  
  for (i in 1:nrow(terms)){
    term1 <- terms[i, 1]
    setwd(wordcount_data)
    if(file.exists(paste0("top-debates-containing-term-", term1, ".csv"))){
      term_proportions <-
        read.csv2(paste0("top-debates-containing-term-", term1, ".csv"))}else{
          term_proportions <- data.frame() }
    all_terms_wordcount <-
      bind_rows(all_terms_wordcount, term_proportions)
  }
  
  return(all_terms_wordcount)
}


standard_library <- function(){
  print("calling function STANDARD_LIBRARY")
  library(foreach)
  library(dplyr)
  library(ggraph)
  library(philentropy)
  library(readr)
  library(igraph)
  library(tidygraph)
  library(foreach)
  library(entropy)
  library(zoo)
  library(tidyr)
  library(tidytext)
  library(data.table)
  library(gridExtra)
  library(grid)
  library(ggplot2)
  library(lubridate)
  library(itertools)
  library(grid)
  library(gtable)
  library(doParallel)
  library(ggrepel)
  
}

unnest_sentences <- function(m1){
  print("calling function UNNEST_SENTENCES")
  #where m1 is a line of text
  m_rn <- unique(m1$speech_id)
  m_id <- unique(m1$debate_id)
  m_sd <- unique(m1$speechdate)
  m_d <- unique(m1$debate)
  m_s <- unique(m1$speaker)
  text <- m1$text
  m_text <- str_split(text, "[.]")
  m2 <- as.data.frame(m_text) 
  m2 <- m2 %>% mutate(speech_id = m_rn) %>%
    mutate(debate_id = m_id) %>%
    mutate(speechdate = m_sd) %>%
    mutate(debate = m_d) %>%
    mutate(speaker = m_s)
  names(m2) <- c("sentence", "speech_id", "debate_id", "speechdate", "debate", "speaker")
  
  return(m2)
}

load_wordcounts <- function(description){
  
  print("calling function LOAD_WORDCOUNTS")
  setwd("~/projects/data")
  hansard <- hansard %>% mutate(year = year(speechdate)) # do this again because somehow it often lapses and causes problems.
  filename <- paste0("all_terms_wordcount_", description, ".csv")
  if(file.exists(filename)){
    setwd("~/projects/data")
    print(paste0("reading in prevoiusly generated files about ", description))
    assign("all_terms_wordcount", read.csv2(filename), envir = .GlobalEnv)
  }
  if(!file.exists(filename)){
    print(paste0("no previously generated files about ", description, " have been found."))
    print(paste0("preparing to scrape intances of the language of ", description, " from hansard."))
    loadfrequencies(level) 
    all_terms_wordcount <- find_term_list(terms, hansard, parallel) 
    print("back in LOAD_WORDCOUNTS")
    #all_terms_wordcount <- read_term_list(terms) #<-- use if the process was interrupted
    if(nrow(all_terms_wordcount)>1){
      setwd("~/projects/data")
      write.csv2(all_terms_wordcount, filename)
    }
  }
  
  return(all_terms_wordcount)
}


find_collocates <- function(term1, firstyear, lastyear, level){
  
  print("calling function FIND_COLLOCATES")
  
  filename <- paste0(term1, "_collocates_", firstyear, "-", lastyear, ".csv")
  
  if(file.exists(filename)){
    setwd("~/projects/data")
    print(paste0("loading previously generated file about ", term1))
    appearances <- read_csv(filename)
  }
  
  if(!file.exists(filename)){
    print("no previously generated file found")
    
    if(wordcount(term1)==1){
      # find just the debates where term1 appears
      print(paste0("finding the hansard debates that contain term ", term1))
      
      loadfrequencies(level)
      print("back in FIND COLLOCATES")
      
      if(level == "sentence"){  
        print(paste0("counting collocate appearances per ", level))
        appearancesentences <- sentencecounts %>% 
          filter(word == term1) %>%
          select(sentence_id) %>%
          unique()
        
        appearances <- sentencecounts %>%
          inner_join(appearancesentences) %>%
          filter(word != term1)
      }
      
      if(level == "speech"){
        print(paste0("counting collocate appearances per ", level))
        
        appearancespeeches <- speechcounts %>% 
          filter(word == term1) %>%
          select(speech_id) %>%
          unique()
        
        appearances <- speechcounts %>%
          inner_join(appearancespeeches) %>%
          filter(word != term1)
        
      }
      
      if(level == "debate"){  
        print(paste0("counting collocate appearances per ", level))
        
        appearancesentences <- debatecounts %>% 
          filter(word == term1) %>%
          select(debate_id) %>%
          unique()
        
        appearances <- debatecounts %>%
          inner_join(appearancesentences) %>%
          filter(word != term1)
      }
    }
    
    
    if(wordcount(term1)>1){
      # find just the debates where term1 appears
      print(paste0("finding the hansard debates that contain term ", term1))
      
      appearances <- hansard %>%  
        filter(year >= firstyear) %>%
        filter(year <= lastyear) %>% 
        filter(grepl(term1, text)) 
      
      appearances$text <- appearances$text %>%
        stringr::str_remove(term1)  
      
      unnested <- 
        unnest_tokens(appearances, word, text, token = "words")
      
      if(level == "sentence"){
        appearances <- unnested %>%
          group_by(year, debate_id, speech_id, sentence_id, word)  %>%
          mutate(wordspersentence = n()) %>%
          ungroup()
      }
      if(level == "speech"){
        appearances <- unnested %>%
          group_by(year, debate_id, speech_id, word)  %>%
          mutate(wordspersentence = n()) %>%
          ungroup()
      }
      if(level == "debate"){
        appearances <- unnested %>%
          group_by(year, debate_id, word)  %>%
          mutate(wordspersentence = n()) %>%
          ungroup()
      }
      
    }
    
    if(nrow(appearances) > 0){
      print(paste0(nrow(appearances), " lines of context found for ", term1))  
      print(paste0("saving file : ", filename))
      setwd("~/projects/data")
      write_csv(appearances, filename)
    }else{
      print("no collocates found.")  
      appearances <- data.frame()
    }
  }
  return(appearances)
}





# find_associations calls term_context for a list (test_terms), then counts 
# the words in the context, computes tf-Idf using all-hansard scores, and 
# returns a dataframe that contains a ranked list of contextual words for each
# term in term_list with counts and tf-idf scores.  

find_associations <- function(test_terms, firstyear, lastyear, level, parallel) {
  print("calling function FIND_ASSOCIATIONS")
  print(paste0("finding words associated with ", description))
  
  if(exists("associations")&&all(unlist(list1)%in%c(unique(associations$term)))&&(abs(max(associations$year)-min(associations$year) - (lastyear-firstyear)>10))){
    print("associations dataframe in use appears to match. using it.")
    test1 <- TRUE # test1==TRUE means skip to end, everything is fine
  }else{test1 <- FALSE 
  if(exists("associations")){rm("associations")}
  
  if(test1 == FALSE){  
    print("looking for a previously generated file of word associations")
    filename <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
    setwd("~/projects/data")
    if(file.exists(filename)){
      print(paste0("reading a previously generated file called ", filename))
      associations <- read_csv(filename)
      if(unlist(list1)%in%c(unique(associations$term))&&(abs(max(associations$year)-min(associations$year) - (lastyear-firstyear)>10))){test1 <- TRUE}
    }}
  
  if(test1 == FALSE){
    if(!file.exists(filename)){
      print("cycling through words")
      if(parallel==FALSE){
        
        associations <- data.frame()
        
        for (i in 1:nrow(test_terms)) {
          term1 <- test_terms[i,1]
          print(paste0("working on ", paste0(term1)))
          
          context <-
            find_collocates(paste(term1), firstyear, lastyear, level)  
          
          print("back to FIND_ASSOCIATIONS")
          print(paste0("context is ", nrow(context), " rows"))
          
          if(exists("context")&(nrow(context) > 0)){
            context$term <- paste(term1)
            context$year <- as.integer(context$year)
          }else{
            context <- data.frame()}
          
          if(nrow(associations)>0){
            associations$year <- as.integer(associations$year)}
          
          print(paste0("attaching findings about ", term1, " to collection of word associations"))
          associations <- associations %>% bind_rows(context)
          associations
        }
      }
      
      if(parallel==TRUE){
        setup_parallel()
        print("running search for terms in parallel")
        associations <- foreach(i = 1:nrow(test_terms), .combine = rbind, 
                                .export = c("find_collocates", "wordcount", "loadfrequencies", "datafolder", setwd("~/projects/data"), "hansard", "firstyear", "lastyear", "level"), 
                                .packages = c("dplyr", "tidytext")
        )%dopar%{
          
          term1 <- test_terms[i,1]
          print(paste0("working on ", paste0(term1)))
          
          context <-
            find_collocates(term1, firstyear, lastyear, level)  
          
          if(exists("context")&length(context > 0)){
            context$term <- paste(term1)}else{
              context <- data.frame()}
          
          print(paste0("attaching findings about ", term1, " to collection of word associations"))
          context
        } 
        stopCluster(cl)
      }
      
      
      if(nrow(associations)>0){
        
        print(paste0("saving a file called ", filename))
        setwd("~/projects/data")
        write_csv(associations, filename)
      }else{print("nothing found")}
    }}
  
  print("saving the output as a global environmental variable called associations (this may be redundant but will help if referenced by other functions)")
  associations <- associations %>%
    mutate(level = level)
  assign("associations", associations, envir=.GlobalEnv)
  
  return(associations)
  }
}




tfidf_associations <- function(list1, firstyear, lastyear, level, parallel) {
  
  print("calling function TFIDF_ASSOCIATIONS")
  loadfrequencies(level)
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered word associations about ",
    description
  ))
  
  
  filename <- paste0("tfidf_associations", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
  
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "reading in file: ", filename))
    setwd("~/projects/data")
    tfidf3 <-
      read_csv(filename)
  }
  # instructions for if no tfidf_associations file is found
  if (!file.exists(filename)){ 
    print("no previous files found")
    
    print(paste0("gathering tfidf measurements for ", description))
    if(exists("associations")&&
       (unique(associations$level) == level) && 
       all(unlist(list1) %in% unique(associations$term)) &&
       (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
    ){print("previously generated dataframe of word associations exists from running find_associations.  using it.")
    } else { 
      print("looking for previously generated file of word associations")
      filename1 <- paste0("associations", description,
                          "_",
                          firstyear,
                          "-",
                          lastyear,
                          "_",
                          level,
                          ".csv")
      setwd("~/projects/data")
      
      if (file.exists(filename1)) {
        print("previously generated file of tfidf measurements found")
        associations <- read_csv(filename1) %>% mutate(level = level)
        assign("associations", associations, envir=.GlobalEnv)
      }else { if (!file.exists(filename1)) {
        print("no previously generated file of tfidf measurements found")
        associations <-
          find_associations(list1, firstyear, lastyear, level, parallel) %>%
          mutate(level = level)
        assign("associations", associations, envir=.GlobalEnv)
        
        print("back in TFIDF_ASSOCIATIONS")
      }
      }}
    # at this point there should be a file called "associations" which
    # gives the data about speeches that mention any words in list1.
    
    # next, the speechcounts/debatecounts/sentencecounts files 
    # are used to give the raw counts of collocates per document
    # for other speeches/ debates / sentences.
    
    # associations is renamed so that the keywords in list1 function
    # as document names (in the rownumber or sentence number column)
    # this will make it possible down the road to use the tfidf
    # measure to tell which words are "distinctive" to each keyword
    # as if the keyword were any other document.
    
    # the files are "anti-joined", and then bound together,
    # so that the tfidf dataframe contains lists of collocates 
    # for each sentence/speech/debate + collocates just for 
    # keywords in list1 with no overlap.  
    
    if (level == "speech") {
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(speech_id)) %>%
          group_by(speech_id, term, word) %>%
          summarize(wcount = sum(wordsperspeech))
        
        context_count$speech_id <- as.character(context_count$speech_id)
        
        # count collocations per speech for each speech in hansard
        tfidf <- speechcounts %>%           
          filter(!is.na(speech_id)) 
        
        if(nrow(tfidf)>0){
          tfidf$speech_id <- as.character(tfidf$speech_id)
          colnames(tfidf)[colnames(tfidf)=="wordsperspeech"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          tfidf <- tfidf %>%
            anti_join(context_count, by = "speech_id")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(tfidf)[colnames(tfidf)=="speech_id"] <- "term"
          
          # tfidf and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          tfidf <- tfidf %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{tfidf <- data.frame()}
      }else{tfidf <- data.frame()}
    }
    
    if(level == "debate") {
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(debate_id)) %>%
          group_by(debate_id, term, word) %>%
          summarize(wcount = sum(wordsperdebate))
        
        context_count$debate_id <- as.character(context_count$debate_id)
        
        # count collocations per speech for each speech in hansard
        tfidf <- debate_counts %>%           
          filter(!is.na(debate_id)) 
        
        if(nrow(tfidf)>0){
          tfidf$debate_id <- as.character(tfidf$debate_id)
          colnames(tfidf)[colnames(tfidf)=="wordsperdebate"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          tfidf <- tfidf %>%
            anti_join(context_count, by = "debate_id")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(tfidf)[colnames(tfidf)=="debate_id"] <- "term"
          
          # tfidf and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          tfidf <- tfidf %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{tfidf <- data.frame()}
      }else{tfidf <- data.frame()}
    }
    
    if(level == "sentence"){
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(sentence_number)) %>%
          group_by(sentence_number, term, word) %>%
          summarize(wcount = sum(wordspersentence))
        
        context_count$sentence_number <- as.character(context_count$sentence_number)
        
        # count collocations per speech for each speech in hansard
        tfidf <- sentencecounts %>%           
          filter(!is.na(sentence_number)) 
        
        if(nrow(tfidf)>0){
          tfidf$sentence_number <- as.character(tfidf$sentence_number)
          colnames(tfidf)[colnames(tfidf)=="wordspersentence"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          tfidf <- tfidf %>%
            anti_join(context_count, by = "sentence_number")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(tfidf)[colnames(tfidf)=="sentence_number"] <- "term"
          
          # tfidf and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          tfidf <- tfidf %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{tfidf <- data.frame()}
      }else{tfidf <- data.frame()}
    }
    
    tfidf <- tfidf %>%
      as_tibble()
    
    if((length(tfidf)>0)&(nrow(tfidf) > 0)){
      
      
      print("joining variables context_count (context of terms) and tfidf (context of all debates)")
      
      # here we create fake documents where the "term" 
      # (keyword from list1) will later serve as the document for tfidf 
      # measuring.
      # each line in context_count2 is a count of a collocates
      # for a term in list1, so that each word will be measured
      # as if a debate, speech, etc. 
      
      context_count2 <- context_count %>%
        mutate(term = as.character(term)) %>%
        mutate(word = as.character(word)) %>%
        select(term, word, wcount) %>%
        group_by(term, word) %>%
        summarize(wcount = sum(wcount))
      
      print("turning everything into a character")
      tfidf$term <- as.character(tfidf$term)
      
      tfidf2 <- tfidf %>%
        bind_rows(context_count2) 
      
      tfidf3 <- tfidf2 %>%
        bind_tf_idf(word, term, wcount) %>%
        arrange(desc(tf_idf)) %>%
        group_by(term) %>%
        filter(!term == word) %>%
        ungroup()
      
      print("saving tfidf as a universal variable")
      #save to global environment, just in case
      assign("tfidf", tfidf3, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(tfidf3, filename)
      
      
      
    }else{tfidf3 <- data.frame()}
  }#end instructions for generating tfidf3 if no previous file existed.
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(tfidf3)
  
}

tfidf_associations_alt <- function(list1, firstyear, lastyear, level, parallel, method) {
  
  print("calling function TFIDF_ASSOCIATIONS_ALT")
  loadfrequencies(level)
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered word associations about ",
    description
  ))
  
  
  filename <- paste0("tfidf_associations", description, "-", method, "_", firstyear, "-", lastyear, "_", level, ".csv")
  
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "reading in file: ", filename))
    setwd("~/projects/data")
    tfidf3 <-
      read_csv(filename)
  }
  # instructions for if no tfidf_associations file is found
  if (!file.exists(filename)){ 
    print("no previous files found")
    
    print(paste0("gathering tfidf measurements for ", description))
    if(exists("associations")&&
       (unique(associations$level) == level) && 
       all(unlist(list1) %in% unique(associations$term)) &&
       (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
    ){print("previously generated dataframe of word associations exists from running find_associations.  using it.")
    } else { 
      print("looking for previously generated file of word associations")
      filename1 <- paste0("associations", description, "-", method,
                          "_",
                          firstyear,
                          "-",
                          lastyear,
                          "_",
                          level,
                          ".csv")
      setwd("~/projects/data")
      
      if (file.exists(filename1)) {
        print("previously generated file of tfidf measurements found")
        associations <- read_csv(filename1) %>% mutate(level = level)
        assign("associations", associations, envir=.GlobalEnv)
      }else { if (!file.exists(filename1)) {
        print("no previously generated file of tfidf measurements found")
        associations <-
          find_associations(list1, firstyear, lastyear, level, parallel) %>%
          mutate(level = level)
        assign("associations", associations, envir=.GlobalEnv)
        
        print("back in TFIDF_ASSOCIATIONS")
      }
      }}
    # at this point there should be a file called "associations" which
    # gives the data about speeches that mention any words in list1.
    
    # next, the speechcounts/debatecounts/sentencecounts files 
    # are used to give the raw counts of collocates per document
    # for other speeches/ debates / sentences.
    
    # associations is renamed so that the keywords in list1 function
    # as document names (in the rownumber or sentence number column)
    # this will make it possible down the road to use the tfidf
    # measure to tell which words are "distinctive" to each keyword
    # as if the keyword were any other document.
    
    # the files are "anti-joined", and then bound together,
    # so that the tfidf dataframe contains lists of collocates 
    # for each sentence/speech/debate + collocates just for 
    # keywords in list1 with no overlap.  
    
    if (level == "speech") {
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(speech_id)) %>%
          group_by(speech_id, term, word) %>%
          summarize(wcount = sum(wordsperspeech))
        
        context_count$speech_id <- as.character(context_count$speech_id)
        
        # count collocations per speech for each speech in hansard
        tfidf <- speechcounts %>%           
          filter(!is.na(speech_id)) 
        
        if(nrow(tfidf)>0){
          tfidf$speech_id <- as.character(tfidf$speech_id)
          colnames(tfidf)[colnames(tfidf)=="wordsperspeech"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          tfidf <- tfidf %>%
            anti_join(context_count, by = "speech_id")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(tfidf)[colnames(tfidf)=="speech_id"] <- "term"
          
          # tfidf and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          tfidf <- tfidf %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{tfidf <- data.frame()}
      }else{tfidf <- data.frame()}
    }
    
    if(level == "debate") {
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(debate_id)) %>%
          group_by(debate_id, term, word) %>%
          summarize(wcount = sum(wordsperdebate))
        
        context_count$debate_id <- as.character(context_count$debate_id)
        
        # count collocations per speech for each speech in hansard
        tfidf <- debate_counts %>%           
          filter(!is.na(debate_id)) 
        
        if(nrow(tfidf)>0){
          tfidf$debate_id <- as.character(tfidf$debate_id)
          colnames(tfidf)[colnames(tfidf)=="wordsperdebate"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          tfidf <- tfidf %>%
            anti_join(context_count, by = "debate_id")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(tfidf)[colnames(tfidf)=="debate_id"] <- "term"
          
          # tfidf and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          tfidf <- tfidf %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{tfidf <- data.frame()}
      }else{tfidf <- data.frame()}
    }
    
    if(level == "sentence"){
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(sentence_number)) %>%
          group_by(sentence_number, term, word) %>%
          summarize(wcount = sum(wordspersentence))
        
        context_count$sentence_number <- as.character(context_count$sentence_number)
        
        # count collocations per speech for each speech in hansard
        tfidf <- sentencecounts %>%           
          filter(!is.na(sentence_number)) 
        
        if(nrow(tfidf)>0){
          tfidf$sentence_number <- as.character(tfidf$sentence_number)
          colnames(tfidf)[colnames(tfidf)=="wordspersentence"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          tfidf <- tfidf %>%
            anti_join(context_count, by = "sentence_number")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(tfidf)[colnames(tfidf)=="sentence_number"] <- "term"
          
          # tfidf and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          tfidf <- tfidf %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{tfidf <- data.frame()}
      }else{tfidf <- data.frame()}
    }
    
    tfidf <- tfidf %>%
      as_tibble()
    
    if((length(tfidf)>0)&(nrow(tfidf) > 0)){
      
      
      print("joining variables context_count (context of terms) and tfidf (context of all debates)")
      
      # here we create fake documents where the "term" 
      # (keyword from list1) will later serve as the document for tfidf 
      # measuring.
      # each line in context_count2 is a count of a collocates
      # for a term in list1, so that each word will be measured
      # as if a debate, speech, etc. 
      
      context_count2 <- context_count %>%
        mutate(term = as.character(term)) %>%
        mutate(word = as.character(word)) %>%
        select(term, word, wcount) %>%
        group_by(term, word) %>%
        summarize(wcount = sum(wcount))
      
      print("turning everything into a character")
      tfidf$term <- as.character(tfidf$term)
      
      tfidf2 <- tfidf %>%
        bind_rows(context_count2) 
      
      tfidf25 <- tfidf2 %>%
        bind_tf_idf_alt(word, term, wcount, method) 
      
      tfidf3 <- tfidf25 %>%
        arrange(desc(tf_idf)) %>%
        group_by(term) %>%
        filter(!term == word) %>%
        ungroup()
      
      print("saving tfidf as a universal variable")
      #save to global environment, just in case
      assign(paste0("tfidf-", method), tfidf3, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(tfidf3, filename)
      
      
      
    }else{tfidf3 <- data.frame()}
  }#end instructions for generating tfidf3 if no previous file existed.
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level, " with method ", method))
  return(tfidf3)
  
}



# jo's extractor
# at the moment, this will extract "Earl of Bridgewater" and "Lord Sheffield"
# and add them to the list of named entities.
# for place names, this code will ensure that "York" is not counted as a place
# every time the Duke of York is referenced.

entity_consolidate_heraldic <- function(text2){
  
  title_words <- c("MR", "GENERAL", "MESSR", "CAPTAIN", "JUDGE","LORD", "LADY", "LIEUTENANT", "INSPECTOR", "SERGEANT", "EARL", "DUKE", "DUCHESS", "VISCOUNT", "COUNTESS", "COUNT", "DOWAGER COUNTESS", "DOWAGER DUCHESS", "PRINCE", "PRINCESS", "BARON", "BARONESS", "VISCOUNTESS", "MAJOR", "GENERAL", "LIEUTENANT", "COMMANDER", "COLONEL", "JUDGE", "INSPECTOR")
  
  library(Hmisc)
  
  hacking <- text2 %>%
    filter(toupper(token) %in% title_words) %>%
    filter(capitalize(token) == token) 
  
  h2 <- hacking %>% select(token_id, doc_id, sentence_id) 
  
  h3 <- h2 %>% mutate(token_id = token_id+1) %>%
    left_join(text2) %>%
    filter(pos == "PROPN") 
  
  h4 <- h2 %>% mutate(token_id = token_id+1) %>%
    left_join(text2) %>%
    filter(pos == "ADP") %>%
    select(token_id, doc_id, sentence_id)
  
  h45 <- h4 %>%
    mutate(token_id = token_id+1) %>%
    left_join(text2) %>%
    filter(pos == "PROPN") %>% 
    select(token_id, doc_id, sentence_id) %>%
    left_join(text2)
  
  # three word strings -- working
  h5 <- h2 %>% 
    filter(doc_id %in% h45$doc_id) %>%
    filter(sentence_id %in% h45$sentence_id) %>%
    bind_rows(h4, h45) %>%
    select(token_id, doc_id, sentence_id) %>%
    left_join(text2) %>%
    group_by(doc_id, sentence_id) %>%
    arrange(doc_id, sentence_id, token_id) %>%
    mutate(entity = paste0(token, "_", shift(token, n = -1), "_", shift(token, n = -2, fill=""))) %>%
    filter(toupper(token) %in% title_words)
  
  # two word strings  -- NOT WORKING YET
  h6 <- h3 %>% select("doc_id", "sentence_id") %>% 
    left_join(hacking, by = c("doc_id", "sentence_id")) %>%
    bind_rows(h3) %>%
    #bind_rows(h2) %>%
    #left_join(text2) %>%
    group_by(doc_id, sentence_id) %>%
    arrange(doc_id, sentence_id, token_id) %>%
    mutate(entity = paste0(token, "_", shift(token, n = -1))) %>%
    filter(toupper(token) %in% title_words)
  
  # add the duke and duchess
  h10 <- h2 %>% mutate(token_id = token_id-2) %>%
    left_join(text2) %>%
    filter(capitalize(token) %in% title_words) 
  h11 <- h10 %>% select(token_id, doc_id, sentence_id) %>%
    mutate(token_id = token_id+1) %>%
    left_join(text2) %>%
    filter(pos == "CCONJ") 
  
  extracted <- bind_rows(h5, h6, h10, h11) %>%
    mutate(token = entity) %>% 
    mutate(lemma = entity) %>%
    mutate(entity_type = "PERSON")
  
  remove <- bind_rows(h2, h3, h4, h45, h5, h6, h10, h11) %>%
    select(token_id, doc_id, sentence_id)
  
  text2 <- text2 %>% anti_join(remove) %>%
    bind_rows(extracted)%>%
    arrange(doc_id, sentence_id, token_id)
  
  text2
}



clean_nations <- function(nation_debates){
  # clean up Ireland/Irish
  
  
  
  nation_debates$nation <- str_replace(nation_debates$nation,
                                       paste0("\\b", "IRISH", "\\b"), "IRELAND")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SCOTCH", "\\b"), "SCOTLAND")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SCOTS", "\\b"), "SCOTLAND")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SCOTS", "\\b"), "SCOTLAND")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SCOTTISH", "\\b"), "SCOTLAND")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "GERMAN", "\\b"), "GERMANY")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "FRENCH", "\\b"), "FRANCE")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "DUTCH", "\\b"), "HOLLAND")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "POLISH", "\\b"), "POLAND")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "WELSH", "\\b"), "WALES")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "BELGIAN", "\\b"), "BELGIUM")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "CHINESE", "\\b"), "CHINA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SENEGALESE", "\\b"), "SENEGAL")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "BURMESE", "\\b"), "BURMA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "BURMAH", "\\b"), "BURMA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SOUDAN", "\\b"), "SUDAN")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "THIBET", "\\b"), "TIBET")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "AUSTRALIAN", "\\b"), "AUSTRALIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SOUTH AFRICAN", "\\b"), "SOUTH AFRICA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "PACIFIC ISLANDERS", "\\b"), "PACIFIC ISLANDS")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "JEWISH", "\\b"), "JEWS")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "BOERS", "\\b"), "BOER")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "AFRICAN", "\\b"), "AFRICA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "CANADIAN", "\\b"), "CANADA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SWISS", "\\b"), "SWITZERLAND")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "NORWEGIAN", "\\b"), "NORWAY")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "FEEJEE", "\\b"), "FIJI")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "EGYPTIEN", "\\b"), "EGYPT")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "EGYPTIAN", "\\b"), "EGYPT")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "RUSSO", "\\b"), "RUSSIAN")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "FEEJEEAN", "\\b"), "FIJI")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "FIJIAN", "\\b"), "FIJI")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "INDIAN", "\\b"), "INDIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "AUSTRALASIAN", "\\b"), "AUSTRALASIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "NORTH AMERICAN", "\\b"), "NORTH AMERICA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "VENEZUELAN", "\\b"), "VENEZUELA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "AFFGHANISTAN", "\\b"), "AFGHANISTAN")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SOUTHEN", "\\b"), "SOUTHERN")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "THIBETAN", "\\b"), "TIBET")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "TIBETAN", "\\b"), "TIBET")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "HUNGARIAN", "\\b"), "HUNGARY")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "RUSSIAN", "\\b"), "RUSSIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "HIBERNIAN", "\\b"), "HIBERNIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "AFFGHAN", "\\b"), "AFGHANISTAN")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "AFGHAN", "\\b"), "AFGHANISTAN")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "ITALIAN", "\\b"), "ITALY")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SERVIAN", "\\b"), "SERBIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "SERVIA", "\\b"), "SERBIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "POLYNESIAN", "\\b"), "POLYNESIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "AUSTRALIAN", "\\b"), "AUSTRALIA")
  nation_debates$nation <- str_replace(nation_debates$nation, 
                                       paste0("\\b", "BRITISH SOUTH AFRICA", "\\b"), "SOUTH AFRICA")
  
  
  n_nations <- c("SUDAN", "VATICAN", "DOMINION", "MUSSELMAN", "BRITAIN", "GREAT BRITAIN", "FENIAN", "JAPAN", "NORTHERN", "WESTERN", "EASTERN", "SOUTHERN", "CROWN", "SOLOMON ISLANDS",
                 "VIRGIN ISLANDS", "OTTOMAN EMPIRE", "AFGHANISTAN", "TIENTSIN", "PERSIAN", 
                 "IONIAN ISLANDS", "OCEAN", "ADEN", "CEYLON", "BENIN", "ANDAMAN", "CREEK TOWN", 
                 "SWEDEN", "CHUSAN", "COCHIN", "CONFEDERATION",
                 "SPAIN", "ARRAN", "FOREIGN", "VAN DIEMENS LAND", "FLANNAN", "KERGUELEN",
                 "MIN-QUIER", "ISLE OF MAN", "CARDIGAN BAY", "LABUAN", "OMAN", "ORAN" )
  # regularize all end -N's so that "RUSSIAN" becomes "RUSSIA".  Note: this may be a problem for Sudan, Pakistan, etc.
  maybewrong <- nation_debates %>%
    filter(str_detect(nation, "N\\b")) 
  for(nation1 in n_nations){
    maybewrong <- maybewrong %>%
      filter(!grepl(nation1, nation))
  }
  maybecorrected <- str_remove(maybewrong$nation, "N\\b")
  maybewrong$nation <-
    str_remove(maybewrong$nation, "N\\b")
  #nation_debates <- 
  
  nation_debates <- nation_debates %>%
    filter(!str_detect(nation, "N\\b")) %>%
    bind_rows(maybewrong)
  
  
  nation_debates <- nation_debates %>%
    filter(!nation == "WEST") %>%
    filter(!nation == "WESTERN") %>%
    filter(!nation == "PARTS OF")
  
  
}



tfidf_comparison <- function(list1, firstyear, lastyear, level, parallel){
  print("calling function TFIDF_COMPARISON")
  
  loadfrequencies(level)
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered comparative tfidf about ",
    description
  ))
  
  
  filename <- paste0("tfidf_comparison_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "reading in file: ", filename))
    setwd("~/projects/data")
    tfidf <-
      read_csv(filename)
  }else{
    
    if (!file.exists(filename)){
      print("no previous files found")
      
      setwd("~/projects/data")
      print(paste0("loading per-sentence word counts for period ", firstyear, "-", lastyear, "for", description))
      
      if(exists("associations")&&
         (unique(associations$level) == level) && 
         all(unlist(list1) %in% unique(associations$term)) &&
         (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
      ){      print("previously generated dataframe of word associations exists from running find_associations.  using it.")
      }else{
        if(!exists("associations")){
          filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
          setwd("~/projects/data")
          if(file.exists(filename1)){associations <- read_csv(filename1) %>% mutate(level = level)}
          
          if(!file.exists(filename1)){
            associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
              mutate(level = level)
            print("back in TFIDF_ASSOCIATIONS")}}}
      
      # at this point there should be a file called "associations". further 
      # computations are enacted on that file.
      
      if(level == "debate"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordsperdebate)) %>%
          select(term, word, n) 
      }
      
      if(level == "speech"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordsperspeech)) %>%
          ungroup() %>%
          select(term, word, n) }
      
      if(level == "sentence"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordspersentence)) %>%
          ungroup() %>%
          select(term, word, n) }
      
      tfidf <- context_count %>% 
        bind_tf_idf(word, term, n) %>%
        arrange(desc(tf_idf)) 
      
      print("saving tfidf as a universal variable")
      #save to global environment, just in case
      assign("tfidf", tfidf, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(tfidf, filename)
      
      
    }else{tfidf <- data.frame()}}
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(tfidf)
  
}


tfidf_comparison_alt <- function(list1, firstyear, lastyear, level, parallel, method){
  print("calling function TFIDF_COMPARISON_ALT")
  
  loadfrequencies(level)
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level, " with ", method
    )
  )
  
  print(paste0(
    "looking for previously gathered comparative tfidf about ",
    description
  ))
  
  
  filename <- paste0("tfidf_comparison_", description, "-", method, "_", firstyear, "-", lastyear, "_", level, ".csv")
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "reading in file: ", filename))
    setwd("~/projects/data")
    tfidf <-
      read_csv(filename)
  }else{
    
    if (!file.exists(filename)){
      print("no previous files found")
      
      setwd("~/projects/data")
      print(paste0("loading per-sentence word counts for period ", firstyear, "-", lastyear, "for", description))
      
      if(exists("associations")&&
         (unique(associations$level) == level) && 
         all(unlist(list1) %in% unique(associations$term)) &&
         (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
      ){      print("previously generated dataframe of word associations exists from running find_associations.  using it.")
      }else{
        if(!exists("associations")){
          filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
          setwd("~/projects/data")
          if(file.exists(filename1)){associations <- read_csv(filename1) %>% mutate(level = level)}
          
          if(!file.exists(filename1)){
            associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
              mutate(level = level)
            print("back in TFIDF_ASSOCIATIONS")}}}
      
      # at this point there should be a file called "associations". further 
      # computations are enacted on that file.
      
      if(level == "debate"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordsperdebate)) %>%
          select(term, word, n) 
      }
      
      if(level == "speech"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordsperspeech)) %>%
          ungroup() %>%
          select(term, word, n) }
      
      if(level == "sentence"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordspersentence)) %>%
          ungroup() %>%
          select(term, word, n) }
      
      tfidf <- context_count %>% 
        bind_tf_idf_alt(word, term, n, method) %>%
        arrange(desc(tf_idf)) 
      
      print("saving tfidf as a universal variable")
      #save to global environment, just in case
      assign("tfidf", tfidf, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(tfidf, filename)
      
      
    }else{tfidf <- data.frame()}}
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(tfidf)
  
}



tfidf_comparison_by_year <- function(list1, firstyear, lastyear, level, intervals, parallel){
  print("calling function TFIDF_COMPARISON_BY_YEAR")
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered comparative tfidf about ",
    description
  ))
  
  
  filename <- paste0("tfidf_comparison_by_year_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "previously generated file found.  reading in file: ", filename))
    tfidf <-
      read_csv(filename)
  }else{
    
    if (!file.exists(filename)){
      print(paste0("no previous files found by the name of ", filename))
      print(paste0("the next step is to gather collocate associations measurements for ", description))
      
      if(exists("associations")&&
         (unique(associations$level) == level) && 
         all(unlist(list1) %in% unique(associations$term)) &&
         (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
      ){ print("previously generated dataframe of word associations exists from running find_associations.  using it.")
      }else{
        if(!exists("associations")){
          print("no associations dataframe found")
          filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
          setwd("~/projects/data")
          print(paste0("looking for a file named ", filename1))
          if(file.exists(filename1)){print("file found; loading...")
            associations <- read_csv(filename1) %>% mutate(level = level)}
          
          if(!file.exists(filename1)){print(paste0("no file named ", filename1, " found"))
            associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
              mutate(level = level)
            print("back in TFIDF_ASSOCIATIONS")}}
      }
      
      # at this point there should be a file called "associations". further 
      # computations are enacted on that file.
      
      print("counting common collocates per term")
      if(level == "debate"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordsperdebate)) %>%
          ungroup() %>%
          select(period, term, word, n) 
      }
      
      if(level == "speech"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordsperspeech)) %>%
          ungroup() %>%
          select(period, term, word, n) 
      }
      
      if(level == "sentence"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordspersentence)) %>%
          ungroup() %>%
          select(period, term, word, n) }
      
      print("calculating tf_idf for each word-term pair")
      tfidf <- context_count %>%
        group_by(period) %>%
        bind_tf_idf(word, term, n) %>%
        ungroup() 
      
      print("saving tfidf as a universal variable")
      #save to global environment, just in case
      assign("tfidf", tfidf, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(tfidf, filename)
      
      
    }else{tfidf <- data.frame()}}
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(tfidf)
  
}


tfidf_associations_by_year <- function(list1, firstyear, lastyear, level, parallel) {
  print("calling function TFIDF_ASSOCIATIONS")
  
  loadfrequencies(level)
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered word associations about ",
    description
  ))
  
  
  filename <- paste0("tfidf_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "reading in file: ", filename))
    setwd("~/projects/data")
    tfidf3 <-
      read_csv(filename)
  } 
  
  if (!file.exists(filename)){ 
    print("no previous files found")
    
    setwd("~/projects/data")
    print(paste0("loading per-sentence word counts for period ", firstyear, "-", lastyear))
    
    filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
    setwd("~/projects/data")
    
    if(exists("associations")&&
       (unique(associations$level) == level) && 
       all(unlist(list1) %in% unique(associations$term)) &&
       (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
    ){      print("associations dataframe already exists. using it.") 
    }else{
      
      if(file.exists(filename1)){associations <- read_csv(filename1) %>% mutate (level = level)}
      
      if(!file.exists(filename1)){
        associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
          mutate(level = level)
        print("back in TFIDF_ASSOCIATIONS")}
    }
    
    # at this point there should be a file called "associations". further 
    # computations are enacted on that file.
    
    if (level == "speech") {
      setwd("~/projects/data")
      
      if(!exists("speechcounts")){load_frequencies(level)}
      
      speechcounts <- speechcounts %>%
        filter(year > firstyear) %>%
        filter(year < lastyear) %>%
        rename(wordsperspeech = n)
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      context_count <- associations %>%
        count(speech_id, term, word) %>%
        rename(wordsperspeech = n) 
      
      tfidf$speech_id <- as.integer(tfidf$speech_id)
      context_count$speech_id <- as.integer(context_count$speech_id)
      
      tfidf <- speechcounts %>%           
        filter(year > firstyear) %>%
        filter(year < lastyear) %>%
        filter(!is.na(speech_id)) #%>%
      #tfidf$term <- as.character(tfidf$speech_id)
      tfidf <- tfidf %>%
        anti_join(context_count, by = "speech_id") %>%
        rename(term = speech_id) %>%
        rename(wcount = wordsperspeech) %>%
        select(term, word, wcount, year)
      
    }
    
    if(level == "debate") {
      setwd("~/projects/data")
      
      if(!exists("debatecounts")){load_frequencies(level)}
      
      if("n" %in% colnames(debatecounts)){
        debatecounts <- debatecounts %>%
          rename(wordsperdebate = n) } 
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations)>0){
        context_count <- associations %>%
          count(debate_id, term, word)  %>%
          rename(wcount = n)
        context_count$debate_id <- as.integer(context_count$debate_id)
        
        tfidf <- debatecounts %>% 
          filter(year > firstyear) %>%
          filter(year < lastyear) %>%
          filter(!is.na(debate_id))
        
        tfidf$debate_id <- as.integer(tfidf$debate_id)
        
        tfidf <- tfidf %>% 
          anti_join(context_count, by = "debate_id") %>%
          rename(term = debate_id) %>%
          rename(wcount = wordsperdebate) %>%
          select(term, word, wcount, year)
      }else{tfidf <- data.frame()}
    } # end debate level
    
    
    
    if(level == "sentence"){
      
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(!exists("sentencecounts")){load_frequencies(level)}
      
      if(nrow(associations)>0){
        context_count <- associations %>%
          count(sentence_id, term, word) %>% 
          rename(wcount = n) 
        
        sentencecounts$sentence_id <- as.factor(sentencecounts$sentence_id)
        
        tfidf <- sentencecounts %>% 
          filter(year > firstyear) %>%
          filter(year < lastyear) %>%
          filter(!is.na(sentence_id)) 
        
        tfidf$sentence_id <- as.integer(tfidf$sentence_id)
        context_count$sentence_id <- as.integer(context_count$sentence_id)
        
        tfidf <- tfidf %>% 
          anti_join(context_count, by = "sentence_id") %>%
          rename(term = sentence_id) 
        
        tfidf <- tfidf %>%
          ungroup() %>%
          ungroup() %>%
          ungroup() %>%
          rename(wcount = wordspersentence) %>%
          select(term, word, wcount, year)
      }else{tfidf <- data.frame()}
    }# end instructions for sentence level
    
    tfidf <- tfidf %>%
      as_tibble()
    
    
    if(length(tfidf)>0){
      if(nrow(tfidf) > 0){
        
        print("joining variables context_count (context of terms) and tfidf (context of all debates)")
        context_count <- context_count %>%
          select(term, word, wcount) %>%
          mutate(term = as.character(term)) %>%
          mutate(word = as.character(word))
        
        print("turning everything into a character")
        tfidf$term <- as.character(tfidf$term)
        
        tfidf2 <- tfidf %>%
          bind_rows(context_count) %>%
          group_by(year, term, word) %>%
          summarize(n = sum(wcount)) %>%
          mutate(grouping = paste0(term, "-", year))
        
        tfidf3 <- tfidf2 %>%
          bind_tf_idf(word, grouping, wcount) %>%
          arrange(desc(tf_idf)) %>%
          group_by(term) %>%
          filter(!term == word) %>%
          ungroup()
        
        print("saving tfidf as a universal variable")
        #save to global environment, just in case
        assign("tfidf", tfidf3, envir=.GlobalEnv)
        
        setwd("~/projects/data")
        write.csv(tfidf3, filename)
        
        
      }else{tfidf3 <- data.frame()}
    }else{tfidf3 <- data.frame()}
  }#end instructions for generating tfidf3 if no previous file existed.
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(tfidf3)
  
}



loadsignificantwords <- function(hansard, firstyear, lastyear, samplesize){
  print("calling function LOADSIGNIFICANTWORDS")
  filename <- paste0("significantwords-", firstyear, "-", lastyear, "-", samplesize, ".csv")
  
  setwd("~/projects/data")
  if(file.exists(filename)){significantwords <- read_csv(filename)}else{
    
    if(parallel == TRUE){
      significantwords <- hansard %>%
        filter((year>firstyear)&(year<lastyear)) %>%
        unnest_parallel(1, TRUE) %>% # -- tokenize a sample into numwords-long ngrams
        count(word)
    }else{
      significantwords <- hansard %>%
        filter((year>firstyear)&(year<lastyear)) %>%
        unnest_tokens(word, text) %>%
        count(word) 
    }
    
    totalwordsinhansard <- sum(significantwords$n) 
    
    # blatt: significant words are those that appear at least 
    # 1/20000 words -- or roughly at least once in a novel?
    significantwords <- significantwords %>%
      filter(n > totalwordsinhansard/samplesize) %>% # this can be tweaked. 
      select(word)
    
    setwd("~/projects/data")
    write_csv(significantwords, filename)}
  
  return(significantwords)
}





collocate_comparison <- function(list1, firstyear, lastyear, level, parallel, method, significantwordscutoff){
  
  if(exists("tfidf")){rm("tfidf")}
  if(exists("tfidfsampleassociations")){rm("tfidfsampleassociations")}
  if(exists("tfidfcomparison")){rm("tfidfcomparison")}
  
  
  #baseline significance measure (used for honing tfidf-based measures, only takes a minute to run the first time)
  significantwords <- loadsignificantwords(hansard, firstyear, lastyear, significantwordscutoff)
  # significantwords calls the top n words from the corpus within the time period.
  
  
  if(!exists("sampleassociations")){
    ## raw count:
    sampleassociations <- find_associations(list1, firstyear, lastyear, level, FALSE)
  }
  
  ## collocates of each keyword in list1 differentially measured against all other documents in hansard (this is the trickiest mathematically and has the most moving parts as to code):
  tfidfsampleassociations <- tfidf_associations_alt(list1, firstyear, lastyear, level, FALSE, method) 
  
  ## collocates of each keyeword in list1 differentially measured against each other:
  tfidfcomparison <- tfidf_comparison_alt(list1, firstyear, lastyear, level, FALSE, method)
  
  
  # normalize some names
  # (you might be wondering why these observations are called different things;
  # the code find_associations is also used for comparisons of collocates
  # at different levels of context -- sentence, debate, etc. -- for which
  # it's important that the output have different names)
  if(level == "speech"){
    colnames(sampleassociations)[colnames(sampleassociations)=="wordsperspeech"] <- "n"
  }
  if(level == "debate"){
    colnames(sampleassociations)[colnames(sampleassociations)=="wordsperdebate"] <- "n"
  }
  if(level == "sentence"){
    colnames(sampleassociations)[colnames(sampleassociations)=="wordspersentence"] <- "n"
  }
  
  # graph just the raw collocate overview from sampleassociations
  sampleassociations %>%  inner_join(significantwords) %>% anti_join(stop_words) %>% filter(!stringr::str_detect(word, "\\d")) %>%
    group_by(term, word) %>% summarize(n = sum(n)) %>%
    # group_by(term) %>% arrange(desc(tf_idf)) %>% 
    slice(seq_len(50)) %>% ungroup() %>%
    ggplot(aes(x = reorder(word, n, sum), y = n)) +
    #ggplot(aes(x = reorder(word, tf_idf, sum), y = tf_idf)) +
    geom_col() +
    #scale_y_reordered() +
    facet_wrap(~term, scales = "free") +
    coord_flip() +
    labs(title = paste0("Collocates for Keywords"), 
         subtitle = paste0("Measured at the level of ", level, " by tfidf comparison between all terms"),
         caption = "Hansard's parliamentary debates of Great Britain",
         y = paste0("Word Pair that Appears Within the Same ", level),
         x = paste0("tf-idf score of statistical distinctiveness , ", firstyear, "-", lastyear))
  
  setwd("~/projects/visualizations")
  ggsave(paste0(list1, description, "-tfidf-comparison-top-collocates-tf-idf-ranked.pdf"),  w = 20, h = 20, units = "in")
  
  #measure the top collocates by three methods
  l1 <- sampleassociations %>% 
    group_by(term, word) %>%
    summarize(n = sum(n)) %>%
    anti_join(stop_words) %>%
    filter(!stringr::str_detect(word, "\\d")) %>%
    # mutate(period = year - year %% intervals) %>%
    group_by(term) %>%
    arrange(desc(n)) %>%
    slice(seq_len(10)) %>% ungroup() %>%
    rename(measure = n) %>%
    mutate(method = "raw-count") 
  
  l2 <- tfidfsampleassociations %>% 
    anti_join(stop_words) %>%
    inner_join(significantwords) %>%
    filter(term %in% list1[,1]) %>%
    filter(!stringr::str_detect(word, "\\d")) %>%
    group_by(term) %>%
    arrange(desc(tf_idf)) %>%
    slice(seq_len(10)) %>% 
    ungroup() %>%
    rename(measure = tf_idf) %>%
    mutate(method = "tfidf-cf-all-words-in-corpus")
  
  l3 <- tfidfcomparison %>%
    anti_join(stop_words) %>%
    filter(!stringr::str_detect(word, "\\d")) %>%
    group_by(term) %>%
    arrange(desc(tf_idf)) %>%
    slice(seq_len(10)) %>% 
    ungroup() %>%
    rename(measure = tf_idf) %>%
    mutate(method = "tfidf-cf-terms-in-list") %>%
    select(term, word, measure, method)
  
  bothlists <- bind_rows(l1, l2, l3)
  
  bothlists}


tfidf_comparison_by_year_alt <- function(list1, firstyear, lastyear, level, intervals, parallel, method){
  print("calling function TFIDF_COMPARISON_BY_YEAR")
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered comparative tfidf about ",
    description
  ))
  
  
  filename <- paste0("tfidf_comparison_by_year_", description, "-", method, "_", firstyear, "-", lastyear, "_", level, ".csv")
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "previously generated file found.  reading in file: ", filename))
    tfidf <-
      read_csv(filename)
  }else{
    
    if (!file.exists(filename)){
      print(paste0("no previous files found by the name of ", filename))
      print(paste0("the next step is to gather collocate associations measurements for ", description))
      
      if(exists("associations")&&
         (unique(associations$level) == level) && 
         all(unlist(list1) %in% unique(associations$term)) &&
         (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
      ){ print("previously generated dataframe of word associations exists from running find_associations.  using it.")
      }else{
        if(!exists("associations")){
          print("no associations dataframe found")
          filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
          setwd("~/projects/data")
          print(paste0("looking for a file named ", filename1))
          if(file.exists(filename1)){print("file found; loading...")
            associations <- read_csv(filename1) %>% mutate(level = level)}
          
          if(!file.exists(filename1)){print(paste0("no file named ", filename1, " found"))
            associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
              mutate(level = level)
            print("back in TFIDF_ASSOCIATIONS")}}
      }
      
      # at this point there should be a file called "associations". further 
      # computations are enacted on that file.
      
      print("counting common collocates per term")
      if(level == "debate"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordsperdebate)) %>%
          ungroup() %>%
          select(period, term, word, n) 
      }
      
      if(level == "speech"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordsperspeech)) %>%
          ungroup() %>%
          select(period, term, word, n) 
      }
      
      if(level == "sentence"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordspersentence)) %>%
          ungroup() %>%
          select(period, term, word, n) }
      
      print("calculating tf_idf for each word-term pair")
      tfidf <- context_count %>%
        group_by(period) %>%
        bind_tf_idf_alt(word, term, n, method) %>%
        ungroup() 
      
      print("saving tfidf as a universal variable")
      #save to global environment, just in case
      assign(paste0("tfidf-", method), tfidf, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(paste0("tfidf-", method), filename)
      
      
    }else{tfidf <- data.frame()}}
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(tfidf)
  
}


# tfidf_associations_by_year_alt <- function(list1, firstyear, lastyear, level, parallel, method){
#   print("calling function TFIDF_ASSOCIATIONS")
#   
#   loadfrequencies(level)
#   print(
#     paste0(
#       "beginning a function to calculate statistically differential word associations about ",
#       description,
#       " at the level of ",
#       level
#     )
#   )
#   
#   print(paste0(
#     "looking for previously gathered word associations about ",
#     description
#   ))
#   
#   
#   filename <- paste0("tfidf_", description, "-", method,  "_", firstyear, "-", lastyear, "_", level, ".csv")
#   setwd("~/projects/data")
#   
#   if (file.exists(filename)) {
#     print(paste0(
#       "reading in file: ", filename))
#     setwd("~/projects/data")
#     tfidf3 <-
#       read_csv(filename)
#   }
#   
#   if (!file.exists(filename)){ 
#     print("no previous files found")
#     
#     setwd("~/projects/data")
#     print(paste0("loading per-sentence word counts for period ", firstyear, "-", lastyear))
#     
#     filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
#     setwd("~/projects/data")
#     
#     if(exists("associations")&&
#        (unique(associations$level) == level) && 
#        all(unlist(list1) %in% unique(associations$term)) &&
#        (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
#     ){      print("associations dataframe already exists. using it.") 
#     }else{
#       
#       if(file.exists(filename1)){associations <- read_csv(filename1) %>% mutate (level = level)}
#       
#       if(!file.exists(filename1)){
#         associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
#           mutate(level = level)
#         print("back in TFIDF_ASSOCIATIONS")}
#     }
#     
#     # at this point there should be a file called "associations". further 
#     # computations are enacted on that file.
#     
#     if (level == "speech") {
#       setwd("~/projects/data")
#       
#       if(!exists("speechcounts")){load_frequencies(level)}
#       
#       speechcounts <- speechcounts %>%
#         filter(year > firstyear) %>%
#         filter(year < lastyear) %>%
#         rename(wordsperspeech = n)
#       
#       print(
#         paste0(
#           "doing a statistical analysis which words are differentially correlated to which term in the list about ",
#           description
#         )
#       )
#       
#       print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
#       context_count <- associations %>%
#         count(speech_id, term, word) %>%
#         rename(wordsperspeech = n) 
#       
#       tfidf$speech_id <- as.integer(tfidf$speech_id)
#       context_count$speech_id <- as.integer(context_count$speech_id)
#       
#       tfidf <- speechcounts %>%           
#         filter(year > firstyear) %>%
#         filter(year < lastyear) %>%
#         filter(!is.na(speech_id)) #%>%
#       #tfidf$term <- as.character(tfidf$speech_id)
#       tfidf <- tfidf %>%
#         anti_join(context_count, by = "speech_id") %>%
#         rename(term = speech_id) %>%
#         rename(wcount = wordsperspeech) %>%
#         select(term, word, wcount, year)
#       
#     }
#     
#     if(level == "debate") {
#       setwd("~/projects/data")
#       
#       if(!exists("debatecounts")){load_frequencies(level)}
#       ``
#       if("n" %in% colnames(debatecounts)){
#         debatecounts <- debatecounts %>%
#           rename(wordsperdebate = n) } 
#       
#       print(
#         paste0(
#           "doing a statistical analysis which words are differentially correlated to which term in the list about ",
#           description
#         )
#       )
#       print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
#       
#       if(nrow(associations)>0){
#         context_count <- associations %>%
#           count(debate_id, term, word)  %>%
#           rename(wcount = n)
#         context_count$debate_id <- as.integer(context_count$debate_id)
#         
#         tfidf <- debatecounts %>% 
#           filter(year > firstyear) %>%
#           filter(year < lastyear) %>%
#           filter(!is.na(debate_id))
#         
#         tfidf$debate_id <- as.integer(tfidf$debate_id)
#         
#         tfidf <- tfidf %>% 
#           anti_join(context_count, by = "debate_id") %>%
#           rename(term = debate_id) %>%
#           rename(wcount = wordsperdebate) %>%
#           select(term, word, wcount, year)
#       }else{tfidf <- data.frame()}
#     } # end debate level
#     
#     
#     
#     if(level == "sentence"){
#       
#       print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
#       
#       if(!exists("sentencecounts")){load_frequencies(level)}
#       
#       if(nrow(associations)>0){
#         context_count <- associations %>%
#           count(sentence_id, term, word) %>% 
#           rename(wcount = n) 
#         
#         sentencecounts$sentence_id <- as.factor(sentencecounts$sentence_id)
#         
#         tfidf <- sentencecounts %>% 
#           filter(year > firstyear) %>%
#           filter(year < lastyear) %>%
#           filter(!is.na(sentence_id)) 
#         
#         tfidf$sentence_id <- as.integer(tfidf$sentence_id)
#         context_count$sentence_id <- as.integer(context_count$sentence_id)
#         
#         tfidf <- tfidf %>% 
#           anti_join(context_count, by = "sentence_id") %>%
#           rename(term = sentence_id) 
#         
#         tfidf <- tfidf %>%
#           ungroup() %>%
#           ungroup() %>%
#           ungroup() %>%
#           rename(wcount = wordspersentence) %>%
#           select(term, word, wcount, year)
#       }else{tfidf <- data.frame()}
#     }# end instructions for sentence level
#     
#     tfidf <- tfidf %>%
#       as_tibble()
#     
#     
#     if(length(tfidf)>0){
#       if(nrow(tfidf) > 0){
#         
#         print("joining variables context_count (context of terms) and tfidf (context of all debates)")
#         context_count <- context_count %>%
#           select(term, word, wcount) %>%
#           mutate(term = as.character(term)) %>%
#           mutate(word = as.character(word))
#         
#         print("turning everything into a character")
#         tfidf$term <- as.character(tfidf$term)
#         
#         tfidf2 <- tfidf %>%
#           bind_rows(context_count) %>%
#           group_by(year, term, word) %>%
#           summarize(n = sum(wcount)) %>%
#           mutate(grouping = paste0(term, "-", year))
#         
#         tfidf3 <- tfidf2 %>%
#           bind_tf_idf_alt(word, grouping, wcount, method) %>%
#           arrange(desc(tf_idf)) %>%
#           group_by(term) %>%
#           filter(!term == word) %>%
#           ungroup()
#         
#         print("saving tfidf as a universal variable")
#         #save to global environment, just in case
#         assign(paste0("tfidf-", method), tfidf3, envir=.GlobalEnv)
#         
#         setwd("~/projects/data")
#         write.csv(tfidf3, filename)
#         
#         
#       }else{tfidf3 <- data.frame()}
#     }else{tfidf3 <- data.frame()}
#   }#end instructions for generating tfidf3 if no previous file existed.
#   
#   print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
#   return(tfidf3)
#   
# }

# TF-IDF function 

# this code allows 5 different idf weightings according to

# https://en.wikipedia.org/wiki/Tf%E2%80%93idf and an added method ("spread")




# ARCHITECTURE

# this code calls two functions 

# compute_idf(word,term,n,method) which computes the idf weights using the requested method 

# bind_tf_idf_alt(word,term,n,method) which combines the tf and idf weights and compute tf_idf

# outputs from this fn is exactly the same as bind_tf_idf output.

# the six weighting methods are: 

# 	"idf" (classical idf, same as binf_tf_idf), 

#	"unary" (equal weighted for all, i.e. ignore idf weights)

# 	"smooth" (similar to "idf", but not as extreme)

#     "max"  (similar to "smooth", but number of documents are adjusted based on words contained, need fixing)

# 	"prob" (log-odds, weight is 0 if word is contained 50/50 in the books/terms)

# 	"spread" (gives generous idf weights to words that are unique to a document,weight islog(N^3/n^2))

# idf weights are strictly >0 for "idf" and "spread". Others could be negative



# DEVELOPMENT

# bind_tf_idf_alt only has one tf calculation, Wikipedia lists 6 tf formulas, may want

# to include this in the future (i.e. build compute_tf function just like compute_idf).

# need to be tested for fixes and bugs

# required packcages


# begin calculation to compute idf weights

compute_idf<- function(data,word,term,n,method){
  
  
  # rename variables
  
  arguments <- as.list(match.call())
  
  term <- as.character(eval(arguments$term, data))
  
  word <- as.character(eval(arguments$word, data))
  
  n <- eval(arguments$n, data)
  
  tfidf_small<-data.frame(term=term,word=word,n=n)
  
  
  total_terms<-n_distinct(tfidf_small$term)
  
  
  # begin calculation for the 6 idf weighting methods
  
  if (method=="idf"){
    
    print("Use classical idf.")
    
    count_matrix<-cbind(c(a = tfidf_small$word,b = tfidf_small$term))
    
    idf<-data.frame(idf=log(total_terms/rowSums(count_matrix))) %>%
      
      rownames_to_column()%>% 
      
      rename(word=rowname) 
    
    
  } else if (method=="unary")  {
    
    print("Use unary idf.")
    
    idf <- tfidf_small %>% 
      
      group_by (word) %>%
      
      summarize(idf=1)
    
  } else if (method=="smooth") {
    
    print("Use smooth idf.")
    
    
    count_matrix<-cbind(c(a = tfidf_small$word,b = tfidf_small$term))
    
    
    idf<-data.frame(idf=log(total_terms/(1+rowSums(count_matrix)))) %>%
      
      rownames_to_column()%>% 
      
      rename(word=rowname) 
    
    
  } else if (method=="max") { 
    
    print("Use idf maximum.")
    
    count_terms<- tfidf_small %>% 
      
      group_by (word) %>%
      
      summarize(nterm=n_distinct(term))
    
    
    idf<- tfidf_small %>%
      
      left_join(count_terms,"word") %>%
      
      group_by (term) %>%
      
      mutate(idf=log(max(nterm)/(1+nterm))) %>%
      
      select(-n,-nterm) 
    
  } else if (method=="prob") {
    
    print("Use probabilistic idf.")
    
    count_matrix<-cbind(c(a = tfidf_small$word,b = tfidf_small$term))
    
    idf<-data.frame(idf=log(total_terms/rowSums(count_matrix)-1)) %>%
      
      rownames_to_column()%>% 
      
      rename(word=rowname) 
    
    
  }  else if (method=="spread") {
    
    print("Use spread idf.")
    
    count_matrix<-cbind(c(a = tfidf_small$word,b = tfidf_small$term))
    
    idf<-data.frame(idf=log(total_terms^3/rowSums(count_matrix)^2)) %>%
      
      rownames_to_column()%>% 
      
      rename(word=rowname) 
    
  }
  
  return(idf)
  
}


# begin function to join tf & idf and compute tf_idf

bind_tf_idf_alt<-function(data,word,term,n,method) {
  
  
  # rename variables
  
  arguments <- as.list(match.call())
  
  term <- as.character(eval(arguments$term, data))
  
  word <- as.character(eval(arguments$word, data))
  
  n <- eval(arguments$n, data)
  
  tfidf_small<-data.frame(term=term,word=word,n=n)
  
  
  
  total_terms<-n_distinct(tfidf_small$term)
  
  if(method=="max"){join_key <-c("word","term")
  
  }else {join_key<-c("word")}
  
  
  tf<- tfidf_small %>% 
    
    group_by (term) %>%
    
    mutate(tf=n/sum(n))
  
  
  tfidf_join <- tf %>%
    
    left_join(compute_idf(tfidf_small,word,term,n,method),join_key) %>%
    
    mutate(tf_idf=tf*idf) %>%
    
    as_tibble()
  
  
  tfidf_join$term<-as.character(tfidf_join$term)
  
  tfidf_join$word<-as.character(tfidf_join$word)
  
  colnames(tfidf_join)<-c(paste(arguments$term),paste(arguments$word),paste(arguments$n),"tf","idf","tf_idf")
  
  return(tfidf_join)
  
}


# count words per day
wordcount_per_day <- function(d, dummyvar){
  
  d2 <- d %>% select("Date", "Text") %>% as.data.frame()
  
  d2 <- d2 %>% 
    dplyr::rename(speechdate = Date) %>%
    dplyr::rename(text = Text) %>%
    mutate(speechdate = lubridate::ymd(speechdate)) %>%
    mutate(text = as.character(text))
  
  print("unnesting")
  tidyhans <- tidyhansard(d2, FALSE)
  
  print("counting wordsperday")
  wordsperday <- tidyhans %>% select(speechdate, word) %>%
    group_by(speechdate) %>%
    dplyr::summarize(count = n()) %>%
    filter(!is.na(count)) %>%
    arrange(desc(count))
  
  wordsperday$weekdayf <-
    factor(
      weekdays(wordsperday$speechdate, abbreviate = T),
      levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
      labels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"),
      ordered = TRUE
    )
  wordsperday$monthf <-
    factor(
      lubridate::month(wordsperday$speechdate),
      levels = as.character(1:12),
      labels = c(
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ),
      ordered = TRUE
    ) # finding the month
  wordsperday$yearmonth <-
    factor(zoo::as.yearmon(wordsperday$speechdate)) # finding the year and the month from the date. Eg: Nov 2018
  wordsperday$week <-
    as.numeric(
      format(wordsperday$speechdate, "%W"),
      breaks = c(1, 2, 3, 4, 5),
      levels = (1:5),
      ordered = TRUE
    ) # finding the week of the year for each date
  wordsperday$year <- lubridate::year(wordsperday$speechdate)
  wordsperday$period <- wordsperday$year - wordsperday$year %% 10
  wordsperday
}


partial.jsd1 <- function(p, q){ p* log(p/((p+q)/2)) }

bind_jsd <- function(df, word, debate_id, count, period, last1){
  
  df <- df %>% mutate(periodnumber = group_indices(., as.character(period)))
  
  firstyear <- min(tidyhans$year)
  # count each word in the past
  x1 <- tidyhans %>%
    filter(year == firstyear) %>%
    count(word) %>% arrange(desc(word)) %>%
    mutate(past1 = estimate.probability(n)) # calculate the probability based on counts
  
  # count each word in the current period
  x2 <- df %>%
    filter(periodnumber == 1) %>%
    arrange(desc(word)) %>%
    mutate(present1 = estimate.probability(count)) #%>% # calculate the probability based on counts
  
  
  # this matches up rows by word
  df1 <- x1 %>%
    full_join(x2, by = "word") %>%
    select(word, present1, past1) %>%  
    mutate_all(funs(replace(., is.na(.), 0)))
  df1
  
  
  ## partial jsd is useful for comparing words
  
  # take the jsd of two periods
  f<- df1 %>%
    mutate(jsd = partial.jsd1(present1, past1)) %>%
    arrange(desc(jsd))
  str(f)
  
  newdf <- f %>%
    mutate(periodnumber = 1)
  
  
  for(period1 in 2:max(df$periodnumber)){
    
    # count each word in the past
    if(last1 == TRUE) {
      x1 <- df %>%
        filter(periodnumber == (period1-1)) %>%
        arrange(desc(word)) %>%
        mutate(past1 = estimate.probability(count))}else{
          x1 <- df %>%
            filter(periodnumber < period1) %>%
            group_by(word) %>%
            summarize(count = sum(count)) %>%
            mutate(past1 = estimate.probability(count))
        } # calculate the probability based on counts
    
    # count each word in the current period
    x2 <- df %>%
      filter(periodnumber == period1) %>%
      arrange(desc(word)) %>%
      mutate(present1 = estimate.probability(count)) #%>% # calculate the probability based on counts
    
    # this matches up rows by word
    df1 <- x1 %>%
      full_join(x2, by = "word") %>%
      select(word, past1, present1) %>%
      mutate_all(funs(replace(., is.na(.), 0))) # replace na's w 0 
    df1
    
    ## partial jsd is useful for comparing words
    # take the jsd of two periods
    f<- df1 %>%
      mutate(jsd = partial.jsd1(present1, past1)) %>%
      arrange(desc(jsd))
    str(f)
    
    f22<- f %>%
      anti_join(stop_words) %>%
      mutate(periodnumber = period1)
    
    newdf <- newdf %>% bind_rows(f22)
    
  }
  
  newdf<- newdf %>%
    anti_join(stop_words) %>%
    inner_join(df)# by = c("periodnumber", "word"))
  
  newdf
}

quantedafy <- function(hansard, target, dict1name, stemmed){
  library(textstem)
  
  cat(paste0("making Hansard into a Quanteda corpus, working at the level of ", target))
  if(target == "debate"){
    hansardready <- hansard %>% 
      select(sentence_id, debate, year, speaker) %>%
      mutate(debate = tolower(debate))
    
    if(stemmed == TRUE){
    hansardready$stemmed <-
      lemmatize_words(hansardready$debate)
    }else{    hansardready$stemmed <-
     hansardready$debate}
    
    hansardcorp <- corpus(hansardready, docid_field = "sentence_id", 
                          text_field = "stemmed")
  }
  
  if(target == "text"){
    hansardready <- hansard %>% 
      select(sentence_id, text, year, speaker) %>%
      mutate(text = tolower(text))
    
    if(stemmed == TRUE){
    hansardready$stemmed <-
      lemmatize_words(hansardready$text)}else{    hansardready$stemmed <-
        hansardready$text}
    
    hansardcorp <- corpus(hansardready, docid_field = "sentence_id", 
                          text_field = "stemmed")
  }
  
  cat(paste0("using dictionary ", dict1name, " to look up words in Hansard"))

  if(stemmed == FALSE){
  ##without stemming
count1 <- dfm(tokens_lookup(tokens(hansardcorp,
                                   remove_hyphens = TRUE
                                   ),
                            dictionary = get(dict1name),
                            valuetype = "fixed",
                            exclusive = TRUE,
                            case_insensitive = TRUE,
                            nested_scope = "dictionary"),
              stem = TRUE)
  }
  
  if(stemmed == TRUE){
  #### with stemming
  count1 <- 
    dfm(
      quanteda::tokens_lookup(  #Steph added quanteda:: while debugging
        quanteda::tokens_wordstem(  #Steph added quanteda:: while debugging
          quanteda::tokens(hansardcorp, #Steph added quanteda:: while debugging
                 remove_hyphens = TRUE,
                 remove_separators = TRUE)
        ),
        valuetype = "glob",
        exclusive = TRUE,
        dictionary = get(dict1name),
        case_insensitive = TRUE,
        nested_scope = "dictionary"
      ),
      tolower = TRUE
    )
  }
  
  cat("making the results tidy")
  tidyregions <- tidy(count1) 
  
  cat("returning tidy output, end of loop")
  tidyregions
}


gen_classifier <- function() {
  setwd("~/projects/data")
  library(readr)
  sentiment <- get_sentiments(lexicon = "bing")
  
  
  
  govwords <- c("attorney", "court",  "attorney", "money",
                "gentleman", "noble", "respect", "sir", 
                "hope", "question", "feeling", "doubt", "general",
                "subject", "found", "statement", "parliament",
                "prepared", "law", "authority", "majority",
                "importance", "thought", "land", "leave", "measure", 
                "policy", "speech", "weight", "liberty", "possession",
                "justice", "word", "fact", "treat", "highest", "argument",
                "concerned", "late", "bad", "discussion", "owing", 
                "objection", "disposed", "expect", "system", "limited",
                "display", "delay", "powerful", "anxious", "forward",
                "interest", "loss", "reason", "intended", "chancellor",
                "grant", "earl", "engaged", "information", "responsible",
                "attention", "long", "real", "facts", "operation", "opposed",
                "sentence", "judicial", "majesty", "established", "immediately",
                "county", "considerable", "action", "united", "confined", "legal",
                "received", "liberal", "tribunal", "foreign", "ground", "result",
                "confess", "discretion", "continue", "proposition", "agreed",
                "fully", "share", "possess", "pledge", "cabinet", "supremacy",
                "promise", "agree", "sense", "commit", "judgment", "credit",
                "possessed", "full", "title", "president", "minister", 
                "constitutional", "remove", "withdraw", "intelligence", "procedure",
                "understanding", "knowledge", "providing", "officer", "guarantee",
                "cross", "prevent", "john", "chairman", "proceeding", "reform",
                "organization", "nation", "civil", "colonel", "prime",
                "good", "pay", "salary", "church", "beer", 
                "university", "public", "council", "planning", 
                "secular", "retirement", "militia", "battalion", "force",
                "wages", "pollution", "marriage", "military", "opium",
                "closure","soil", "instructions", "ship", "spirits", "farm", 
                "letter", "applicant", "mail", "income", "coercion", 
                "morrow", "excluded", "perpetuity", "prison", "prisoner", "prisoners",
                "prisons", "ballot", "war", "slavery", "slave", "slaves", "rifle", "morrow", 
                "insolvency", "police", "execution", "amnesty", 
                "armaments", "penal", "damages", "sultan", "protestant", 
                "socialism", "improvement", "hospital", "rating", 
                "hanging", "criminal", "crime", "imprisonment", "black", 
                "time", "words", "change", "rule", "plan", "motion", 
                "examination", "vote", "perjury", "opposition", "kind", 
                "friend", "member", "committee", "investigation", 
                "board", "inquiry", "present", "lord", "government",
                "special", "appeal", "case", "bonus", "advance", "deal", "tax")
  s2 <- sentiment %>%
    dplyr::filter(!(word %in% govwords)) %>% # changed (and also the other)
    dplyr::mutate(kind = "sentiment") %>%
    dplyr::mutate(Geography = "NA", Empire = "NA") %>%
    dplyr::rename(node = word) %>% 
    dplyr::rename(cat = sentiment) 
  
  traits <- read_csv("wordnet-traits.csv") 
  traits <- traits %>%
    as.data.frame() %>%
    dplyr::rename(node = term) %>%
    mutate(kind = "trait") %>%
    mutate(Geography = "NA", Empire = "NA") %>%
    select(node, kind, Geography, Empire, cat)
  
  phenomena <- read_csv("wordnet-phenomena.csv") 
  phenomena <- phenomena %>%
    dplyr::rename(node = term) %>%
    mutate(kind = "phenomena") %>%
    mutate(Geography = "NA", Empire = "NA") %>%
    select(node, kind, Geography, Empire, cat)
  
  nations <- read_csv("collaborative_nations.csv")
  nations2 <- nations %>%
    select(Nation_Base, Geography, Empire) %>%
    dplyr::rename(node = Nation_Base) %>%
    mutate(kind = "nations",  cat = "NA") %>%
    select(node, kind, Geography, Empire, cat)
  cities <- read_csv("collaborative_cities.csv")
  cities2 <- cities %>%
    select(City_Base, Geography, Empire) %>%
    dplyr::rename(node = City_Base) %>%
    mutate(kind = "cities") %>%
    mutate( cat = "NA") %>%
    select(node, kind, Geography, Empire, cat)
  concerns <- read_csv("concerns.csv")
  concerns2 <- concerns %>%
    dplyr::rename(node = concerns) %>%
    mutate(kind = "concern") %>%
    mutate(Geography = "NA", Empire = "NA",  cat = "NA") %>%
    select(node, kind, Geography, Empire, cat)
  classes <- read_csv("classes.csv")
  classes2 <- classes %>%
    dplyr::rename(node = classes) %>%
    mutate(kind = "class") %>%
    mutate(Geography = "NA", Empire = "NA", cat = "NA") %>%
    select(node, kind, Geography, Empire, cat)
  offices <- read_csv("offices.csv")
  offices2 <- offices %>% dplyr::rename(node = offices) %>%
    dplyr::mutate(kind = "office") %>%
    mutate(Geography = "NA", Empire = "NA", cat = "NA") %>%
    select(node, kind, Geography, Empire, cat)
  setwd("~/projects/data")
  traits <- read_csv("traitdict.csv") %>%
    select(word, cat) %>%
    dplyr::rename(node = word) %>%
    mutate(kind = "trait") %>%
    mutate(Geography = "NA", Empire = "NA")
  
  property <- read_csv("propertywords.csv")
  names(property) <- "node" 
  property <- property %>%
    mutate(kind = "property") %>%
    mutate(cat = "NA") %>%
    mutate(Geography = "NA", Empire = "NA")
  
  phenomena <- read_csv("phenomenadict.csv") %>%
    select(word, cat) %>%
    dplyr::rename(node = word) %>%
    mutate(kind = "phenomena") %>%
    mutate(Geography = "NA", Empire = "NA")  
  
  gen_classifier <-
    rbind(nations2, cities2, concerns2, offices2, classes2, s2, property, 
          phenomena, traits)
  gen_classifier <- gen_classifier %>%
    group_by(node) %>%
    sample_n(1) %>%
    ungroup() %>%
    mutate(
      node = tolower(node),
      empire = stringr::str_to_title((Empire)),
      geography = stringr::str_to_title((Geography))
    ) %>%
    select(-Geography, -Empire)
  assign("gen_classifier", gen_classifier, envir = .GlobalEnv)
  gen_classifier
}


produce_dictionary <- function(stemmed){
  library(quanteda)
  library(readr)
  library(tm)
  library(tidytext)
  library(textdata) # Citation: url = {https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1467-8640.2012.00460.x},
  
  description <- "full-dictionary"
  target <- "text" # debate or text
  
  # read in data
  sentiment <- get_sentiments(lexicon = "bing")
  govwords <- c("attorney", "court",  "attorney", "money",
                "gentleman", "noble", "respect", "sir", 
                "hope", "question", "feeling", "doubt", "general",
                "subject", "found", "statement", "parliament",
                "prepared", "law", "authority", "majority",
                "importance", "thought", "land", "leave", "measure", 
                "policy", "speech", "weight", "liberty", "possession",
                "justice", "word", "fact", "treat", "highest", "argument",
                "concerned", "late", "bad", "discussion", "owing", 
                "objection", "disposed", "expect", "system", "limited",
                "display", "delay", "powerful", "anxious", "forward",
                "interest", "loss", "reason", "intended", "chancellor",
                "grant", "earl", "engaged", "information", "responsible",
                "attention", "long", "real", "facts", "operation", "opposed",
                "sentence", "judicial", "majesty", "established", "immediately",
                "county", "considerable", "action", "united", "confined", "legal",
                "received", "liberal", "tribunal", "foreign", "ground", "result",
                "confess", "discretion", "continue", "proposition", "agreed",
                "fully", "share", "possess", "pledge", "cabinet", "supremacy",
                "promise", "agree", "sense", "commit", "judgment", "credit",
                "possessed", "full", "title", "president", "minister", 
                "constitutional", "remove", "withdraw", "intelligence", "procedure",
                "understanding", "knowledge", "providing", "officer", "guarantee",
                "cross", "prevent", "john", "chairman", "proceeding", "reform",
                "organization", "nation", "civil", "colonel", "prime",
                "good", "pay", "salary", "church", "beer", 
                "university", "public", "council", "planning", 
                "secular", "retirement", "militia", "battalion", "force",
                "wages", "pollution", "marriage", "military", "opium",
                "closure","soil", "instructions", "ship", "spirits", "farm", 
                "letter", "applicant", "mail", "income", "coercion", 
                "morrow", "excluded", "perpetuity", "prison", "prisoner", "prisoners",
                "prisons", "ballot", "war", "slavery", "slave", "slaves", "rifle", "morrow", 
                "insolvency", "police", "execution", "amnesty", 
                "armaments", "penal", "damages", "sultan", "protestant", 
                "socialism", "improvement", "hospital", "rating", 
                "hanging", "criminal", "crime", "imprisonment", "black", 
                "time", "words", "change", "rule", "plan", "motion", 
                "examination", "vote", "perjury", "opposition", "kind", 
                "friend", "member", "committee", "investigation", 
                "board", "inquiry", "present", "lord", "government",
                "special", "appeal", "case", "bonus", "advance", "deal", "tax")
  
  
  
  
  s2 <- sentiment %>%
    filter(!(word %in% govwords)) %>% 
    select(word) %>%
    mutate(sentiment = word)
  
  
  setwd("~/projects/data")
  traits <- read_csv("traitdict.csv") %>%
    select(word) %>%
    mutate(sentiment = word)
  
  phenomena <- read_csv("phenomenadict.csv") %>%
    select(word) %>%
    mutate(sentiment = word)

  nations <- read_csv("collaborative_nations.csv")
  n2 <- nations %>%
    select(Nations, Nation_Base)%>%
    rename(word = Nations, sentiment = Nation_Base) 
  
  cities <- read_csv("collaborative_cities.csv")
  c2 <- cities %>%
    select(Cities, City_Base) %>%
    rename(word = Cities, sentiment = City_Base) 
  
  concerns <- read_csv("concerns.csv")
  classes <- read_csv("classes.csv")
  offices <- read_csv("offices.csv")
  property <- read_csv("propertywords.csv")
  
  property <- read_csv("propertywords.csv")
  names(property) <- "word" 
  e1 <- property %>%
    mutate(sentiment = word)
  
  d1 <- concerns %>% 
    select(concerns) %>%
    rename(word = concerns) %>%
    mutate(sentiment = word)
  d2 <- classes %>% 
    select(classes) %>%
    rename(word = classes) %>%
    mutate(sentiment = word)
  d3 <- offices %>% 
    select(offices) %>%
    rename(word = offices) %>%
    mutate(sentiment = word)

  fulldict <- bind_rows(n2, c2, d1, d2, d3, e1, s2, traits, phenomena) %>% 
    mutate(word = tolower(word)) %>%
    mutate(sentiment = tolower(sentiment)) #%>%
   # as.dictionary()
  
  library(textstem)

  if(stemmed == TRUE){
  fulldict$stem <-
    lemmatize_words(fulldict$sentiment) }else{fulldict$stem <- fulldict$sentiment}

  fulldict <- as_tibble(fulldict)
  
  #names(fd) <- "sentiment"
  
  fulldict <- fulldict %>% mutate(word = stem)%>%
    as.dictionary()
  
  assign("fulldict", fulldict, envir = .GlobalEnv)
  fulldict
}

quantedafy_hansard <- function(hansard, stemmed){
  library(quanteda)
  library(readr)
  
  for (target in c("text", "debate"
  )) {
    description <- "fulldict"
    dict1name <- "fulldict"
    tidyresults <- quantedafy(hansard, target, "fulldict", stemmed)
    
    cat("saving a file of tidy output in the data directory")
    setwd("~/projects/data")
    write_csv(tidyresults, paste0(dict1name, "-", target, "-", stemmed, "fromquanteda.csv"))
    
  }
  
}

load_classified_results <- function(target){
  library(readr)
  setwd("~/projects/data")
  r1 <-
    read_csv(paste0("fulldict-", target, "fromquanteda.csv"))
  
  setwd("~/projects/code")
  source("wordcount-functions.R")
  gen_classifier <- gen_classifier()
  classified_results <- r1 %>% 
    left_join(gen_classifier, by = c("term" = "node"))
  
  assign("classified_results", classified_results, envir = globalenv())
  
  classified_results
}


entities_per_yr <- function(classified_results, cat1, target, gen_classifier){
  # iteratively generate visualizations

  assign("target", target, envir = globalenv())
  assign("cat1", cat1, envir = globalenv())
  assign("gen_classifier", gen_classifier, envir = globalenv())
  

if(target == "debate"){target_description <- "debate title"}
if(target == "text"){target_description <- "text"}

if(cat1 == "nations"){gendescription <- "geographical entities and ethnicities"}else{gendescription <- cat1}
setwd("~/projects/data")
assign("target_description", target_description, envir = globalenv())
assign("gendescription", gendescription, envir = globalenv())

  
  df <- classified_results %>%
    filter(kind == cat1)
  assign("df", df, envir = globalenv())
  setwd("~/projects/code")
  source("counting_entities_per_yr_after_Q.R")
  
  docdate <- hansard %>%
    select(sentence_id, debate_id, speechdate, year)
  
  
  df <- df %>% rename(sentence_id = document) 
  
  df <- df %>%
    left_join(docdate, by = "sentence_id")
  
  assign("df", df, envir = .GlobalEnv)
  
  setwd("~/projects/code")
  setwd(paste0("~/projects/code")) # changed from: setwd(paste0("~/projects/code", "/semantic_network"))
  source("qdata-semantic-net-4.R")
  
  setwd("~/projects/code")
  setwd(paste0("~/projects/code")) # changed from: setwd(paste0("~/projects/code", "/semantic_network"))
  source("visualize-semantic-network.R")
  
  
  df
}


two_entities_network <- function(classified_results, cat1, cat2, target, gen_classifier) {
  
  if(cat1 == "nations"){gendescription <- "geographical entities and ethnicities"}else{
    gendescription<- cat1
  }
  
  if(cat2 == "nations"){gendescription2 <- "geographical entities and ethnicities"}else{  gendescription2 <- cat2
  }
  if(target == "debate"){target_description <- "debate title"}
  if(target == "text"){target_description <- "text"}
  setwd("~/projects/data") 
  assign("target", target, envir = globalenv())
  assign("cat1", cat1, envir = globalenv())
  assign("gen_classifier", gen_classifier, envir = globalenv())
  assign("cat2", cat2, envir = globalenv())
  assign("gendescription2", gendescription2, envir = globalenv())
  assign("target_description", target_description, envir = globalenv())
  assign("gendescription", gendescription, envir = globalenv())
  
  ## adding this temp code to fix classified results so there isn't kind.x and kind.y
  classified_results <- classified_results %>%
    rename(kind = kind.x,
           cat = cat.x,
           empire = empire.x,
           geography = geography.x)
  
  
  results1 <- classified_results %>%
    filter(kind == cat1)

  results2 <- classified_results %>%
    filter(kind == cat2)
  if(cat1 == cat2){print("skipping")}else{
    
    df <- rbind(results1, results2) %>%
     # filter(stringr::str_length(term) > 5) %>% # temporary - eliminate 'be' which is in concerns at present
      filter(!is.na(count)) %>%
      filter(!is.na(term)) 
    
    docdate <- hansard %>%
      select(sentence_id, debate_id, speechdate, year)
    
    
    df <- df %>% rename(sentence_id = document) 
    
    df <- df %>%
      left_join(docdate, by = "sentence_id")
    
    assign("df", df, envir = .GlobalEnv)
    
    setwd(paste0("~/projects/code")) # changed from : setwd(paste0("~/projects/code", "/semantic_network"))
    source("qdata-semantic-net-2-categories-alt.R")
    setwd(paste0("~/projects/code")) # changed from : setwd(paste0("~/projects/code", "/semantic_network"))
    source("visualize-network-2-categories.R")
    
  }
}


toolongpairs <- function(toolong, bridgecategories){
  # filter out any instances of toolong that don't have at 
  # least one entry for both categories
  # toolongcat1 <- toolong %>% filter(term %in% results1$term) %>%
  #   count(sentence_id) %>%
  #   rename(cat1count = n)
  # toolongcat2 <- toolong %>% filter(term %in% results2$term) %>%
  #   count(sentence_id) %>%
  #   rename(cat2count = n)
  # 
  # toolong1 <- toolong %>% left_join(toolongcat1) %>%
  #   mutate(cat1count = replace_na(cat1count, 0)) %>%
  #   filter(cat1count > 0) %>%
  #   left_join(toolongcat2) %>%
  #   mutate(cat2count = replace_na(cat2count, 0)) %>%
  #   filter(cat2count > 0)
  
  # deal with toolong
  toolong1 <- toolong %>% 
    group_by(sentence_id) %>%
    dplyr::mutate(grouping = 
                    dplyr::group_indices())
  
  longresults <- data.frame()
  
  for(g in seq(from = min(toolong1$grouping), to = max(toolong1$grouping), by = 1)){
    
    longdf1 <- toolong1 %>% 
      filter(grouping == g) 
    #### import results and turn into a network.
    # import results and limit to those in classifier
    longterms <- longdf1 %>%
      distinct(speechdate, debate_id, sentence_id, term, count) %>%
      dplyr::group_by(debate_id, sentence_id, term) %>%
      dplyr::summarize(count = sum(count)) %>%
      ungroup() %>%
      ungroup() 

    longtermsinpairs <- longterms %>%
      dplyr::group_by(sentence_id) %>%
      dplyr::mutate(numterms = dplyr::n()) %>%
      ungroup() %>%
      filter(numterms > 1) %>%
      select(-numterms)
    
    
    longuniqueterms <- longdf1 %>%
      group_by(term) %>% 
      sample_n(1) %>%
      ungroup() %>%
     # select(term, kind, geography, empire)  %>%
      filter(term %in% longtermsinpairs$term)
    
    # get pairwise counts
    # assemble a tibble with all the pairs
    longpairs1 <- longtermsinpairs %>% 
      dplyr::group_by(sentence_id) %>% 
      expand(sentence_id, from = term, to = term) %>%  # crossing? expand?
      filter(from < to) %>%
      ungroup()       
    
    # create edges
    longedges <- longpairs1 %>%
      filter(!is.na(from)) %>%
      filter(!is.na(to)) %>%
      group_by(from, to) %>%
      dplyr::summarize(weight = dplyr::n()) %>%
      filter(weight > 0) %>%
      ungroup()
    
    #optional: filter for cat1-cat2
    if(bridgecategories == TRUE) {
      classifier1 <- gen_classifier %>% filter(kind == cat1) %>%
        rename(term = node)
      classifier2 <- gen_classifier %>% filter(kind == cat2) %>%
        rename(term = node)
      longedges1 <- longedges %>%
        filter(!is.na(from)) %>%
        filter(!is.na(to)) %>%
        filter(from %in% classifier1$term) %>%
        filter(to %in% classifier2$term)
      longedges2 <- longedges %>%
        filter(!is.na(from)) %>%
        filter(!is.na(to)) %>%
        filter(from %in% classifier2$term) %>%
        filter(to %in% classifier1$term)
      longedges <- rbind(longedges1, longedges2)
    }
    
    #make nodes
    longnodes <- longuniqueterms %>% 
      rename(node = term) %>%
      filter((node %in% longedges$from)|(node %in% longedges$to)) #%>%

    # add id numbers to nodes
    longnodes <- longnodes %>%
      dplyr::mutate(id = speech_id()) 
    
    # match edges with names of nodes
    longedges <- longedges %>%
      dplyr::left_join(longnodes, by=c("from" = "node")) %>%
      dplyr::rename(from_name = from) %>%
      dplyr::rename(from = id) %>%
      dplyr::left_join(longnodes, by=c("to" = "node")) %>%
      dplyr::rename(to_name = to) %>%
      dplyr::rename(to = id) %>%
      dplyr::select(from, to, from_name, to_name, weight) 
    
    # putin the proper order
    longedges <- longedges %>% 
      dplyr::mutate(from = as.integer(from)) %>%
      dplyr::mutate(to = as.integer(to)) %>% 
      dplyr::select(from, to, from_name, to_name, weight) 
    longedges
    
    
        if(nrow(longedges)>0) {
      longresults <- bind_rows(longresults, longedges)
    }
  }
  write_csv(longresults, paste0("longresults-", cat1, "-", cat2, "-", target, "_pairwise_edges.csv"))

return(longresults)
}

findpairs <- function(df1, bridgecategories){     
  #bridgecategories == TRUE means that edges will be filtered for
  #having one cat1 and one cat2; otherwise, cat1/cat2 are ignored
  
  #### import results and turn into a network.
  # import results and limit to those in classifier
  terms <- df1 %>%
    distinct(speechdate, debate_id, sentence_id, term, count) %>%
    dplyr::group_by(debate_id, sentence_id, term) %>%
    dplyr::summarize(count = sum(count)) %>%
    ungroup() %>%
    ungroup()
  
  termsinpairs <- terms %>%
    dplyr::group_by(sentence_id) %>%
    dplyr::mutate(numterms = dplyr::n()) %>%
    ungroup() %>%
    filter(numterms > 1) %>%
    select(-numterms)
  
  uniqueterms <- df1 %>%
    group_by(term) %>% 
    sample_n(1) %>% ungroup() %>%
    #select(term, kind, geography, empire) %>%
    filter(term %in% termsinpairs$term)
  
  # assemble a tibble with all the pairs
  pairs1 <- termsinpairs %>% 
    dplyr::group_by(sentence_id) %>% 
    expand(sentence_id, from = term, to = term) %>% 
    filter(from < to) %>% # the "expander": creates pairwise matches
    ungroup()
  
  # create edges
  edges <- pairs1 %>%
    filter(!is.na(from)) %>%
    filter(!is.na(to)) %>%
    group_by(from, to) %>%
    dplyr::summarize(weight = dplyr::n()) %>%
    filter(weight > 0) %>%
    ungroup()
  
  #optional: filter for cat1-cat2
  if(bridgecategories == TRUE) {
    classifier1 <- gen_classifier %>% filter(kind == cat1) %>%
      rename(term = node)
    classifier2 <- gen_classifier %>% filter(kind == cat2) %>%
      rename(term = node)
    edges1 <- edges %>%
      filter(!is.na(from)) %>%
      filter(!is.na(to)) %>%
      filter(from %in% classifier1$term) %>%
      filter(to %in% classifier2$term)
    edges2 <- edges %>%
      filter(!is.na(from)) %>%
      filter(!is.na(to)) %>%
      filter(from %in% classifier2$term) %>%
      filter(to %in% classifier1$term)
    edges <- rbind(edges1, edges2)
  }
  
  # retain only the nodes that are in edge pairs
  nodes <- uniqueterms %>% 
    rename(node = term) %>%
    filter((node %in% edges$from)|(node %in% edges$to)) %>%
    select(node) %>% distinct()
  
  # add id numbers to nodes
  nodes <- nodes %>%
    dplyr::mutate(id = speech_id()) 
  
  # match edges with names of nodes
  edges <- edges %>%
    dplyr::left_join(nodes, by=c("from" = "node")) %>%
    dplyr::rename(from_name = from) %>%
    dplyr::rename(from = id) %>%
    dplyr::left_join(nodes, by=c("to" = "node")) %>%
    dplyr::rename(to_name = to) %>%
    dplyr::rename(to = id) %>%
    dplyr::select(from, to, from_name, to_name, weight) %>%
    filter(!is.na(from)) %>%
    filter(!is.na(to)) 
  
  # putin the proper order
  edges <- edges %>% 
    dplyr::mutate(from = as.integer(from)) %>%
    dplyr::mutate(to = as.integer(to)) %>% 
    dplyr::select(from, to, from_name, to_name, weight) 
  edges
}

generate_nodes <- function(edges0){
  # extract node information from edges record
  n1 <- edges0 %>% distinct(to_name) %>%
    rename(node = to_name)
  n2 <- edges0 %>% distinct(from_name) %>%
    rename(node = from_name)
  
  nodes1 <- rbind(n1, n2) %>%
    distinct()
  
  # add id numbers to nodes
  nodes2 <- nodes1 %>%
    mutate(id = speech_id()) 
  
  attr(edges0, "spec") <- NULL
  
  # lemmatize edges names & recount
  edges1 <- edges0 %>% 
    group_by(to_name, from_name) %>%
    summarize(weight = sum(weight)) %>%
    ungroup() %>%
    distinct() %>%
    filter(to_name != from_name)
  
  # match edges with names of nodes
  edges2 <- edges1 %>%
    left_join(nodes2, by=c("from_name" = "node")) %>%
    dplyr::mutate(from = id) #%>%
    
  edges3 <- edges2 %>% 
    select(-id) %>%
    left_join(nodes2, by=c("to_name" = "node")) %>%
    dplyr::mutate(to = id)  %>%
    select(-id) %>%
    filter(!is.na(from)) %>%
    filter(!is.na(to)) 
  
  # putin the proper order
  edges4 <- edges3 %>% 
    mutate(from = as.integer(from)) %>%
    mutate(to = as.integer(to)) %>% 
    select(from, to, from_name, to_name, weight)
  
  # count connections
  connections1 <- edges3 %>%
    dplyr::group_by(from_name) %>%
    dplyr::summarize(connections = dplyr::n()) %>%
    dplyr::rename(node = from_name)
  connections2 <- edges3 %>%
    dplyr::group_by(to_name) %>%
    dplyr::summarize(connections = dplyr::n()) %>%
    dplyr::rename(node = to_name)
  connections <- bind_rows(connections1, connections2) %>%
    group_by(node) %>%
    summarize(connections = sum(connections)) %>%
    distinct() %>%
    filter(!is.na(connections))
  
  nodes3 <- nodes2 %>% dplyr::left_join(connections) %>%
    left_join(partial_classifier) %>%
    distinct() %>%
    filter(connections > 0) 
  
  nodes3
}

generate_tidygraph <- function(edges0){
  
  # extract node information from edges record
  n1 <- edges0 %>% distinct(to_name) %>%
    rename(node = to_name)
  n2 <- edges0 %>% distinct(from_name) %>%
    rename(node = from_name)
  
  nodes1 <- rbind(n1, n2) %>%
    distinct()
  
  # add id numbers to nodes
  nodes2 <- nodes1 %>%
    mutate(id = speech_id()) 
  
  attr(edges0, "spec") <- NULL
  
  # lemmatize edges names & recount
  edges1 <- edges0 %>% 
    group_by(to_name, from_name) %>%
    summarize(weight = sum(weight)) %>%
    ungroup() %>%
    distinct() %>%
    filter(to_name != from_name)
  
  # match edges with names of nodes
  edges2 <- edges1 %>%
    left_join(nodes2, by=c("from_name" = "node")) %>%
    dplyr::rename(from = id) %>%
    select(from, from_name, to_name, weight) %>%
    left_join(nodes2, by=c("to_name" = "node")) %>%
    dplyr::rename(to = id)  %>%
    select(from, to, from_name, to_name, weight) %>%
    filter(!is.na(from)) %>%
    filter(!is.na(to)) 
  
  # putin the proper order
  edges3 <- edges2 %>% 
    mutate(from = as.integer(from)) %>%
    mutate(to = as.integer(to)) %>% 
    select(from, to, from_name, to_name, weight)
  
  # count connections
  connections1 <- edges3 %>%
    dplyr::group_by(from_name) %>%
    dplyr::summarize(connections = dplyr::n()) %>%
    dplyr::rename(node = from_name)
  connections2 <- edges3 %>%
    dplyr::group_by(to_name) %>%
    dplyr::summarize(connections = dplyr::n()) %>%
    dplyr::rename(node = to_name)
  connections <- bind_rows(connections1, connections2) %>%
    group_by(node) %>%
    summarize(connections = sum(connections)) %>%
    distinct() %>%
    filter(!is.na(connections))
  
  nodes3 <- nodes2 %>% dplyr::left_join(connections) %>%
    left_join(partial_classifier) %>%
    distinct() %>%
    filter(connections > 0) 
  
  
  # make network
  tidygraph1 <- tbl_graph(nodes = nodes3, edges = edges3, directed = FALSE)
  
  tidygraph2 <- tidygraph1 %>%
    activate(nodes) %>%
    filter(!node_is_isolated()) %>%
    mutate(neighbors = centrality_degree()) %>%
    arrange(-neighbors) %>%
    filter(neighbors > 1)
  
  tidygraph2
}

tidy_logl <- function(df, group_key, token_key, threshold = 3, wcount) {
  # 
  # #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # # If df is grouped, then use 'do()' to apply the function to all groups.
  # # Note: As the data is re-organised by the grouping variable(s) during the 
  # #       'do()', use the group_indices() to put the data back in the original order 
  # #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # if (dplyr::is_grouped_df(df)) {
  #   indices <- group_indices(df) 
  #   df      <- do(df, tidy_logl(.)) 
  #   df      <- df[order(order(indices)), , drop = FALSE]
  #   return(df)
  # } 
  
  q_wcount <- dplyr::enquo(wcount)
  
  total_words_spoken <- df %>% ungroup() %>%
    dplyr::mutate(q_wcount = as.numeric(!!q_wcount)) %>% 
    dplyr::select(q_wcount) %>%
    sum(as.numeric())
  
  q_group_key <- dplyr::enquo(group_key)
  
  
  per_group_totals <- df %>%
    dplyr::group_by(!!q_group_key) %>%
    dplyr::summarize(per_group = sum(as.integer(!!q_wcount)), na.rm = T)
  
  q_token_key <- dplyr::enquo(token_key)
  
  per_token_totals <- df %>%
    dplyr::group_by(!!q_token_key) %>%
    dplyr::summarize(per_token = sum(as.integer(!!q_wcount)), na.rm = T)
  
  ll <- df %>%
    dplyr::group_by(!!q_group_key, !!q_token_key) %>%
    dplyr::summarize(n = sum(as.integer(!!q_wcount))) %>%
    dplyr::left_join(per_group_totals) %>%
    dplyr::left_join(per_token_totals) %>%
    dplyr::mutate(
      in_group_non_tokens = per_group - n,
      out_group_tokens = per_token - n,
      out_group_non_tokens = total_words_spoken - per_group - per_token
    ) %>%
    dplyr::rename( # see above linked PDF (p.2) for variable naming reference
      a = n,
      b = out_group_tokens,
      c = in_group_non_tokens,
      d = out_group_non_tokens
    ) %>%
    dplyr::select(-c(per_group, per_token)) %>%
    dplyr::mutate(
      e1 = (a + c) * ((a + b) / total_words_spoken),
      e2 = (b + d) * ((a + b) / total_words_spoken),
      ll = 2 * ((a * log(a / e1)) + (b * log(b / e2)))
    ) %>%
    dplyr::filter(!is.na(ll), ll > threshold) %>%
    dplyr::mutate(ll = dplyr::if_else(a < e1, ll * -1, ll)) %>%
    dplyr::select(-c(a, b, c, d)) %>%
    dplyr::arrange(desc(ll))
  
    
  df <- df %>%
    #select(!!q_group_key, !!q_token_key, n, e1, e2, ll) %>%
    left_join(ll)
  
  return(df)
}

loglike_associations <- function(list1, firstyear, lastyear, level, parallel) {
  
  print("calling function loglike_ASSOCIATIONS")
  loadfrequencies(level)
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered word associations about ",
    description
  ))
  
  
  filename <- paste0("loglike_associations", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
  
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "reading in file: ", filename))
    setwd("~/projects/data")
    loglike3 <-
      read_csv(filename)
  }
  # instructions for if no loglike_associations file is found
  if (!file.exists(filename)){ 
    print("no previous files found")
    
    print(paste0("gathering loglike measurements for ", description))
    if(exists("associations")&&
       (unique(associations$level) == level) && 
       all(unlist(list1) %in% unique(associations$term)) &&
       (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
    ){print("previously generated dataframe of word associations exists from running find_associations.  using it.")
    } else { 
      print("looking for previously generated file of word associations")
      filename1 <- paste0("associations", description,
                          "_",
                          firstyear,
                          "-",
                          lastyear,
                          "_",
                          level,
                          ".csv")
      setwd("~/projects/data")
      
      if (file.exists(filename1)) {
        print("previously generated file of log likelihood measurements found")
        associations <- read_csv(filename1) %>% mutate(level = level)
        assign("associations", associations, envir=.GlobalEnv)
      }else { if (!file.exists(filename1)) {
        print("no previously generated file of log likelihood measurements found")
        associations <-
          find_associations(list1, firstyear, lastyear, level, parallel) %>%
          mutate(level = level)
        assign("associations", associations, envir=.GlobalEnv)
        
        print("back in LOGLIKE_ASSOCIATIONS")
      }
      }}
    # at this point there should be a file called "associations" which
    # gives the data about speeches that mention any words in list1.
    
    # next, the speechcounts/debatecounts/sentencecounts files 
    # are used to give the raw counts of collocates per document
    # for other speeches/ debates / sentences.
    
    # associations is renamed so that the keywords in list1 function
    # as document names (in the rownumber or sentence number column)
    # this will make it possible down the road to use the loglike
    # measure to tell which words are "distinctive" to each keyword
    # as if the keyword were any other document.
    
    # the files are "anti-joined", and then bound together,
    # so that the loglike dataframe contains lists of collocates 
    # for each sentence/speech/debate + collocates just for 
    # keywords in list1 with no overlap.  
    
    if (level == "speech") {
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(speech_id)) %>%
          group_by(speech_id, term, word) %>%
          summarize(wcount = sum(wordsperspeech))
        
        context_count$speech_id <- as.character(context_count$speech_id)
        
        # count collocations per speech for each speech in hansard
        loglike <- speechcounts %>%           
          filter(!is.na(speech_id)) 
        
        if(nrow(loglike)>0){
          loglike$speech_id <- as.character(loglike$speech_id)
          colnames(loglike)[colnames(loglike)=="wordsperspeech"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          loglike <- loglike %>%
            anti_join(context_count, by = "speech_id")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(loglike)[colnames(loglike)=="speech_id"] <- "term"
          
          # loglike and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          loglike <- loglike %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{loglike <- data.frame()}
      }else{loglike <- data.frame()}
    }
    
    if(level == "debate") {
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(debate_id)) %>%
          group_by(debate_id, term, word) %>%
          summarize(wcount = sum(wordsperdebate))
        
        context_count$debate_id <- as.character(context_count$debate_id)
        
        # count collocations per speech for each speech in hansard
        loglike <- debatecounts %>%           
          filter(!is.na(debate_id)) 
        
        if(nrow(loglike)>0){
          loglike$debate_id <- as.character(loglike$debate_id)
          colnames(loglike)[colnames(loglike)=="wordsperdebate"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          loglike <- loglike %>%
            anti_join(context_count, by = "debate_id")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(loglike)[colnames(loglike)=="debate_id"] <- "term"
          
          # loglike and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          loglike <- loglike %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{loglike <- data.frame()}
      }else{loglike <- data.frame()}
    }
    
    if(level == "sentence"){
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      # count collocations per speech for each keyword in list1
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations) > 0){
        context_count <- associations %>%
          filter(!is.na(sentence_id)) %>%
          group_by(sentence_id, term, word) %>%
          summarize(wcount = sum(wordspersentence))
        
        context_count$sentence_id <- as.character(context_count$sentence_id)
        
        # count collocations per speech for each speech in hansard
        loglike <- sentencecounts %>%           
          filter(!is.na(sentence_id)) 
        
        if(nrow(loglike)>0){
          loglike$sentence_id <- as.character(loglike$sentence_id)
          colnames(loglike)[colnames(loglike)=="wordspersentence"] <- "wcount"
          
          # remove any overlap between the speeches counted as 
          # keyword collocates and the all-hansard speeches
          loglike <- loglike %>%
            anti_join(context_count, by = "sentence_id")
          
          #standaradize colnames (we're calling all speech numbers
          #'term' just like the keywords in list1)
          colnames(loglike)[colnames(loglike)=="sentence_id"] <- "term"
          
          # loglike and context_count are ready to be joined and 
          # measured against each other.  this will happen in the 
          # next stage.
          loglike <- loglike %>% ungroup() %>%
            select(term, word, wcount)
          
          context_count <- context_count %>% ungroup() %>%
            select(term, word, wcount)
        }else{loglike <- data.frame()}
      }else{loglike <- data.frame()}
    }
    
    loglike <- loglike %>%
      as_tibble()
    
    if((length(loglike)>0)&(nrow(loglike) > 0)){
      
      
      print("joining variables context_count (context of terms) and loglike (context of all debates)")
      
      # here we create fake documents where the "term" 
      # (keyword from list1) will later serve as the document for loglike 
      # measuring.
      # each line in context_count2 is a count of a collocates
      # for a term in list1, so that each word will be measured
      # as if a debate, speech, etc. 
      
      context_count2 <- context_count %>%
        mutate(term = as.character(term)) %>%
        mutate(word = as.character(word)) %>%
        select(term, word, wcount) %>%
        group_by(term, word) %>%
        summarize(wcount = sum(wcount))
      
      print("turning everything into a character")
      loglike$term <- as.character(loglike$term)
      
      loglike2 <- loglike %>%
        bind_rows(context_count2) 
      
      loglike3 <- 
        tidy_logl(loglike2, group_key = term, token_key = word, 
                  threshold = 3, wcount) %>%
        arrange(desc(ll)) %>%
        group_by(term) %>%
        filter(!term == word) %>%
        ungroup()
      
      print("saving loglike as a universal variable")
      #save to global environment, just in case
      assign("loglike", loglike3, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(loglike3, filename)
      
      
      
    }else{loglike3 <- data.frame()}
  }#end instructions for generating loglike3 if no previous file existed.
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(loglike3)
  
}

loglike_comparison <- function(list1, firstyear, lastyear, level, parallel){
  print("calling function loglike_COMPARISON")
  
  loadfrequencies(level)
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered comparative loglike about ",
    description
  ))
  
  
  filename <- paste0("loglike_comparison_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "reading in file: ", filename))
    setwd("~/projects/data")
    loglike <-
      read_csv(filename)
  }else{
    
    if (!file.exists(filename)){
      print("no previous files found")
      
      setwd("~/projects/data")
      print(paste0("loading per-sentence word counts for period ", firstyear, "-", lastyear, "for", description))
      
      if(exists("associations")&&
         (unique(associations$level) == level) && 
         all(unlist(list1) %in% unique(associations$term)) &&
         (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
      ){      print("previously generated dataframe of word associations exists from running find_associations.  using it.")
      }else{
        if(!exists("associations")){
          filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
          setwd("~/projects/data")
          if(file.exists(filename1)){associations <- read_csv(filename1) %>% mutate(level = level)}
          
          if(!file.exists(filename1)){
            associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
              mutate(level = level)
            print("back in LOGLIKE_ASSOCIATIONS")}}}
      
      # at this point there should be a file called "associations". further 
      # computations are enacted on that file.
      
      if(level == "debate"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordsperdebate)) %>%
          select(term, word, n) 
      }
      
      if(level == "speech"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordsperspeech)) %>%
          ungroup() %>%
          select(term, word, n) }
      
      if(level == "sentence"){
        context_count <- associations %>%
          group_by(term, word) %>%
          summarize(n = sum(wordspersentence)) %>%
          ungroup() %>%
          select(term, word, n) }
      
      loglike <-         
        tidy_logl(context_count, group_key = term, token_key = word, 
                  threshold = 3, wcount = n)
      
      
      print("saving loglike as a universal variable")
      #save to global environment, just in case
      assign("loglike", loglike, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(loglike, filename)
      
      
    }else{loglike <- data.frame()}}
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(loglike)
  
}


loglike_associations_by_year <- function(list1, firstyear, lastyear, intervals, level, parallel) {
  print("calling function loglike_ASSOCIATIONS")
  
  loadfrequencies(level)
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered word associations about ",
    description
  ))
  
  
  filename <- paste0("loglike_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "reading in file: ", filename))
    setwd("~/projects/data")
    loglike3 <-
      read_csv(filename)
  } 
  
  if (!file.exists(filename)){ 
    print("no previous files found")
    
    setwd("~/projects/data")
    print(paste0("loading per-", level, " word counts for period ", firstyear, "-", lastyear))
    
    filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
    setwd("~/projects/data")
    
    if(exists("associations")&&
       (unique(associations$level) == level) && 
       all(unlist(list1) %in% unique(associations$term)) &&
       (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
    ){      print("associations dataframe already exists. using it.") 
    }else{
      
      if(file.exists(filename1)){associations <- read_csv(filename1) %>% mutate (level = level)}
      
      if(!file.exists(filename1)){
        associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
          mutate(level = level)
        print("back in loglike_ASSOCIATIONS")}
    }
    
    # at this point there should be a file called "associations". further 
    # computations are enacted on that file.
    
    if (level == "speech") {
      setwd("~/projects/data")
      
      if(!exists("speechcounts")){load_frequencies(level)}
      
      speechcounts <- speechcounts %>%
        filter(year > firstyear) %>%
        filter(year < lastyear) %>%
        rename(wordsperspeech = n)
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      context_count <- associations %>%
        count(year, speech_id, term, word) %>%
        rename(wordsperspeech = n) 
      
      loglike$speech_id <- as.integer(loglike$speech_id)
      context_count$speech_id <- as.integer(context_count$speech_id)
      
      loglike <- speechcounts %>%           
        filter(year > firstyear) %>%
        filter(year < lastyear) %>%
        filter(!is.na(speech_id)) #%>%
      #loglike$term <- as.character(loglike$speech_id)
      loglike <- loglike %>%
        anti_join(context_count, by = "speech_id") %>%
        rename(term = speech_id) %>%
        rename(wcount = wordsperspeech) %>%
        select(term, word, wcount, year)
      
    }
    
    if(level == "debate") {
      setwd("~/projects/data")
      
      if(!exists("debatecounts")){load_frequencies(level)}
      
      if("n" %in% colnames(debatecounts)){
        debatecounts <- debatecounts %>%
          rename(wordsperdebate = n) } 
      
      print(
        paste0(
          "doing a statistical analysis which words are differentially correlated to which term in the list about ",
          description
        )
      )
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(nrow(associations)>0){
        context_count <- associations %>%
          count(year, debate_id, term, word)  %>%
          rename(wcount = n)
        context_count$debate_id <- as.integer(context_count$debate_id)
        
        loglike <- debatecounts %>% 
          filter(year > firstyear) %>%
          filter(year < lastyear) %>%
          filter(!is.na(debate_id))
        
        loglike$debate_id <- as.integer(loglike$debate_id)
        
        loglike <- loglike %>% 
          anti_join(context_count, by = "debate_id") %>%
          rename(term = debate_id) %>%
          rename(wcount = wordsperdebate) %>%
          select(term, word, wcount, year)
      }else{loglike <- data.frame()}
    } # end debate level
    
    
    
    if(level == "sentence"){
      
      print(paste0("counting which words correspond to which term on the level of ", level, " in the list about ", description))
      
      if(!exists("sentencecounts")){load_frequencies(level)}
      
      if(nrow(associations)>0){
        context_count <- associations %>%
          count(year, sentence_id, term, word) %>% 
          rename(wcount = n) 
        
        sentencecounts$sentence_id <- as.factor(sentencecounts$sentence_id)
        
        loglike <- sentencecounts %>% 
          filter(year > firstyear) %>%
          filter(year < lastyear) %>%
          filter(!is.na(sentence_id)) 
        
        loglike$sentence_id <- as.integer(loglike$sentence_id)
        context_count$sentence_id <- as.integer(context_count$sentence_id)
        
        loglike <- loglike %>% 
          anti_join(context_count, by = "sentence_id") %>%
          rename(term = sentence_id) 
        
        loglike <- loglike %>%
          ungroup() %>%
          ungroup() %>%
          ungroup() %>%
          rename(wcount = wordspersentence) %>%
          select(term, word, wcount, year)
      }else{loglike <- data.frame()}
    }# end instructions for sentence level
    
    loglike <- loglike %>%
      as_tibble()
    
    
    if(length(loglike)>0){
      if(nrow(loglike) > 0){
        
        print("joining variables context_count (context of terms) and loglike (context of all debates)")
        context_count <- context_count %>%
          select(year, term, word, wcount) %>%
          mutate(term = as.character(term)) %>%
          mutate(word = as.character(word))
        
        print("turning everything into a character")
        loglike$term <- as.character(loglike$term)
        
        loglike2 <- loglike %>%
          bind_rows(context_count) %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wcount)) %>%
          mutate(grouping = paste0(term, "-", period))
        
        loglike3 <- loglike2 %>%
          tidy_logl(group_key = grouping, token_key = word, 
                    threshold = 3, n) #%>%
          
        loglike4 <- loglike3 %>% 
          separate(grouping, into = c("term", "period"), sep = "-") %>%
          group_by(term) %>%
          filter(!term == word) %>%
          ungroup()
        
        
        print("saving loglike as a universal variable")
        #save to global environment, just in case
        assign("loglike", loglike4, envir=.GlobalEnv)
        
        setwd("~/projects/data")
        write_csv(loglike4, filename)
        
        
      }else{loglike4<- data.frame()}
    }else{loglike4 <- data.frame()}
  }#end instructions for generating loglike3 if no previous file existed.
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(loglike4)
  
}


loglike_comparison_by_year <- function(list1, firstyear, lastyear, level, intervals, parallel, exclusive2period){
  print("calling function LOGLIKE_COMPARISON_BY_YEAR")
  print(
    paste0(
      "beginning a function to calculate statistically differential word associations about ",
      description,
      " at the level of ",
      level
    )
  )
  
  print(paste0(
    "looking for previously gathered comparative tfidf about ",
    description
  ))
  
  
  filename <- paste0("ll_comparison_by_year_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
  setwd("~/projects/data")
  
  if (file.exists(filename)) {
    print(paste0(
      "previously generated file found.  reading in file: ", filename))
    ll <-
      read_csv(filename)
  }else{
    
    if (!file.exists(filename)){
      print(paste0("no previous files found by the name of ", filename))
      print(paste0("the next step is to gather collocate associations measurements for ", description))
      
      if(exists("associations")&&
         (unique(associations$level) == level) && 
         all(unlist(list1) %in% unique(associations$term)) &&
         (abs(max(associations$year)-min(associations$year)- (lastyear-firstyear)) < 10 )
      ){ print("previously generated dataframe of word associations exists from running find_associations.  using it.")
      }else{
        if(!exists("associations")){
          print("no associations dataframe found")
          filename1 <- paste0("associations_", description, "_", firstyear, "-", lastyear, "_", level, ".csv")
          setwd("~/projects/data")
          print(paste0("looking for a file named ", filename1))
          if(file.exists(filename1)){print("file found; loading...")
            associations <- read_csv(filename1) %>% mutate(level = level)}
          
          if(!file.exists(filename1)){print(paste0("no file named ", filename1, " found"))
            associations <- find_associations(list1, firstyear, lastyear, level, parallel) %>%
              mutate(level = level)
            print("back in LL_ASSOCIATIONS")}}
      }
      
      # at this point there should be a file called "associations". further 
      # computations are enacted on that file.
      
      print("counting common collocates per term")
      if(level == "debate"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordsperdebate)) %>%
          ungroup() %>%
          select(period, term, word, n) 
      }
      
      if(level == "speech"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordsperspeech)) %>%
          ungroup() %>%
          select(period, term, word, n) 
      }
      
      if(level == "sentence"){
        context_count <- associations %>%
          mutate(period = year - year %% intervals) %>%
          group_by(period, term, word) %>%
          summarize(n = sum(wordspersentence)) %>%
          ungroup() %>%
          select(period, term, word, n) }
      
      print("calculating log likelihood for each word-term pair")
      if(exclusive2period == T){
      ll <- context_count %>%
        mutate(grouping = paste0(term, "-", period)) %>%
        tidy_logl(group_key = grouping, token_key = word, threshold = 3, n) #%>%

       ll <- ll %>% #separate(grouping, into = c("term", "period"), sep = "-") %>%
        filter(!is.na(ll))
       }else{
          # ll <- context_count %>%
          #   group_by(period) %>%
          #   tidy_logl(group_key = term, token_key = word, threshold = 3, n) %>%
          #   ungroup() 
          # 
          # ll <- ll %>% ungroup() %>%
          #   filter(!is.na(ll))
          
          ll2 <- data.frame()
          for(p in unique(context_count$period)){
           ll3 <- context_count %>% filter(period == p) %>%
             tidy_logl(group_key = term, token_key = word, threshold = 3, n)
           ll2 <- rbind(ll2, ll3) %>%
             filter(!is.na(ll))
          }
        }
      
      
      print("saving ll as a universal variable")
      #save to global environment, just in case
      assign("ll", ll, envir=.GlobalEnv)
      
      setwd("~/projects/data")
      write.csv(ll, filename)
      
      
    }else{ll <- data.frame()}}
  
  print(paste0("associations table complete for list of words about ", description, " at the level of ", level))
  return(ll)
  
}

