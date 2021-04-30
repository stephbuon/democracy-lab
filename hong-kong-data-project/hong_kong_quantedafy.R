## enter new read me 

setwd ("~/democracy-lab")

hansard_data <- "hansard_c20_12192019_w_year.csv"

subsection <- "c20_"

do_quantedafy_hansard <- TRUE
do_generate_graphs <- FALSE
do_generate_semantic_networks <- FALSE

stemmed <- TRUE

# test <- file.path("~/projects/data")

#quanteda_data_path <- file.path("quanteda-networks", "quanteda-data" )
quanteada_data_path <- file.path("hong-kong-data-project")
#quanteda_viz_path <- file.path("quanteda-networks", "quanteda-visualizations" )


## add all libraries, including from baseline set up and word count functions if need be 

library(quanteda)
library(tidyverse)
library(tm)
library(tidytext)
library(textdata)
library(textstem)
library(tidygraph)
library(ggraph)
library(igraph)
library(foreach)
library(lubridate)
library(itertools)
library(doParallel)

### Functions 

produce_dictionary <- function(stemmed){
  
  description <- "full-dictionary"
  target <- "text" # debate or text
  
  # read in data
  #sentiment <- get_sentiments(lexicon = "bing")
  govwords <- c("attorney", "court",  "attorney", "money", "gentleman", "noble", "respect", "sir", 
                "hope", "question", "feeling", "doubt", "general", "subject", "found", "statement", "parliament",
                "prepared", "law", "authority", "majority", "importance", "thought", "land", "leave", "measure", 
                "policy", "speech", "weight", "liberty", "possession","justice", "word", "fact", "treat", "highest", "argument",
                "concerned", "late", "bad", "discussion", "owing", "objection", "disposed", "expect", "system", "limited",
                "display", "delay", "powerful", "anxious", "forward", "interest", "loss", "reason", "intended", "chancellor",
                "grant", "earl", "engaged", "information", "responsible", "attention", "long", "real", "facts", "operation", "opposed",
                "sentence", "judicial", "majesty", "established", "immediately", "county", "considerable", "action", "united", "confined", "legal",
                "received", "liberal", "tribunal", "foreign", "ground", "result", "confess", "discretion", "continue", "proposition", "agreed",
                "fully", "share", "possess", "pledge", "cabinet", "supremacy", "promise", "agree", "sense", "commit", "judgment", "credit",
                "possessed", "full", "title", "president", "minister", "constitutional", "remove", "withdraw", "intelligence", "procedure",
                "understanding", "knowledge", "providing", "officer", "guarantee", "cross", "prevent", "john", "chairman", "proceeding", "reform",
                "organization", "nation", "civil", "colonel", "prime", "good", "pay", "salary", "church", "beer", 
                "university", "public", "council", "planning", "secular", "retirement", "militia", "battalion", "force",
                "wages", "pollution", "marriage", "military", "opium", "closure","soil", "instructions", "ship", "spirits", "farm", 
                "letter", "applicant", "mail", "income", "coercion", "morrow", "excluded", "perpetuity", "prison", "prisoner", "prisoners",
                "prisons", "ballot", "war", "slavery", "slave", "slaves", "rifle", "morrow", "insolvency", "police", "execution", "amnesty", 
                "armaments", "penal", "damages", "sultan", "protestant", "socialism", "improvement", "hospital", "rating", 
                "hanging", "criminal", "crime", "imprisonment", "black", "time", "words", "change", "rule", "plan", "motion", 
                "examination", "vote", "perjury", "opposition", "kind", "friend", "member", "committee", "investigation", 
                "board", "inquiry", "present", "lord", "government", "special", "appeal", "case", "bonus", "advance", "deal", "tax")
  
#  s2 <- sentiment %>%
#    filter(!(word %in% govwords)) %>% 
#    select(word) %>%
#    mutate(sentiment = word)
  
  #setwd("~/quanteda-networks/quanteda-data")
#  traits <- read_csv(file.path(quanteda_data_path, "traitdict.csv")) %>%
#    select(word) %>%
#    mutate(sentiment = word)
  
#  phenomena <- read_csv(file.path(quanteda_data_path,"phenomenadict.csv")) %>%
#    select(word) %>%
#    mutate(sentiment = word)
  
#  nations <- read_csv(file.path(quanteda_data_path,"collaborative_nations.csv"))
#  n2 <- nations %>%
#    select(Nations, Nation_Base)%>%
#    rename(word = Nations, 
#           sentiment = Nation_Base) 
  
#  cities <- read_csv(file.path(quanteda_data_path, "collaborative_cities.csv"))
#  c2 <- cities %>%
#    select(Cities, City_Base) %>%
#    rename(word = Cities, 
#           sentiment = City_Base) 
  
  concerns <- read_csv(file.path(quanteda_data_path, "hk_concerns.csv"))
#  classes <- read_csv(file.path(quanteda_data_path,"classes.csv"))
#  offices <- read_csv(file.path(quanteda_data_path,"offices.csv"))
#  property <- read_csv(file.path(quanteda_data_path,"propertywords.csv"))
  
#  names(property) <- "word" 
  
#  e1 <- property %>%
#    mutate(sentiment = word)
  
  d1 <- concerns %>% 
    select(concerns) %>%
    rename(word = concerns) %>%
    mutate(sentiment = word)
  
#  d2 <- classes %>% 
#    select(classes) %>%
#    rename(word = classes) %>%
#    mutate(sentiment = word)
  
#  d3 <- offices %>% 
#    select(offices) %>%
#    rename(word = offices) %>%
#    mutate(sentiment = word)
  
#  fulldict <- bind_rows(n2, c2, d1, d2, d3, e1, s2, traits, phenomena) %>% 
fulldict <- d1 %>%
      mutate(word = tolower(word)) %>%
    mutate(sentiment = tolower(sentiment)) #%>%
  # as.dictionary()
  
  if(stemmed == TRUE) {
    fulldict$stem <- lemmatize_words(fulldict$sentiment) }
  else { 
    fulldict$stem <- fulldict$sentiment }
  
  fulldict <- as_tibble(fulldict)
  
  #names(fd) <- "sentiment"
  
  fulldict <- fulldict %>% 
    mutate(word = stem )%>%
    as.dictionary()
  
  assign("fulldict", fulldict, envir = .GlobalEnv)
  fulldict
}


