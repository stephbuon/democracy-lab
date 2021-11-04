############# MASTER PHRASE FINDER FOR HANSARD #########################
##################### Jo Guldi, 12-10-17

# From each word in a list of keywords (for instance a topic), this script generates a heatmap over time
# showing the changing expression of n-word phrases containing that keyword.
# At the end of the script, a master timeline and heatmap show the relationship between all words in 
# each list.  
# Embedded loops allow a user to cycle through numerous keyword lists by setting the parameters at the 
# top of the file (e.g. keyword lists, years, phrase length), without altering the code below.

# here are any lists of keywords.  16 keywords long.
#politicians <- c("hagan", "disraeli", "parnell", "davitt", "gladstone", "balfour", "bessborough", "napier", "argyll", "healy", "connor", "sexton", "o\'brien", "scully", "matt harris", "maitland")
#emotions <- c(" anger", " sad", "happiness", "lov", "irrita", "afraid", "fear", "terror", "danger", "brilliant", "proud", "brave", "hop", "pride", "silly", "gross")
tenant <- c("landlord", "tenant", "valu") # , "land", "agricult", "crofter",  "land court", "tiller", "evict", "improv", "soil", "harvest", "hut", "peasant", "rights", "serfdom") 
property <- c("owns", "belong", "properti") #, "plot", "survey", "parcel", "abode", "inhabit", "habita", "reside", "holding", "squat", "dwell", "lodgi", "occupi", "settle")

# some more lists of keywords froma 500 topic model of all hansard
topic406 <- c("propert",	"privat",	"person",	"owner",	"possess",	"interest",	"land",	"present",	"protect",	"sale",	"case",	"hand",	"law",	"transfer",	"belong",	"valu",	"vest",	"individu",	"trust", "x")
topic362 <- c("ireland",	"trevelyan",	"act",	"law",	"harrington",	"criminal",	"person",	"sheridan",	"arrest",	"crime",	"procedure",	"protection",	"forster",	"chief",	"property",	"case",	"kerry",	"edward",	"sexton",	"lieuten")	
topic262 <- c("tenant",	"landlord",	"compens",	"improv",	"land",	"bill",	"rent",	"improvements",	"hold",	"case",	"claus",	"amend",	"act",	"farm",	"tenanc",	"agreement",	"holding",	"court",	"give",	"notic")
topic453 <- c("crofter",	"scotland",	"highland",	"island",	"weir",	"crofters",	"district",	"sutherland", "ross",	"deer", "highlands",	"croft",	"peopl",	"lord",	"secretari",	"beg",	"cromarty",	"proprietor",	"advoc",	"land")	
topic247 <- c("coloni",	"governor",	"zealand",	"island",	"nativ",	"state",	"ceylon",	"malta",	"secretari",	"colony",	"govern",	"colonies",	"british",	"coast",	"despatch",	"government",	"offic", "chief",	"settlement",	"natives")
topic153 <- c("land",	"emigr",	"emigration",	"acr",	"wast",	"labour",	"popul",	"cultiv", "larg",	"lands",	"govern",	"peopl",	"person",	"tenants",	"scheme",	"district", 	"soil", "acres",	"countri",	"purpos")
topic65 <- c("properti",	"duti",	"estat",	"person",	"property",	"death",	"case",	"duty",	"real",	"success", "pay",	"man",	"probat",	"estate",	"son",	"legaci",	"land",	"life", 	"die",	"interest")
topic152 <- c("agricultur",	"farmer",	"land",	"farm",	"interest",	"labour",	"agriculture",	"counti",	"rent",	"farmers",	"depress",	"class",	"england", "great",	"agriculturist",	"agricultural",	"cultiv", "district", "relief", "benefi")	
topic244 <- c("land",	"rent",	"commission",	"case",	"court",	"fair",	"fix",	"ireland",	"tenant",	"irish", "act",	"commiss",	"judici",	"sub-commission",	"rents",	"chief",	"landlord",	"appeal", "applic",	"counti")
topic135 <- c("ireland",	"bill", "fitzgerald",	"napier",	"tenants",	"whiteside",	"goldney",	"m\'mahon",	"seymour",	"committee",	"thought",	"evicted",	"whitesid",	"amendment",	"law",	"horsman",	"registration",	"sadleir",	"act",	"land")	
dynamic_topic1880 <- c("rent", "arrear", "tith",  "judici", "due", "rents", "old", "fixed", "payment",  "reduc", "fair",  "gale", "eject",  "reduct", "charge", "payabl", "valuat", "estat",  "valuation", "leasehold")
dynamic_topic1870 <- c("x", "farm", "evict", "farmer", "leas", "scale", "hypothec", "arrear",  "distress", "demand", "tith", "due",  "eject", "rents", "condit", "occupi", "higher", "hold", "ps10", "exceed")
dynamic_topic1890 <- c("rent", "fix", "fair", "judici", "fixed", "reduct", "rents", "statutori", "arrear",  "charge", "reduc", "sub", "due", "valuer", "valuat",  "mccartan",  "deduct",  "ulster", "price", "redempt") 