gen_classifier <- function() {
  
  #sentiment <- get_sentiments(lexicon = "bing")
  
  govwords <- c("attorney", "court",  "attorney", "money", "gentleman", "noble", "respect", "sir", 
                "hope", "question", "feeling", "doubt", "general", "subject", "found", "statement", "parliament",
                "prepared", "law", "authority", "majority", "importance", "thought", "land", "leave", "measure", 
                "policy", "speech", "weight", "liberty", "possession", "justice", "word", "fact", "treat", "highest", "argument",
                "concerned", "late", "bad", "discussion", "owing","objection", "disposed", "expect", "system", "limited",
                "display", "delay", "powerful", "anxious", "forward", "interest", "loss", "reason", "intended", "chancellor",
                "grant", "earl", "engaged", "information", "responsible", "attention", "long", "real", "facts", "operation", "opposed",
                "sentence", "judicial", "majesty", "established", "immediately", "county", "considerable", "action", "united", "confined", "legal",
                "received", "liberal", "tribunal", "foreign", "ground", "result", "confess", "discretion", "continue", "proposition", "agreed",
                "fully", "share", "possess", "pledge", "cabinet", "supremacy", "promise", "agree", "sense", "commit", "judgment", "credit",
                "possessed", "full", "title", "president", "minister", "constitutional", "remove", "withdraw", "intelligence", "procedure",
                "understanding", "knowledge", "providing", "officer", "guarantee", "cross", "prevent", "john", "chairman", "proceeding", "reform",
                "organization", "nation", "civil", "colonel", "prime", "good", "pay", "salary", "church", "beer", 
                "university", "public", "council", "planning", "secular", "retirement", "militia", "battalion", "force",
                "wages", "pollution", "marriage", "military", "opium", "closure","soil", "instructions", "ship", "spirits", "farm", 
                "letter", "applicant", "mail", "income", "coercion", "morrow", "excluded", "perpetuity", "prison", "prisoner", "prisoners",
                "prisons", "ballot", "war", "slavery", "slave", "slaves", "rifle", "morrow", "insolvency", "police", "execution", "amnesty", 
                "armaments", "penal", "damages", "sultan", "protestant", "socialism", "improvement", "hospital", "rating", 
                "hanging", "criminal", "crime", "imprisonment", "black", "time", "words", "change", "rule", "plan", "motion", 
                "examination", "vote", "perjury", "opposition", "kind", "friend", "member", "committee", "investigation", 
                "board", "inquiry", "present", "lord", "government", "special", "appeal", "case", "bonus", "advance", "deal", "tax")
  
  #s2 <- sentiment %>%
  #  dplyr::filter(!(word %in% govwords)) %>% # changed (and also the other)
  #  dplyr::mutate(kind = "sentiment") %>%
  #  dplyr::mutate(Geography = "NA", 
  #                Empire = "NA") %>%
  #  dplyr::rename(node = word) %>% 
  #  dplyr::rename(cat = sentiment) 
  
  #traits <- read_csv(file.path(quanteda_data_path, "wordnet-traits.csv")) 
  #traits <- traits %>%
  #  as.data.frame() %>%
  #  dplyr::rename(node = term) %>%
  #  mutate(kind = "trait") %>%
  #  mutate(Geography = "NA", 
  #         Empire = "NA") %>%
  #  select(node, kind, Geography, Empire, cat)
  
  #phenomena <- read_csv(file.path(quanteda_data_path, "wordnet-phenomena.csv"))
  #phenomena <- phenomena %>%
  #  dplyr::rename(node = term) %>%
  #  mutate(kind = "phenomena") %>%
  #  mutate(Geography = "NA", Empire = "NA") %>%
  #  select(node, kind, Geography, Empire, cat)
  
  #nations <- read_csv(file.path(quanteda_data_path, "collaborative_nations.csv"))
  #nations2 <- nations %>%
  #  select(Nation_Base, Geography, Empire) %>%
  #  dplyr::rename(node = Nation_Base) %>%
  #  mutate(kind = "nations",  cat = "NA") %>%
  #  select(node, kind, Geography, Empire, cat)
  
  #cities <- read_csv(file.path(quanteda_data_path, "collaborative_cities.csv"))
  #cities2 <- cities %>%
  #  select(City_Base, Geography, Empire) %>%
  #  dplyr::rename(node = City_Base) %>%
  #  mutate(kind = "cities") %>%
  #  mutate( cat = "NA") %>%
  #  select(node, kind, Geography, Empire, cat)
  
  concerns <- read_csv(file.path(quanteda_data_path, "hk_concerns.csv"))
  concerns2 <- concerns %>%
    dplyr::rename(node = concerns) %>%
    mutate(kind = "concern") %>%
    mutate(Geography = "NA", Empire = "NA",  cat = "NA") %>%
    select(node, kind, Geography, Empire, cat)
  
  #classes <- read_csv(file.path(quanteda_data_path, "classes.csv"))
  #classes2 <- classes %>%
  #  dplyr::rename(node = classes) %>%
  #  mutate(kind = "class") %>%
  #  mutate(Geography = "NA", Empire = "NA", cat = "NA") %>%
  #  select(node, kind, Geography, Empire, cat)
  
  #offices <- read_csv(file.path(quanteda_data_path, "offices.csv"))
  #offices2 <- offices %>% 
  #  dplyr::rename(node = offices) %>%
  #  dplyr::mutate(kind = "office") %>%
  #  mutate(Geography = "NA", Empire = "NA", cat = "NA") %>%
  #  select(node, kind, Geography, Empire, cat)
  
  #traits <- read_csv(file.path(quanteda_data_path, "traitdict.csv")) %>%
  #  select(word, cat) %>%
  #  dplyr::rename(node = word) %>%
  #  mutate(kind = "trait") %>%
  #  mutate(Geography = "NA", Empire = "NA")
  
  #property <- read_csv(file.path(quanteda_data_path, "propertywords.csv"))
  #names(property) <- "node" 
  #property <- property %>%
  #  mutate(kind = "property") %>%
  #  mutate(cat = "NA") %>%
  #  mutate(Geography = "NA", Empire = "NA")
  
  #phenomena <- read_csv(file.path(quanteda_data_path, "phenomenadict.csv")) %>%
  #  select(word, cat) %>%
  #  dplyr::rename(node = word) %>%
  #  mutate(kind = "phenomena") %>%
  #  mutate(Geography = "NA", Empire = "NA")  
  
  #gen_classifier <- rbind(nations2, cities2, concerns2, offices2, classes2, s2, property, phenomena, traits)
  
  gen_classifier <- concerns2
  
  gen_classifier <- gen_classifier %>%
    group_by(node) %>%
    sample_n(1) %>%
    ungroup() %>%
    mutate(node = tolower(node),
           empire = stringr::str_to_title((Empire)),
           geography = stringr::str_to_title((Geography))) %>%
    select(-Geography, -Empire)
  
  assign("gen_classifier", gen_classifier, envir = .GlobalEnv)
  gen_classifier
}