# custom stopwords.  in this case we're interested in words that signify too common phrases (act, bill, said)
# as well as words that contain keywords (untill/till, right/bright)
stopwords <- c("lieutenant")
#england|ireland|scotland|evalu|untill|still|shut|bright|artill|act|bill|said|member|cork|manchester|lieutenant|parent|mediterranean")

# set the boundaries of the inquiry
j = 5 # how many words constitute a phrase?
k = 10 # k is defined as a max of phrases we want to sample per year. 20?  10? 5?
firstyear = 1870 # set the period under investigation
lastyear = 1890 # end of the period
intervals = 1 # tick marks on the chartsevery year, every five years?  


# turn the keywords into a dataframe that will be queried as the code runs
#keywords_names <- data.frame(tenant, property)
# tenant, 
#politicians, 
# emotions)
# alternatively:
keywords_names <- data.frame(topic135, topic244, topic152, topic65, topic247, topic453, topic262, topic362, dynamic_topic1870, dynamic_topic1880, dynamic_topic1890)

# look at how querying the dataframe works.  brackets say [row, column]
keywords_names
keywords_names[3, 1]


# install important software
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("tidytext")
install.packages("wordcloud")
install.packages("reshape2")
install.packages("Hmisc")
install.packages("foreach")
install.packages("doParallel")
install.packages("itertools")
library(tidytext)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(viridis)
library(Hmisc)
library(foreach)
library(doParallel)
library(itertools)


#setup parallel backend to use many processors
cores=detectCores()
cl <- makeCluster(cores[1]-1) #not to overload your computer
registerDoParallel(cl)


##### read in hansard sampled
#setwd("/Users/ellenguldi/Box Sync/#learningtocode/hansard/data")
setwd("/Volumes/Land/storage/Data/Box Sync/#learningtocode/data/hansard data")
samp.2 <- read.csv("stemmed_debates.tsv",sep="\t",header=FALSE)
str(samp.2)
#samp.2 is a file with 4 columns: v1 (year), V2 (decade), V3 (title), V4 (text)

# constrain the timeframe
samp.2 <- samp.2 %>%
  filter(V1 > firstyear) %>%
  filter(V1 < lastyear)
str(samp.2)

#we don't need document titles for this exercise, so remove it
names(samp.2) <- c("year","decade", "title", "text") #rename the columns
samp.2$text <- as.character(samp.2$text) # make the text column to be of the class character (instead of factor)
str(samp.2)

# get the n-grams
#tidy_hans.2 <- samp.2 %>% 
 # unnest_tokens(ngrams, text, token = "ngrams", n = j) 
#str(tidy_hans.2)


# ngrams in parallel
tidy_hans.3 <- foreach(m = isplitRows(samp.2, chunks=4), .combine='rbind',
              .packages='tidytext') %dopar% {
                   unnest_tokens(m, ngrams, text, token = "ngrams", n = j)
              }

#setwd("/Users/ellenguldi/Box Sync/#learningtocode/visualizations")
setwd("/Volumes/Land/storage/Data/Box Sync/#learningtocode/visualizations")

#str(tidy_hans.3)


# start cycling through the keywords list under consideration
foreach(h = 1:(dim(keywords_names)[2]), .packages = c("dplyr", "ggplot2", "viridis", "Hmisc")) %dopar% {   # the instructions are to iterate as many times as there are columns in keyword_names
  
  # create the value "f" for the first keyword in each list
  f = (keywords_names[1, h])

  # create the structure of the database with the first keyword in each list
  assign((paste0(colnames(keywords_names)[h], "_keywords")), tidy_hans.3 %>% 
    filter(grepl(paste0(f), ngrams)) %>%
    filter(!grepl(paste0(stopwords), ngrams)) %>%
    group_by(year) %>% 
      count(ngrams, sort = TRUE) %>% #order in terms of descending count
      arrange(desc(n)) %>%
      mutate(rank_by_year = row_number()) %>%
      ungroup() %>%
    group_by(ngrams) %>% 
  #  mutate(observations = ifelse(!is.na(n), n == max(rownumber()), FALSE)) %>%
    mutate(total = sum(n)) %>% # the 'total' variable is how many times the phrase shows up for all time
    mutate(keyword = paste0(f)) %>% 
    ungroup() %>%
    group_by(year) %>%
    mutate(sum_n = sum(n)) %>%
    ungroup())
  
  write.table(get(paste0(colnames(keywords_names)[h], "_keywords")), file  = paste0("keyword_", f))  
           
  assign(paste0("keyword_", f), get(paste0(colnames(keywords_names)[h], "_keywords")))
         
  # plot the first keyword of the list only -- the value "f" - ordered by time
  p <- get(paste0(colnames(keywords_names)[h], "_keywords")) %>% 
    filter(rank_by_year < k) %>%
    filter(n>3)  %>%
    mutate(n = signif(n, 1)) %>% 
    arrange(n) %>%
    ggplot(aes(x=reorder(ngrams, year), y = factor(year))) + 
#    ggplot(aes(x=reorder(ngrams, (n/log(year)*total/log(year))), y = factor(year))) + 
    #using total and rank_by_year for re-ordering here produces different results.  
    # I don't yet know which one I really like.
    ggtitle(paste0("Repeated ", j, "-Word Phrases About ", toupper(as.character(f)), " From ", firstyear, " to ", lastyear)) +
    geom_tile(aes(fill=factor(n)), colour="white")+
    scale_y_discrete(breaks = seq(firstyear, lastyear, intervals), # changes the ticks on the x (time) axis
                     labels = seq(firstyear, lastyear, intervals) # labels should correspond to years
                   #  minor_breaks = (seq(firstyear, lastyear, 1) - breaks) # I don't know if this will work.
                    # if necessary DELETE THE ROW ABOVE.  This caused crashing in other versions of the code.
                      ) + # Ticks from 0-10, every .25
    coord_flip() +
    scale_fill_viridis(option = "C", discrete=TRUE, direction=-1) +
    #  scale_fill_discrete(palette = "Greens",  direction=-1,
    #                    breaks = c(3,  (number_colors/4), number_colors)
    #                                ) +
    guides(fill = guide_legend(
      keywidth = 0.5, keyheight = .01, title = "Number of Phrases")) +
    labs( x = paste0("Repeated Phrases (n>3) That Contain the Keyword \'", toupper(as.character(f)), "\'"),
          y = "Year") +
    theme(legend.title = element_text(color = "black", size = 12),
          plot.title = element_text(color = "black", size = 17, hjust = 0.5),
          legend.key.size = unit(2, "cm"),
          axis.text.x = element_text(angle = 90),
          axis.text.y = element_text(face="bold", color="#993333", 
                                     size=14, angle=45)
    ) 
  
  p
  
  ggsave(paste0(as.character(f), "_by_time_hansard_", firstyear, "-", lastyear, "_",  as.character(j), "grams_phrases.png"), device = "png", plot = p, width = 9, height = 12, units = "in", dpi = 800)
  ggsave(paste0(as.character(f), "_by_time_hansard_", firstyear, "-", lastyear, "_",  as.character(j), "grams_phrases.pdf"), device = "pdf", plot = p, width = 9, height = 12, units = "in", dpi = 800)
  
 # plot the first word only by n not by time
    p <- get(paste0(colnames(keywords_names)[h], "_keywords")) %>% 
    filter(rank_by_year < k) %>%
    filter(n>3)  %>%
    mutate(n = signif(n, 1)) %>% 
    arrange(n) %>%
  #  ggplot(aes(x=reorder(ngrams, year), y = factor(year))) + 
    ggplot(aes(x=reorder(ngrams, (n/log(year)*total/log(year))), y = factor(year))) + 
    #using total and rank_by_year for re-ordering here produces different results.  
    # I don't yet know which one I really like.
    ggtitle(paste0("Repeated ", j, "-Word Phrases About ", toupper(as.character(f)), " From ", firstyear, " to ", lastyear)) +
    geom_tile(aes(fill=factor(n)), colour="white")+
    scale_y_discrete(breaks = seq(firstyear, lastyear, intervals), # changes the ticks on the x (time) axis
                     labels = seq(firstyear, lastyear, intervals) # labels should correspond to years
                     #  minor_breaks = (seq(firstyear, lastyear, 1) - breaks) # I don't know if this will work.
                     # if necessary DELETE THE ROW ABOVE.  This caused crashing in other versions of the code.
    ) + # Ticks from 0-10, every .25
    coord_flip() +
    scale_fill_viridis(option = "C", discrete=TRUE, direction=-1) +
    #  scale_fill_discrete(palette = "Greens",  direction=-1,
    #                    breaks = c(3,  (number_colors/4), number_colors)
    #                                ) +
    guides(fill = guide_legend(
      keywidth = 0.5, keyheight = .01, title = "Number of Phrases")) +
    labs( x = paste0("Repeated Phrases (n>3) That Contain the Keyword \'", toupper(as.character(f)), "\'"),
          y = "Year") +
    theme(legend.title = element_text(color = "black", size = 12),
          plot.title = element_text(color = "black", size = 17, hjust = 0.5),
          legend.key.size = unit(2, "cm"),
          axis.text.x = element_text(angle = 90),
          axis.text.y = element_text(face="bold", color="#993333", 
                                     size=14, angle=45)
    ) 
  
  p
  
  ggsave(paste0(as.character(f), "_by_n_hansard_", firstyear, "-", lastyear, "_",  as.character(j), "grams_phrases.png"), device = "png", plot = p, width = 9, height = 12, units = "in", dpi = 800)
  ggsave(paste0(as.character(f), "_by_n_hansard_", firstyear, "-", lastyear, "_",  as.character(j), "grams_phrases.pdf"), device = "pdf", plot = p, width = 9, height = 12, units = "in", dpi = 800)
  

  
   # use a for loop to add in other keywords
  for(i in 2:dim(keywords_names)[1]) {  # this loop should be as long as there are rows in the list of keywords names
    
    # bring in each of the next keywords, one at a time
    g = (keywords_names[i, h])
    
    assign(paste0("keyword_", g), tidy_hans.3 %>% 
             filter(grepl(paste0(g), ngrams)) %>% 
             group_by(year) %>% count(ngrams, sort = TRUE) %>% #order in terms of descending count
             filter(!grepl(paste0(stopwords), ngrams)) %>%
             arrange(desc(n)) %>%
             mutate(rank_by_year = row_number()) %>%
             ungroup() %>%
             group_by(ngrams) %>% 
             mutate(total = sum(n)) %>% # the 'total' variable is how many times the phrase shows up for all time
             mutate(keyword = paste0(g)) %>% 
             ungroup() %>%
             group_by(year) %>%
             mutate(sum_n = sum(n)) %>%
             ungroup())
    
    # bind rows with the previous iterations for this topic to produce something called [topich]_keywords
    assign(paste0(colnames(keywords_names)[h], "_keywords"), get(paste0(colnames(keywords_names)[h], "_keywords")) %>% 
      bind_rows(get(paste0("keyword_", g))))
    
    # save the output as a file called [topich]_keywords
    write.table(get(paste0(colnames(keywords_names)[h], "_keywords")), file  = paste0(colnames(keywords_names)[h], "_keywords"))  
    # save another file called keyword_[wordg]
    write.table(get(paste0("keyword_", g)), file  = paste0("keyword_", g))  
    
    
    # graph the rest of the keywords 
    p <- get(paste0("keyword_", g)) %>% 
      filter(rank_by_year < k) %>% # only the top phrases for each year
      filter(n>3)  %>% # only repeated phrases
      mutate(n = signif(n, 1)) %>% # round the phrase counts so that the legend isn't unreadable
      ggplot(aes(x=reorder(ngrams, (n/log(year)*total/log(year))), y = factor(year))) + 
      #  ggplot(aes(x=reorder(ngrams, year), y = factor(year))) + 
      geom_tile(aes(fill=factor(n)), colour="white") + # geom_tile heatmap
      scale_y_discrete(breaks = seq(firstyear, lastyear, intervals), labels = seq(firstyear, lastyear, intervals)) + 
      # Ticks for years based on intervals set above
      coord_flip() + # flip the axes
      scale_fill_viridis(option = "C", discrete=TRUE, direction=-1) + # color scale
      #  scale_fill_discrete(palette = "Greens",  direction=-1, # alternative color scale
      #                    breaks = c(3,  (number_colors/4), number_colors)
      #                                ) +
      labs( x = paste0("Repeated Phrases (n>3) That Contain the Keyword \'", toupper(as.character(g)), "\'"),
            y = "Year") + # label the axes
      ggtitle(paste0("Repeated ", j, "-Word Phrases About ", toupper(as.character(g)), " From ", firstyear, " to ", lastyear)) +
      theme(legend.title = element_text(color = "black", size = 12),
            plot.title = element_text(color = "black", size = 17, hjust = 0.5),
            legend.key.size = unit(2, "cm"),
            axis.text.x = element_text(angle = 90),
            axis.text.y = element_text(face="bold", color="#993333", 
                                       size=14, angle=45)
      ) +
      guides(fill = guide_legend(
        keywidth = 0.5, keyheight = .01, title = "Number of Phrases")) 
    
    p
    
    ggsave(paste0(as.character(g), "_by_n_hansard_", firstyear, "-", lastyear, "_", as.character(j), "grams_phrases.png"), device = "png", plot = p, width = 9, height = 12, units = "in", dpi = 800)
    ggsave(paste0(as.character(g), "_by_n_hansard_", firstyear, "-", lastyear, "_", as.character(j), "grams_phrases.pdf"), device = "pdf", plot = p, width = 9, height = 12, units = "in", dpi = 800) 
    
  
    
    # graph the rest of the keywords - by year not by n.
    p <- get(paste0("keyword_", g)) %>% 
      filter(rank_by_year < k) %>% # only the top phrases for each year
      filter(n>3)  %>% # only repeated phrases
      mutate(n = signif(n, 1)) %>% # round the phrase counts so that the legend isn't unreadable
      #ggplot(aes(x=reorder(ngrams, (n/log(year)*total/log(year))), y = factor(year))) + 
      ggplot(aes(x=reorder(ngrams, year), y = factor(year))) + 
      geom_tile(aes(fill=factor(n)), colour="white") + # geom_tile heatmap
      scale_y_discrete(breaks = seq(firstyear, lastyear, intervals), labels = seq(firstyear, lastyear, intervals)) + 
      # Ticks for years based on intervals set above
      coord_flip() + # flip the axes
      scale_fill_viridis(option = "C", discrete=TRUE, direction=-1) + # color scale
      #  scale_fill_discrete(palette = "Greens",  direction=-1, # alternative color scale
      #                    breaks = c(3,  (number_colors/4), number_colors)
      #                                ) +
      labs( x = paste0("Repeated Phrases (n>3) That Contain the Keyword \'", toupper(as.character(g)), "\'"),
            y = "Year") + # label the axes
      ggtitle(paste0("Repeated ", j, "-Word Phrases About ", toupper(as.character(g)), " From ", firstyear, " to ", lastyear)) +
      theme(legend.title = element_text(color = "black", size = 12),
            plot.title = element_text(color = "black", size = 17, hjust = 0.5),
            legend.key.size = unit(2, "cm"),
            axis.text.x = element_text(angle = 90),
            axis.text.y = element_text(face="bold", color="#993333", 
                                       size=14, angle=45)
      ) +
      guides(fill = guide_legend(
        keywidth = 0.5, keyheight = .01, title = "Number of Phrases")) 
    
    p
    
    ggsave(paste0(as.character(g), "_by_time_hansard_", firstyear, "-", lastyear, "_", as.character(j), "grams_phrases.png"), device = "png", plot = p, width = 9, height = 12, units = "in", dpi = 800)
    ggsave(paste0(as.character(g), "_by_time_hansard_", firstyear, "-", lastyear, "_", as.character(j), "grams_phrases.pdf"), device = "pdf", plot = p, width = 9, height = 12, units = "in", dpi = 800) 
    
      
  }


  # consolidate: all_keywords  
              
  all_keywords <- read.table((paste0(colnames(keywords_names)[h], "_keywords")))  
  
  # TIMELINE
  # plot a line chart of how prevalent the phrases are over time
  timeline <-
    ggplot(all_keywords, 
           aes(x = year, y = sum_n, shape = keyword, color = keyword, size = 1.4, alpha = 1)) +
    geom_point() +
    stat_smooth(aes(linetype = keyword), method = "loess", size = 0.5, se = FALSE, show_guide=FALSE) +
 #   geom_point(aes(x = year, y = n, color = keyword, alpha = 1/100)) +
      scale_y_log10() +
      scale_x_continuous(breaks = seq(firstyear, lastyear, intervals)) +  # Ticks from 0-10, every year
      ggtitle(paste0("Repeated ", j, "-Word Phrases About ", colnames(keywords_names)[h], " From ", firstyear, " to ", lastyear)) +
      labs(color = "Total repeated phrases", 
           y = paste0("Number of Repeated Phrases (n>3) Per Year Containing Each Keyword"),
           x = "Year") +
    scale_shape(guide = "none") + 
    scale_linetype(guide = "none") +
    scale_size(guide = "none") +
    scale_alpha(guide = "none") +
      scale_colour_viridis(alpha = 1, begin = 0, end = 1, direction = 1,
                         discrete = TRUE, option = "D") +
      theme(legend.title = element_text(color = "black", size = 12),
            plot.title = element_text(color = "black", size = 17, hjust = -0.5),
            legend.key.size = unit(2, "cm")
      )       
    
  timeline
  
  ggsave(paste0(colnames(keywords_names)[h], "_hansard_", firstyear, "-", lastyear, "_keywords_", as.character(j), "grams_timeline_sumn.png"), 
         device = "png", 
         plot = timeline, 
         width = 12, height = 9, units="in", dpi = 500)
  ggsave(paste0(colnames(keywords_names)[h], "_hansard_", firstyear, "-", lastyear, "_keywords_", as.character(j), "grams_timeline_sumn.pdf"), 
         device = "pdf", plot = timeline, width = 12, height = 9, units="in", dpi = 500)
  
  
  # add in the totals for each individual phrase
  timeline2 <- timeline + geom_point(aes(x = year, y = n, shape = keyword, color = keyword, size = 1, alpha = 0.2)) +
    stat_smooth(aes(linetype = keyword), method = "loess", size = 0.25, se = FALSE, show_guide=FALSE) +
    scale_shape(guide = "none") + 
    scale_linetype(guide = "none") +
    scale_size(guide = "none") +
    scale_alpha(guide = "none") +
    labs(color = "Each repeated phrase")
  
    

  timeline2
  
  ggsave(paste0(colnames(keywords_names)[h], "_hansard_", firstyear, "-", lastyear, "_keywords_", as.character(j), "grams_timeline_n.png"), 
         device = "png", 
         plot = timeline2, 
         width = 12, height = 9, units="in", dpi = 500)
  ggsave(paste0(colnames(keywords_names)[h], "_hansard_", firstyear, "-", lastyear, "_keywords_", as.character(j), "grams_timeline_n.pdf"), 
         device = "pdf", plot = timeline2, width = 12, height = 9, units="in", dpi = 500)
  

  # HEATMAP -- ALL PHRASES
  # a heatmap for top phrases by year
  heatmap <- ggplot(all_keywords, 
                    aes(x=reorder(ngrams, year), y = factor(year))) + 
    geom_tile(aes(fill=factor(n)), colour="white") +
    scale_y_discrete(breaks = seq(firstyear, lastyear, intervals)) + # Ticks from 0-10, every .25
    theme(axis.text.x = element_text(angle = 90)) +
    coord_flip() +
    facet_wrap(~keyword, scales = "free_y") +
    ylab(label = paste0("each row represents one ", as.character(j), "-word phrase")) +
    ggtitle(paste0("Repeated ", as.character(j), "-Word Phrases About ", toupper(get(colnames(keywords_names)[h])), " From ", firstyear, " to ", lastyear)) +
    scale_fill_viridis(option = "C", discrete=TRUE, direction=-1) +
    labs( x = paste0("Each Row Represents a Phrase Repeated More Than 3x/Yr About \'", toupper(colnames(keywords_names)[h]), "\'"),
          y = "Year") +
    theme(axis.text.y = element_blank(), 
      legend.title = element_text(color = "black", size = 12),
          plot.title = element_text(color = "black", size = 17),
          legend.key.size = unit(2, "cm")
    ) +
    guides(fill = guide_legend(
      keywidth = 0.5, keyheight = .01, title = "Number of Phrases"))
  
  heatmap 
  
  ggsave(paste0(colnames(keywords_names)[h], "_hansard_", firstyear, "-", lastyear, "_keywords_", as.character(j), "grams_phrases_heatmap.png"), device = "png", plot = heatmap, width = 9, height = 12, units="in", dpi = 500)
  ggsave(paste0(colnames(keywords_names)[h], "_hansard_", firstyear, "-", lastyear, "_keywords_", as.character(j), "grams_phrases_heatmap.pdf"), device = "pdf", plot = heatmap, width = 9, height = 12, units="in", dpi = 500)
  
  
}