quantedafy <- function(hansard, target, dict1name, stemmed){
  
  cat(paste0("making Hansard into a Quanteda corpus, working at the level of ", target))
  if(target == "debate"){
    hansardready <- hansard %>% 
      select(sentence_id, debate, year, speaker) %>%
      mutate(debate = tolower(debate))
    
    if(stemmed == TRUE){
      hansardready$stemmed <- lemmatize_words(hansardready$debate)
    } else { hansardready$stemmed <- hansardready$debate}
    
    hansardcorp <- corpus(hansardready, docid_field = "sentence_id", text_field = "stemmed") }
  
  if(target == "text"){
    hansardready <- hansard %>% 
      select(sentence_id, text, year, speaker) %>%
      mutate(text = tolower(text))
    
    if(stemmed == TRUE){
      hansardready$stemmed <- lemmatize_words(hansardready$text) }
    else { hansardready$stemmed <- hansardready$text }
    
    hansardcorp <- corpus(hansardready, docid_field = "sentence_id", 
                          text_field = "stemmed")
  }
  
  cat(paste0("using dictionary ", dict1name, " to look up words in Hansard"))
  
  if(stemmed == FALSE) {
    ##without stemming
    count1 <- dfm(tokens_lookup(tokens(hansardcorp,
                                       remove_hyphens = TRUE),
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

quantedafy_hansard <- function(hansard, stemmed){
  
  for (target in c("text", "debate")) {
    description <- "fulldict"
    dict1name <- "fulldict"
    tidyresults <- quantedafy(hansard, target, "fulldict", stemmed)
    
    cat("saving a file of tidy output in the data directory")
    
    write_csv(tidyresults, (file.path(quanteda_data_path, paste0(dict1name, "-", target, "-", stemmed, "test")))) 
  }
}



load_classified_results <- function(target){
  
  r1 <- read_csv(file.path(quanteda_data_path, paste0("fulldict-", target, "fromquanteda.csv")))
  
  gen_classifier <- gen_classifier()
  
  classified_results <- r1 %>% 
    left_join(gen_classifier, by = c("term" = "node"))
  
  assign("classified_results", classified_results, envir = globalenv())
  
  classified_results }






entities_per_yr <- function(classified_results, cat1, target, gen_classifier){
  # iteratively generate visualizations
  
  assign("target", target, envir = globalenv())
  assign("cat1", cat1, envir = globalenv())
  assign("gen_classifier", gen_classifier, envir = globalenv())
  
  
  if(target == "debate"){target_description <- "debate title"}
  if(target == "text"){target_description <- "text"}
  
  if(cat1 == "nations") {gendescription <- "geographical entities and ethnicities"
  } else { gendescription <- cat1 }
  
  assign("target_description", target_description, envir = globalenv())
  assign("gendescription", gendescription, envir = globalenv())
  
  
  df <- classified_results %>%
    filter(kind == cat1)
  
  assign("df", df, envir = globalenv())
  
  ############################################# counting entities after Q
  
  if(target == "debate"){target_description <- "debate title"}
  if(target == "text"){target_description <- "debate text"}
  
  # what were the top mentions?
  topmentions <- df %>%
    group_by(term) %>%
    summarize(total=sum(count)) %>%
    dplyr::top_n(50, wt = total) %>%
    mutate(term = stringr::str_replace(term, "_", " ")) %>%
    mutate(term = stringr::str_to_title(term), 
           term = stringr::str_replace(term, "Usa", "USA")) 
  
  
  ggplot(topmentions, aes(x = reorder(term, total), y = total)) +
    geom_col() +
    coord_flip() +
    labs(x = "term", title = paste0("Top Mentions of ", stringr::str_to_title(gendescription), " by Total Count"),
         subtitle = paste0("in the ", target_description, " of parliamentary debates"))
  
  #'ed by steph setwd(vizfolder)
  #'ed by steph ggsave(paste0("top-mentions-of-", gendescription, "-", target_description, ".pdf"),
  #'ed by steph        h = 10, w = 5, units = "in")
  
  docdate <- hansard %>% 
    select(sentence_id, speechdate) %>%
    rename(document = sentence_id)
  # How many total mentions of nations were there per year?
  totalnationsperyr <- df %>% 
    left_join(docdate) %>%
    mutate(year = year(speechdate)) %>%
    group_by(year) %>%
    summarize(total = sum(count))
  
  
  ggplot(totalnationsperyr, aes(x = year, y = total)) +
    geom_col() +
    labs(title = paste0("Total Mentions of ", stringr::str_to_title(gendescription), " Per Year"),
         subtitle = paste0("in the ", target_description, " of parliamentary debates"))
  #'ed by steph setwd(vizfolder)
  #'ed by steph ggsave(paste0("total_mentions_", gendescription, "-", target_description, "_per_yr.pdf"))
  
  # How many times on average was each nation mentioned?
  avementionsperyr <- df %>% 
    left_join(docdate) %>%
    mutate(year = year(speechdate)) %>%
    group_by(year, term) %>%
    summarize(count = sum(count)) %>%
    ungroup() %>%
    group_by(year) %>%
    mutate(ave = mean(count)) %>%
    mutate(median = median(count)) %>%
    ungroup()
  
  ggplot(avementionsperyr, aes(x = year, y = count)) +
    geom_line(alpha = 0.2) +
    geom_line(aes(y = ave), color = "red") +
    geom_line(aes(y = median), color = "blue") +
    scale_y_log10() +
    labs(title = paste0("Average Mentions of Any Given ", stringr::str_to_title(gendescription), " Per Year"),
         y = "count (as logarithm)",
         subtitle = paste0("in the ", target_description, " of parliamentary debates"),
         caption = "red is average; blue is median")
  
  # do I need to ggsave these plots? I think so 
  
  ###################################################################################################################
  
  docdate <- hansard %>%
    select(sentence_id, debate_id, speechdate, year)
  
  
  df <- df %>% 
    rename(sentence_id = document) 
  
  df <- df %>%
    left_join(docdate, by = "sentence_id")
  
  assign("df", df, envir = .GlobalEnv)
  
  ####### q data semantic network
  
  
  if(target == "text"){
    
    
    dfcount <- df %>% 
      dplyr::count(sentence_id) #group_by(sentence_id) %>%
    #mutate(n = n(term))
    
    dfcount %>% ggplot(aes(x = n)) +
      geom_histogram()
    
    toolong <- dfcount %>% 
      filter(n > 25) %>%
      left_join(df)
    
    df <- df %>% 
      anti_join(toolong, wt = sentence_id)
    
    
    parallel <- TRUE
    setup_parallel()
    allresults <- data.frame()
    
    for(firstyear in seq(from = 1800, to = 1908, by = 10)){
      lastyear <- firstyear + 9
      
      df0 <- df %>% filter(year >= firstyear) %>%
        filter(year <= lastyear)
      
      edges <- foreach(m = unique(df$year),#max(df$year),
                       .combine = rbind,
                       .packages = c("dplyr", "tidyr")) %dopar% {   # in 1806:1911){
                         
                         df1 <- df0 %>% #filter(year >= 1800+(d1*10)) %>%
                           #<= 1809+(d1*10))#
                           filter(year == m) 
                         #### import results and turn into a network.
                         # import results and limit to those in classifier
                         terms <- df1 %>%
                           distinct(speechdate, debate_id, sentence_id, term, count) %>%
                           dplyr::group_by(debate_id, sentence_id, term) %>%
                           dplyr::summarize(count = sum(count)) %>%
                           ungroup() %>%
                           ungroup() 
                         
                         uniqueterms <- df1 %>%
                           group_by(term) %>% 
                           sample_n(1) %>% ungroup() %>%
                           select(term, kind, geography, empire) 
                         
                         termsinpairs <- terms %>%
                           dplyr::group_by(sentence_id) %>%
                           dplyr::mutate(numterms = dplyr::n()) %>%
                           ungroup() %>%
                           filter(numterms > 1) %>%
                           select(-numterms)
                         
                         # get pairwise counts
                         # assemble a tibble with all the pairs
                         pairs1 <- termsinpairs %>% 
                           # mutate(edgeid = paste0(debate, "-", speechdate)) %>%
                           # select(edgeid, term) %>%
                           dplyr::group_by(sentence_id) %>% 
                           expand(sentence_id, from = term, to = term) %>% 
                           filter(from < to) %>%
                           ungroup()       
                         
                         nodes <- uniqueterms %>% 
                           dplyr::left_join(terms) %>% #rbind(results1, results2) %>% 
                           # group_by(term) %>% sample_n(1) %>% ungroup() %>%
                           dplyr::group_by(kind, empire, geography, term) %>%
                           dplyr::summarize(count = sum(count)) %>%
                           #rename(node = term) %>%
                           arrange(desc(count)) %>% ungroup() %>% ungroup() 
                         
                         # create edges
                         edges <- pairs1 %>%
                           filter(!is.na(from)) %>%
                           filter(!is.na(to)) %>%
                           dplyr::count(from, to) %>%
                           dplyr::rename(weight = n) %>%
                           filter(weight > 0) %>%
                           filter((from %in% uniqueterms$term)&(to %in% uniqueterms$term))
                         
                         
                         
                         # count connections
                         connections <- edges %>%
                           dplyr::group_by(from) %>%
                           dplyr::summarize(connections = dplyr::n(), total_weight = sum(weight)) %>%
                           dplyr::rename(node = from)
                         
                         
                         # retain only the nodes that are in edge pairs
                         nodes <- nodes %>% 
                           dplyr::rename(node = term) %>%
                           filter((node %in% edges$from)|(node %in% edges$to))
                         
                         nodes <- nodes %>% dplyr::left_join(connections) %>%
                           filter(connections > 0) %>%
                           filter(total_weight > 0)
                         
                         # only the nodes that are in edge pairs
                         nodes <- nodes %>% filter((node %in% edges$from)|(node %in% edges$to))%>%
                           arrange(desc(count)) %>%
                           filter(!is.na(node)) %>%
                           filter(count > 0)  %>%
                           dplyr::mutate(id = row_number())
                         
                         # add id numbers to nodes
                         nodes <- nodes %>%
                           dplyr::mutate(id = row_number()) 
                         
                         # match edges with names of nodes
                         edges <- edges %>%
                           dplyr::left_join(nodes, by=c("from" = "node")) %>%
                           dplyr::rename(from_name = from) %>%
                           dplyr::rename(from = id) %>%
                           dplyr::rename(from_weight = total_weight) %>%
                           dplyr::rename(from_connections = connections) %>%
                           dplyr::left_join(nodes, by=c("to" = "node")) %>%
                           dplyr::rename(to_name = to) %>%
                           dplyr::rename(to = id) %>%
                           dplyr::rename(to_weight = total_weight) %>%
                           dplyr::rename(to_connections = connections) %>%
                           dplyr::select(from, to, from_name, to_name, weight, from_weight, to_weight, from_connections, to_connections) %>%
                           filter(!is.na(from)) %>%
                           filter(!is.na(to)) 
                         
                         # putin the proper order
                         edges <- edges %>% 
                           dplyr::mutate(from = as.integer(from)) %>%
                           dplyr::mutate(to = as.integer(to)) %>% 
                           dplyr::select(from, to, from_name, to_name, weight, from_weight, to_weight, from_connections, to_connections) 
                         edges
                       }
      
      write_csv(edges, file.path(quanteda_data_path,  paste0(cat1, "_pairwise_edges_", firstyear, "-", lastyear)))
      
      allresults <- rbind(allresults, edges)
    }
    
    write_csv(allresults, file.path(quanteda_data_path, paste0(cat1, "_pairwise_edges.csv")))
    
    edges <- read_csv(file.path(quanteda_data_path, paste0(cat1, "_pairwise_edges.csv")))
    
    # extract node information from edges record
    n1 <- edges %>% 
      distinct(to_name, to_weight, to_connections) %>%
      rename(node = to_name, count = to_weight, connections = to_connections)
    n2 <- edges %>% 
      distinct(from_name, from_weight, from_connections) %>%
      rename(node = from_name, count = from_weight, connections = from_connections)
    
    # add up totals for all decades
    edges <- edges %>% 
      group_by(from_name, to_name) %>%
      summarize(weight = sum(weight)) %>%
      ungroup()
    
    nodes <- rbind(n1, n2) %>%
      group_by(node) %>%
      summarize(count = sum(count), 
                connections = sum(connections))
    
    # add id numbers to nodes
    nodes <- nodes %>%
      mutate(id = row_number()) 
    
    attr(edges, "spec") <- NULL
    #attr(edges, "groups") <- NULL
    
    # match edges with names of nodes
    edges <- edges %>% 
      left_join(nodes, by=c("from_name" = "node")) %>%
      dplyr::rename(from = id) %>%
      select(from, from_name, to_name, weight)
    
    edges <- edges %>%
      left_join(nodes, by=c("to_name" = "node")) %>%
      dplyr::rename(to = id) 
    
    edges <- edges %>%
      select(from, to, from_name, to_name, weight) %>%
      filter(!is.na(from)) %>%
      filter(!is.na(to)) 
    
    # putin the proper order
    edges <- edges %>% 
      mutate(from = as.integer(from)) %>%
      mutate(to = as.integer(to)) %>% 
      select(from, to, from_name, to_name, weight)
    
    # save those files because generating them takes forever
    
    write_csv(edges, file.path(quanteda_data_path, paste0(cat1,"-", target, "-edges.csv")))
    write_csv(nodes, file.path(quanteda_data_path, paste0(cat1, "-", target, "-nodes.csv")))
    
    closeAllConnections()
    
  }
  
  
  if(target == "debate"){
    #### import results and turn into a network.
    # import results and limit to those in classifier
    terms <- df %>%
      distinct(speechdate, debate_id, sentence_id, term, count) %>%
      group_by(sentence_id, term) %>%
      dplyr::summarize(count = sum(count)) %>%
      ungroup() %>%
      ungroup() 
    
    uniqueterms <- df %>%
      group_by(term) %>% 
      sample_n(1) %>% ungroup() %>%
      select(term, kind, geography, empire) 
    
    termsinpairs <- terms %>%
      dplyr::group_by(sentence_id) %>%
      dplyr::mutate(numterms = dplyr::n()) %>%
      dplyr::ungroup() %>%
      dplyr::filter(numterms > 1) %>%
      select(-numterms)
    
    # get pairwise counts
    # assemble a tibble with all the pairs
    pairs1 <- termsinpairs %>% 
      # mutate(edgeid = paste0(debate, "-", speechdate)) %>%
      # select(edgeid, term) %>%
      group_by(sentence_id) %>% 
      expand(sentence_id, from = term, to = term) %>% 
      filter(from < to) %>%
      ungroup()
    
    nodes <- uniqueterms %>% 
      left_join(terms) %>% #rbind(results1, results2) %>% 
      # group_by(term) %>% sample_n(1) %>% ungroup() %>%
      group_by(kind, empire, geography, term) %>%
      summarize(count = sum(count)) %>%
      #rename(node = term) %>%
      arrange(desc(count)) %>% ungroup() %>% ungroup() 
    
    # create edges
    edges <- pairs1 %>%
      filter(!is.na(from)) %>%
      filter(!is.na(to)) %>%
      count(from, to) %>%
      rename(weight = n) %>%
      filter(weight > 0) %>%
      filter((from %in% uniqueterms$term)&(to %in% uniqueterms$term))
    
    # count connections
    connections <- edges %>%
      group_by(from) %>%
      summarize(connections = n(), total_weight = sum(weight)) %>%
      rename(node = from)
    
    # retain only the nodes that are in edge pairs
    nodes <- nodes %>% rename(node = term) %>%
      filter((node %in% edges$from)|(node %in% edges$to))
    
    nodes <- nodes %>% left_join(connections) %>%
      filter(connections > 0) %>%
      filter(total_weight > 0)
    
    # only the nodes that are in edge pairs
    nodes <- nodes %>% filter((node %in% edges$from)|(node %in% edges$to))%>%
      arrange(desc(count)) %>%
      filter(!is.na(node)) %>%
      filter(count > 0)  %>%
      mutate(id = row_number())
    
    # add id numbers to nodes
    nodes <- nodes %>%
      mutate(id = row_number()) 
    
    # match edges with names of nodes
    edges <- edges %>%
      left_join(nodes, by=c("from" = "node")) %>%
      rename(from_name = from) %>%
      rename(from = id) %>%
      rename(from_weight = total_weight) %>%
      rename(from_connections = connections) %>%
      left_join(nodes, by=c("to" = "node")) %>%
      rename(to_name = to) %>%
      rename(to = id) %>%
      rename(to_weight = total_weight) %>%
      rename(to_connections = connections) %>%
      select(from, to, from_name, to_name, weight, from_weight, to_weight, from_connections, to_connections) %>%
      filter(!is.na(from)) %>%
      filter(!is.na(to)) 
    
    # putin the proper order
    edges <- edges %>% 
      mutate(from = as.integer(from)) %>%
      mutate(to = as.integer(to)) %>% 
      select(from, to, from_name, to_name, weight, from_weight, to_weight, from_connections, to_connections)
    
  }
  
  
  write_csv(edges, file.path(quanteda_data_path, paste0(cat1, "_pairwise_edges.csv")))
  
  
  ##################################################################
  ########## visualize semantic network : 
  
  
  edges <- read_csv(file.path(quanteda_data_path, paste0(cat1,"-", target, "-edges.csv")))
  nodes <- read_csv(file.path(quanteda_data_path, paste0(cat1, "-", target, "-nodes.csv")))
  
  # make network
  #ig1 <- graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
  tidygraph1 <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
  
  set.seed(1)
  
  top100 <- nodes %>% 
    arrange(desc(connections)) %>%
    dplyr::top_n(300, wt = connections) %>%
    select(id, node, connections)
  
  tope <- edges %>% 
    select(to, from, weight) %>%
    dplyr::inner_join(top100, by = c("to" = "id")) %>%
    rename(to_name = node) %>%
    select(to, from, weight, to_name) %>%
    dplyr::inner_join(top100, by = c("from" = "id")) %>%
    rename(from_name = node) %>%
    filter(to != from) %>%
    dplyr::top_n(200, wt = weight)
  
  w <- min(tope$weight)
  k <- min(top100$connections)
  
  
  g21 <- tidygraph1 %>%
    activate(edges) %>%
    filter(weight > w) %>%
    activate(nodes) %>%
    filter(connections > k) %>% 
    filter(!node_is_isolated()) %>%
    mutate(neighbors = centrality_degree()) %>%
    arrange(-neighbors) %>%
    filter(neighbors > 1)
  
  ggraph(g21, layout = "nicely") + # fr or lgl or graphopt or nicely
    geom_edge_fan(aes(width = weight), alpha = 0.05) +
    geom_node_point(aes(size = connections, alpha = .8))+#, color = geography)) +
    #geom_edge_fan(alpha = 0.1) +
    geom_node_text(aes(label = node, size = connections, alpha = 1), repel = FALSE) +
    theme_void()+
    labs(title = paste0(stringr::str_to_title(gendescription), " with more than ", k, " mentions and ", w, " edges"), 
         subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
         caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
  
  
  ggsave(file.path(quanteda_viz_path, paste("more_than_", k, "_mentions_and_", w, "_edges_network",  gendescription, "-", target_description, Sys.time(),".pdf"),
                   h = 6, w = 6, units = "in", dpi = 1500))
  
  # focus on nodes not in britain
  g22 <- tidygraph1 %>% 
    activate(nodes) %>%
    filter(geography != "Britain") %>%
    filter(!node_is_isolated())
  
  top100 <- nodes %>% 
    filter(geography != "Britain") %>%
    ungroup() %>%
    select(id, count) %>%
    arrange(desc(count)) %>%
    slice(seq_len(200)) 
  
  top3 <- edges %>% 
    filter(to != from) %>%
    inner_join(top100, by = c("to" = "id")) %>%
    inner_join(top100, by = c("from" = "id"))  %>%
    arrange(desc(weight)) %>%
    slice(seq_len(200))
  
  w <- min(top100$count)
  k <- min(top3$weight)
  
  g222 <- g22 %>%
    activate(edges) %>%
    filter(weight > k) %>%
    activate(nodes) %>%
    filter(count > w) %>% 
    filter(!node_is_isolated())  %>%
    mutate(neighbors = centrality_degree()) %>%
    arrange(-neighbors) %>%
    filter(neighbors > 2)
  
  ggraph(g222, layout = "fr") + # fr or lgl or graphopt or nicely
    geom_edge_fan(aes(width = weight), alpha = 0.05) +
    geom_node_point(aes(size = count, alpha = 1, color = geography)) +
    #geom_edge_fan(alpha = 0.1) +
    geom_node_text(aes(label = node, size = count, alpha = 1), repel = FALSE) +
    theme_void() +
    labs(title = paste0(stringr::str_to_title(gendescription), " outside of Britain with more than ", k, " mentions and ", w, " edges"), 
         subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
         caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
  
  
  ggsave(file.path(quanteda_viz_path, paste("not_britain_more_than_", k, "_mentions_and_", w, "_edges_for_network_", gendescription, "-", target_description,Sys.time(),".pdf"),
                   h = 6, w = 6, units = "in", dpi = 1500))
  
  
  
  
  ####################
  
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
    
    ##############################################################################################
    ######################################### source("qdata-semantic-net-2-categories-alt.R")
    
    
    pairs1 <- data.frame() 
    
    parallel <- TRUE
    setup_parallel()
    
    if(target == "text"){
      pairs1 <- foreach(y1 = 1806:1911, .combine = rbind,
                        .packages = c("dplyr", "tidyr")) %dopar% {   # in 1806:1911){
                          df1 <- df %>% #filter(year >= 1800+(d1*10)) %>%
                            #<= 1809+(d1*10))#
                            filter(year == y1) 
                          terms <- df1 %>%
                            distinct(speechdate, sentence_id, term, count) %>%
                            #mutate(debate = paste0(speechdate, "-", debate)) %>%
                            group_by(sentence_id, term) %>%
                            summarize(count = sum(count)) %>%
                            ungroup() %>%
                            ungroup() 
                          
                          termsinpairs <- terms %>%
                            group_by(sentence_id) %>%
                            mutate(numterms = n()) %>%
                            ungroup() %>%
                            filter(numterms > 1) %>%
                            select(-numterms)
                          
                          # get pairwise counts
                          
                          pairs0 <- termsinpairs %>% 
                            # mutate(edgeid = paste0(debate, "-", speechdate)) %>%
                            # select(edgeid, term) %>%
                            group_by(sentence_id) %>% 
                            expand(sentence_id, from = term, to = term) %>% 
                            filter(from < to) %>%
                            ungroup()
                          
                          pairs0
                        }
    }
    
    closeAllConnections()
    
    if(target == "debate"){
      
      terms <- df %>%
        distinct(speechdate, debate_id, term, count) %>%
        mutate(count = 1) %>% 
        group_by(debate_id, term) %>%
        summarize(count = sum(count)) %>%
        ungroup() %>%
        ungroup() 
      
      
      termsinpairs <- terms %>%
        group_by(debate_id) %>%
        mutate(numterms = n()) %>%
        ungroup() %>%
        filter(numterms > 1) %>%
        select(-numterms)
      
      # get pairwise counts
      
      pairs0 <- termsinpairs %>% 
        # mutate(edgeid = paste0(debate, "-", speechdate)) %>%
        # select(edgeid, term) %>%
        group_by(debate_id) %>% 
        expand(debate_id, from = term, to = term) %>% 
        filter(from < to) %>%
        ungroup()
      pairs1 <- rbind(pairs0, pairs1)
    }
    
    uniqueterms <- df %>%
      group_by(term) %>% 
      sample_n(1) %>% 
      ungroup() %>%
      select(term, kind, geography, empire) 
    
    # create nodes
    nodes <- uniqueterms %>% 
      left_join(terms) %>% #rbind(results1, results2) %>% 
      # group_by(term) %>% sample_n(1) %>% ungroup() %>%
      group_by(kind, empire, geography, term) %>%
      summarize(count = sum(count)) %>%
      #rename(node = term) %>%
      arrange(desc(count)) %>% ungroup() %>% ungroup() 
    
    # create edges
    edges <- pairs1 %>%
      filter(!is.na(from)) %>%
      filter(!is.na(to)) %>%
      count(from, to) %>%
      rename(weight = n) %>%
      filter(weight > 0) %>%
      filter((from %in% uniqueterms$term) & (to %in% uniqueterms$term))
    
    # retain only the edges where one half minimum is in cat1
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
    
    # count connections
    connections <- edges %>%
      group_by(from) %>%
      summarize(connections = n(), total_weight = sum(weight)) %>%
      rename(node = from)
    
    # retain only the nodes that are in edge pairs
    nodes <- nodes %>% 
      rename(node = term) %>%
      filter((node %in% edges$from)|(node %in% edges$to))
    
    nodes <- nodes %>% 
      left_join(connections) %>%
      filter(connections > 0) %>%
      filter(total_weight > 0)
    
    # only the nodes that are in edge pairs
    nodes <- nodes %>% 
      filter((node %in% edges$from)|(node %in% edges$to)) %>%
      arrange(desc(count)) %>%
      filter(!is.na(node)) %>%
      filter(count > 0)  %>%
      mutate(id = row_number())
    
    # add id numbers to nodes
    nodes <- nodes %>%
      mutate(id = row_number()) 
    
    # match edges with names of nodes
    edges <- edges %>%
      left_join(nodes, by=c("from" = "node")) %>%
      rename(from = id, from_name = from) %>%
      left_join(nodes, by=c("to" = "node")) %>%
      rename(to = id, to_name = to) %>%
      select(from, to, from_name, to_name, weight) %>%
      filter(!is.na(from)) %>%
      filter(!is.na(to)) 
    
    # putin the proper order
    edges <- edges %>% 
      mutate(from = as.integer(from)) %>%
      mutate(to = as.integer(to)) %>% 
      select(to, from, everything())
    nodes <- nodes %>% 
      select(id, node, everything()) %>%
      mutate(id = as.integer(id)) 
    
    # save those files because generating them takes forever
    write_csv(edges, file.path(quanteda_data_path, paste0(cat1, "-", cat2, "-", target, "-edges.csv")))
    write_csv(nodes, file.path(quanteda_data_path, paste0(cat1, "-", cat2, "-", target, "-nodes.csv")))
    
    # make network
    ig1 <- graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
    tidygraph1 <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
    
    tidygraph1 <- tidygraph1 %>% 
      bind_nodes(nodes)
    
    tidygraph1
    
    
    
    
    ################################################################################################
    ########################### visualize network 2 categories: 
    
    edges <- read_csv(file.path(quanteda_data_path, paste0(cat1, "-", cat2, "-", target, "-edges.csv")))
    nodes <- read_csv(file.path(quanteda_data_path, paste0(cat1, "-", cat2, "-", target, "-nodes.csv")))
    
    gendescription <- paste0(stringr::str_to_title(cat1), " and ", stringr::str_to_title(cat2))
    
    gen_classifier <- gen_classifier()
    
    nodes <- nodes %>% left_join(gen_classifier) %>%
      filter(kind %in% c(cat1, cat2))
    
    set.seed(1)
    
    
    # filter for top categories
    top50cat1 <- nodes %>% 
      #anti_join(stop_words, by = c("node" = "word")) %>% # remove with updated data
      filter(kind == cat1) %>% 
      arrange(desc(count)) %>%
      dplyr::top_n(50, wt = count)
    top50cat2 <- nodes %>% 
      filter(kind == cat2) %>% 
      arrange(desc(count)) %>%
      #anti_join(stop_words, by = c("node" = "word")) %>%  # remove with updated data
      dplyr::top_n(50, wt = count)
    
    top100 <- rbind(top50cat1, top50cat2)
    
    cat1edges <- edges %>% 
      select(to, from, from_name, to_name, weight) %>%
      inner_join(top50cat1, by = c("to" = "id")) %>%
      select(to, from, from_name, to_name,  weight) %>%
      inner_join(top50cat2, by = c("from" = "id")) %>%
      select(to, from, from_name, to_name, weight) %>%
      filter(to != from) %>%
      dplyr::top_n(70, wt = weight)
    
    cat2edges <- edges %>% select(to, from, from_name, to_name, weight) %>%
      inner_join(top50cat2, by = c("to" = "id")) %>%
      select(to, from, from_name, to_name,  weight) %>%
      inner_join(top50cat1, by = c("from" = "id")) %>%
      select(to, from, from_name, to_name, weight) %>%
      filter(to != from) %>%
      dplyr::top_n(70, wt = weight)
    
    tope <- rbind(cat1edges, cat2edges) 
    
    
    top100again <- top100 %>% 
      filter((id %in% tope$to) | (id %in% tope$from)) 
    tope <- tope %>% 
      filter(from %in% top100again$id) %>% 
      filter(to %in% top100again$id) 
    
    #renumber
    top100again <- top100again %>%
      mutate(id = row_number()) %>%
      filter(!is.na(node))
    
    tope1 <- tope%>% select(-to, -from) %>%
      inner_join(top100again, by=c("from_name" = "node")) %>%
      rename("from" = "id") %>% 
      select(-count, -connections, -kind, - cat, -empire, -geography)
    
    
    tope2 <- tope1 %>%  
      left_join(top100again, by=c("to_name" = "node")) %>%
      rename("to" = "id") %>%
      select(-count, -connections, -kind, - cat, -empire, -geography)
    # %>%
    #select(to, from, to_name, from_name, weight) #"to", "from", "to_name", "from_name", "weight")
    
    #  # select(to, from, to_name, from_name, weight) %>%
    # select(-nation1, -nation2) %>%
    # select(-count) 
    
    if(nrow(top100again) > 5){
      k <- min(top100$count)
      w <- min(tope2$weight)
      
      ig1 <- graph_from_data_frame(d = tope2, vertices = top100again, directed = FALSE)
      tidygraph2 <- as_tbl_graph(ig1)
      
      
      g21 <- tidygraph2 %>%
        filter(!node_is_isolated())# %>%
      # mutate(neighbors = centrality_degree()) %>%
      # arrange(-neighbors) %>%
      # filter(neighbors > 0)
      
      ggraph(g21, layout = "nicely") + # fr or lgl or graphopt or nicely
        geom_edge_fan(aes(width = weight), alpha = 0.05) +
        geom_node_point(aes(size = count, alpha = 1, color = kind)) +
        geom_node_text(aes(label = name, size = count, alpha = 1), repel = FALSE) +
        theme_void()+
        labs(title = paste0(stringr::str_to_title(gendescription), " with more than ", k, " mentions and ", w, " edges"), 
             subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
             caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
      
      
      ggsave(file.path(quanteda_viz_path, paste("top_of_each_category_top_edges",  gendescription, "-", target_description, Sys.time(),".pdf"),
                       h = 6, w = 6, units = "in", dpi = 1500))
      
    } else {
      
      # make network
      ig1 <- graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
      tidygraph1 <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
      
      tidygraph1 <- tidygraph1 %>% 
        bind_nodes(nodes)
      
      tidygraph1
      
      g21 <- tidygraph1 %>%
        filter(!node_is_isolated())
      
      ggraph(g21, layout = "fr") + # fr or lgl or graphopt or nicely
        geom_edge_fan(aes(width = weight), alpha = 0.05) +
        geom_node_point(aes(size = weight, alpha = 1, color = kind)) +
        geom_node_text(aes(label = node, size = weight, alpha = 1), repel = FALSE) +
        theme_void()+
        labs(title = paste0(stringr::str_to_title(gendescription), " with more than ", k, " mentions and ", w, " edges"), 
             subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
             caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
      
      ggsave(file.path(quanteda_viz_path, paste("top_of_each_category_top_edges",  gendescription, "-", target_description, Sys.time(),".pdf"),
                       h = 6, w = 6, units = "in", dpi = 1500))
    }
    # focus on nodes not in britain
    
    nonbritain <- nodes %>%
      filter(geography != "Britain") %>%
      filter((kind == "nations")|(kind == "cities")) %>%
      arrange(desc(count)) 
    
    top50cat12 <- nonbritain %>% filter(kind == cat1) %>% arrange(desc(count)) %>%
      dplyr::top_n(500, wt = count)
    
    top50cat22 <- nodes %>% 
      anti_join(stop_words, by = c("node" = "word")) %>%  # remove with updated data
      filter(kind == cat2) %>% arrange(desc(count)) %>%
      dplyr::top_n(50, wt = count)
    
    top1002 <- rbind(top50cat12, top50cat22) %>%
      mutate(id = row_number()) %>%
      filter(!is.na(node))
    
    
    cat1edges2 <- edges %>% select(-to, -from) %>%
      inner_join(top50cat12, by = c("to_name" = "node")) %>%
      dplyr::rename("to" = "id") %>%
      select(-count, -connections, -kind, - cat, -empire, -geography) %>%
      inner_join(top50cat22, by = c("from_name" = "node")) %>%
      dplyr::rename(from = id) %>% 
      select(-count, -connections, -kind, - cat, -empire, -geography) %>%
      filter(to != from) %>%
      dplyr::top_n(100, wt = weight)
    
    cat2edges2 <- edges %>% select(-to, -from) %>%
      inner_join(top50cat22, by = c("to_name" = "node"))  %>%
      rename("to" = "id") %>%
      select(-count, -connections, -kind, - cat, -empire, -geography) %>%
      inner_join(top50cat12, by = c("from_name" = "node")) %>%
      rename("from" = "id") %>% 
      select(-count, -connections, -kind, - cat, -empire, -geography) %>%
      filter(to != from) %>%
      dplyr::top_n(100, wt = weight)
    
    tope2 <- rbind(cat1edges2, cat2edges2) 
    #top100again2 <- top1002 %>% filter((id %in% tope2$to) | (id %in% tope2$from))
    #tope2 <- tope2 %>% filter(from %in% top100again2$id) %>% filter(to %in% top100again2$id) 
    
    ig3 <- graph_from_data_frame(d = tope2, vertices = top1002, directed = FALSE)
    
    tidygraph3 <- as_tbl_graph(ig3)
    
    if(nrow(top100again2) > 5){
      
      k <- max(top100again2$count)
      w <- max(tope2$weight)
      
      g3 <- tidygraph3 %>%
        filter(!node_is_isolated()) %>%
        mutate(neighbors = centrality_degree()) %>%
        arrange(-neighbors) %>%
        filter(neighbors > 0)
      
      ggraph(g3, layout = "nicely") + # fr or lgl or graphopt or nicely
        geom_edge_fan(aes(width = weight), alpha = 0.03) +
        geom_node_point(aes(size = count, alpha = 1, color = kind)) +
        #geom_edge_fan(alpha = 0.1) +
        geom_node_text(aes(label = name, size = count, alpha = 1), repel = FALSE) +
        theme_void()+
        labs(title = paste0(stringr::str_to_title(gendescription), " with more than ", k, " mentions and ", w, " edges"), 
             subtitle = paste0("Data: ", gendescription, " names co-located in ", target_description), 
             caption = "Data: Britain's parliamentary debates according to Hansard, 1803-1911")
      
      
      ggsave(file.path(quanteda_viz_path, paste("nonbritain_top_of_each_category_top_edges",  gendescription, "-", gendescription2, "-", target_description, Sys.time(),".pdf"),
                       h = 6, w = 6, units = "in", dpi = 1500))
      
    }
    ######################################################################################################################################
    
    
    
  }
}






if (do_quantedafy_hansard == TRUE) {
  quanteda_options(threads = 5, verbose = T)
  
  fulldict <- produce_dictionary(stemmed)
  gen_classifier()
  
  hansard <- read_csv(file.path(quanteda_data_path, hansard_data))
  # st <- Sys.time()
  quantedafy_hansard(hansard, stemmed) 
  # t1 <- st - Sys.time()
  # st2 <- Sys.time()
  save.image(file.path(quanteda_data_path, file = paste0(subsection, "quantedafy_hansard.RData"))) # just added this -- does it work? 
  
} else {
  load(file.path(quanteda_data_path, paste0(subsection, "quantedafy_hansard.RData"))) } # same




#if (do_generate_graphs == TRUE) {
  # graph top entities per yr, makes semantic network
#  for(target in c(
#    "debate", 
#    "text")) {
    
#    classified_results <- load_classified_results(target)
    
#    for(cat1 in c("nations", 
#                  "concern", "office", "class", "trait", 
#                  "phenomena", "sentiment")){
#      entities_per_yr(classified_results, cat1, target, gen_classifier) # makes bargraphs, tidygraph, and visualizes the tidygraph
#    }
#  }
  
#  t2 <- st2 - Sys.time() # see if i need this 
#  save.image(file.path(quanteda_data_path, file = paste0(subsection, "generate_graphs.RData")))
  
#} else {
#  load(file.path(quanteda_data_path, paste0(subsection, "generate_graphs.RData")))
#}



#if (do_generate_semantic_networks == TRUE) {
  
  # generate semantic network of two entities at the same time 
#  for(target in c("text", "debate")){
#    classified_results <- load_classified_results(target)
    
#    for(cat1 in c("nations", "cities", "concern")){
#      for (cat2 in c("concern", "sentiment", "phenomena", "office", "class", "trait")) {
#        gendescription2 <- paste0(cat2, target)   
#        two_entities_network(classified_results, cat1, cat2, target, gen_classifier) } # makes a 2-entity tidygraph and visualizes it
#    } 
#  }
  
#  save.image(file.path(quanteda_data_path, file = paste0(subsection, "generate_semantic_networks.RData")))
  
#} else {
#  load(file.path(quanteda_data_path, paste0(subsection, "generate_semantic_networks.RData"))) }
