### ALL HANSARD THROUGH TEMPORAL SCALE

## Assumes probability distribution of words per debate name per speechdate. 

# the code below applies the tf-idf measure of "relevance" to measure the 
# relative uniqueness of the connection
# between each word and a particular timespan (for instance, a decade, year, or day)

# typically tf-idf is used to measure which keywords
# in a document are most relevant to that document, thus generating the keywords
# used to mark a particular document as 'special' within a particular corpus.
# here, dates are used as 'documents,' creating a measure of which nation names
# were differentially important on particular days, months, years, decades, and
# half centuries.  tf-idf by date thus allows a measure of which places were 
# important on the scale of days and which were commanded attention on the scale
# of decades etc. -- thus providing a measure of 'differential attention'
# in parliament.

# ARCHITECTURE:
# a count of words per debate per speechdate is set up.
# tf-idf is calculated based on relative co-occurrence.

# the code cycles through big periods of years (5, 10, 20)
# and attempts to show the difference between tf-idf measures and raw count

# a second loop looks at smaller time periods (words relatively unique to a month, day ,etc.)

# DEVELOPMENT:
# nothing to add.

##### GENERAL SETUP
source("~/projects/code/wordcount-functions.R")

##### SETUP SPECIFIC TO THIS BATCH
#path <- "twig-level/language-time-twig/language-time-identify-relative-peaks-tfidf-twig alias"
description <- "temporal-scale-tfidf-concerns-hong-kong"
datadir <- "~/projects/hong-kong"

library(tidyverse)
library(ggrepel)

hm <- read_csv("~/projects/hong_kong/fulldict-text-TRUEtest")#"fulldict-textfromquanteda-jg-2019.csv")
#hansard <- readhansard()
hansard <- read_csv("~/projects/hong_kong/hansard_c20_debate_titles_w_hong_kong.csv")

metadata <- hansard %>% 
  distinct(sentence_id, speechdate, year) %>%
  rename(document = sentence_id)

hm2 <- left_join(hm, metadata, by = "document") %>%
  rename(word = term)

# tidy hansard
#tidy_hans <- tidyhansard(hansard, TRUE) 

#### START CODE

years <- as.data.frame(unique(metadata$year))
firstyear <- min(years)
lastyear <- max(years)
numyears <- nrow(years)

#all_terms_wordcount <- hm2 %>% group_by(year, speechdate, word) %>%
#  mutate(count = sum(count)) %>% 
#  filter(n>1) %>%
#  filter(is.na(as.numeric(word))) %>%
#filter(word %in% concerns)
#  filter(!year > 1907)

all_terms_wordcount <- hm2 %>% 
  group_by(year, word) %>%
  mutate(n = sum(count)) %>% 
  filter(n >1) %>%
  filter(is.na(as.numeric(word))) #%>%
  #filter(word %in% concerns) #for use if using tidy_hans and controlling vocab
  #filter(!year > 1907)

# cycles through term counts by month, 6 month, year, etc.  

for(yrs in c(5, 10, 20, 50, 100)) {
  
  ### count tfidf with n years as "document"
  print(paste0("counting tfidf by a ", yrs, "-year period"))
  onerowperdocument2 <- all_terms_wordcount %>%
    mutate(period = year - year %% yrs) %>%
    group_by(period, word) %>%
    dplyr::summarize(count = sum(n)) %>%
    ungroup() %>%
    mutate(id_number = period) %>%
    filter(!is.na(period)) %>%
    filter(!is.na(word)) %>%
    filter(!is.na(id_number))
  
  tfidf2 <- onerowperdocument2 %>%
    bind_tf_idf(word, id_number, count) %>%
    arrange(desc(tf_idf))
  
  top_debates5 <- tfidf2 %>%
    arrange(desc(tf_idf)) %>%
    slice(seq_len(25)) 
  
  top_n_debates <- top_debates5 %>%
    slice(seq_len(10))
  
  ggplot(top_debates5, aes(x = period,
                           y = count,#tf_idf, 
                           fill = tf_idf, 
                           label = word)) +
    geom_col() +
    #coord_flip() +
    guides(fill=FALSE) +
    geom_label_repel(
      #data = subs2,
      color = "white",
      fontface = "bold",
      force = 2,
      label.size = 0.1,
      position = position_stack(vjust = 0.5)
    ) +
    labs(title = "Temporally-Constrained Statistical Outliers in the Speech of Parliament",
         subtitle = paste0("What did Parliament Speak About Intensely for a Relatively Short Period (", yrs, " yr)?"),
         caption = "Searching the Hansard Parliamentary Debates, Measuring statistical uniqueness by TF-IDF")
  
  setwd("~/projects/hong_kong")
  ggsave(paste0(description, "1--", yrs, "yr.jpg"),
         w = 11, h = 8, units = "in")
  
  # bar chart of top tf-idf words per period
  top_debates_per_unit <- tfidf2 %>%
    group_by(period) %>%
    arrange(desc(tf_idf)) %>%
    slice(seq_len(5)) %>%
    ungroup() 
  
  
  ggplot(top_debates_per_unit, aes(y = count,
                                   x = reorder_within(word, count, period, fun = sum), 
                                   fill = tf-idf
  )) +
    geom_col() +
    facet_wrap(~period, scales = "free") +
    scale_x_reordered() +
    coord_flip() +
    guides(fill=FALSE, color = FALSE, line = FALSE) +
    labs(title = paste0("Words that Distinguished Parliament's Speech per ", yrs, "-yr Period, as measured by differential attention"),
         subtitle = paste0("Differential Attention is calculated by Tf-Idf, using temporal period (", yrs, " yr) as the 'document'"),
         caption = "Searching the Hansard Parliamentary Debates",
         y = "count",
         x = "keyword")
  
  setwd("~/projects/hong_kong")
  ggsave(paste0(description, "--", yrs, "yr.jpg"),
         w = 11, h = 8, units = "in")
  
  # What does tf-idf really mean? clarify tf-idf vs count
  
  top_debates_per_unit <- tfidf2 %>%
    group_by(period) %>%
    arrange(desc(tf_idf)) %>%
    slice(seq_len(5)) %>%
    ungroup() 
  
  top_by_count <- onerowperdocument2 %>%
    select(-id_number) %>%
    anti_join(stop_words) %>%
    group_by(period) %>%
    arrange(desc(count)) %>%
    slice(seq_len(5)) %>%
    ungroup()
  
  top_by_tf_idf <- tfidf2 %>% 
    group_by(period) %>%
    arrange(desc(tf_idf)) %>% 
    slice(seq_len(5)) %>%
    select(period, word, count, tf_idf) %>%
    ungroup()
  
  top_by_count <- top_by_count %>%
    anti_join(top_by_tf_idf, by = "word")
  
  both_original <- bind_rows(top_by_tf_idf, top_by_count) 
  both_background <- both_original %>% select(word) %>%
    left_join(onerowperdocument2, by = "word") %>%
    mutate(tf_idf = 0)
  
  
  # 
  a <- ggplot(both_original, aes(x = period, 
                                 y = count,
                                 label = word, 
                                 color = word,
                                 shape = word,
                                 group = word,
                                 fill = tf_idf)) +
    guides(color = FALSE) +
    geom_point(size = 10) + 
    geom_label_repel(
      fontface = "bold",
      force = 2,
      label.size = 0.1#,
      #position = position_stack(vjust = 0.5)
    ) +  labs(title = paste0("Comparing Top Words by Count and Words That Distinguished Parliament's Speech per ", yrs, "-yr Period, as measured by differential attention"),
              subtitle = paste0("Differential Attention is calculated by Tf-Idf, using temporal period (", yrs, " yr) as the 'document'"),
              caption = "Searching the Hansard Parliamentary Debates",
              y = "count",
              x = "keyword")
  a
  a + 
    geom_line(data = both_background) +
    geom_point(data = both_background)
  
  ggsave(paste0(description, "_compare_count_and_tfidf_measures1-", yrs, "yr.jpg"),
         w = 11, h = 8, units = "in")
  
  ### experimenting with mapping actual count against tf/idf
  
  viz2 <- top_n_debates %>% select(word) %>%
    inner_join(tfidf2) %>%
    select(-tf, -idf, -id_number) %>%
    gather(key = "measure", value = "value", tf_idf, count)
  
  
  ggplot(viz2, aes(x = period, 
                   y = value, 
                   color = word,
                   label = word,
                   shape = word,
                   fill = word)) +
    geom_point(size = 10) +
    facet_wrap(~measure, scales = "free") +
    guides(fill=FALSE) +
    labs(title = "Statistical Outliers",
         subtitle = paste0(description, " That Were Spoken About Intensely for a Relatively Short Period (", yrs, " yr)"),
         caption = "Searching the Hansard Parliamentary Debates")
  
  ggsave(paste0(description, "_compare_count_and_tfidf_measures_top_keyword--", yrs, "yr.jpg"),
         w = 11, h = 8, units = "in")
  
  
  
}

for(mos in c("1 day", "1 week", "1 month", "6 months", "12 months")){
  
  ### find outliers that have high tfidf, using with month as "document"
  print(paste0("calculating tfidf by ", mos))
  
  onerowperdocument2 <- all_terms_wordcount %>%
    mutate(speechdate = ymd(speechdate)) %>%
    mutate(year = year(speechdate)) %>%
    mutate(period = year - year %% yrs) %>%
    mutate(period = floor_date(speechdate, mos)) %>%
    group_by(period, year, word) %>%
    dplyr::summarize(count = sum(n)) %>%
    ungroup() %>%
    mutate(id_number = period) %>%
    filter(!is.na(period)) %>%
    filter(!is.na(word)) %>%
    filter(!is.na(id_number))
  
  tfidf <- onerowperdocument2 %>%
    bind_tf_idf(word, id_number, count) %>%
    arrange(desc(tf_idf))
  
  top_debates10 <- tfidf %>%
    arrange(desc(tf_idf)) %>%
    slice(seq_len(30))
  
  # plot outliers that have high tfidf, using with month as "document"
  ggplot(top_debates10, aes(
    x = year,
    y = count, 
    fill = tf_idf,
    label = word
  )) +
    geom_col() +
    #coord_flip() +
    guides(fill = FALSE) +
    geom_label_repel(
      #data = subs2,
      color = "white",
      fontface = "bold",
      force = 2,
      label.size = 0.1,
      position = position_stack(vjust = 0.5)
    ) +
    labs(
      title = "Statistical Outliers",
      subtitle = paste0(
        "What Parliament Spoke About Intensely for a Relatively Short Period (",
        mos,
        ")"
      ),
      caption = "Searching the Hansard Parliamentary Debates"
    )
  
  setwd("~/projects/hong_kong")
  ggsave(paste0("statistical-outlier-", description, "-", mos, ".jpg"), 
         w = 11, h = 8, units = "in")
  
  
  # What does tf-idf really mean? clarify tf-idf vs count
  
  
  top_by_count <- onerowperdocument2 %>%
    mutate(period2 = year - year %% 5) %>%
    select(-id_number) %>%
    anti_join(stop_words) %>%
    group_by(period2) %>%
    arrange(desc(count)) %>%
    slice(seq_len(1)) %>%
    ungroup()
  
  top_by_tf_idf <- tfidf %>% 
    mutate(year = year(id_number)) %>%
    mutate(period2 = year - year %% 5) %>%
    group_by(period2) %>%
    arrange(desc(tf_idf)) %>% 
    slice(seq_len(1)) %>%
    select(period2, word, count, tf_idf) %>%
    ungroup()
  
  top_by_count <- top_by_count %>%
    anti_join(top_by_tf_idf, by = "word")
  
  both_original <- bind_rows(top_by_tf_idf, top_by_count) 
  both_background <- both_original %>% select(word, period2) %>%
    left_join(onerowperdocument2, by = "word") %>%
    mutate(tf_idf = 0)
  
  
  # 
  a <- ggplot(both_original, aes(x = period2, 
                                 y = count,
                                 label = word, 
                                 color = word,
                                 group = word,
                                 fill = tf_idf)) +
    guides(color = FALSE) +
    geom_point() + 
    geom_label_repel(
      fontface = "bold",
      force = 2,
      label.size = 0.1#,
      #position = position_stack(vjust = 0.5)
    ) +  labs(title = paste0("Comparing Top Words by Count and Words That Distinguished Parliament's Speech per ", yrs, "-yr Period, as measured by differential attention"),
              subtitle = paste0("Differential Attention is calculated by Tf-Idf, using temporal period (", yrs, " yr) as the 'document'"),
              caption = "Searching the Hansard Parliamentary Debates",
              y = "count",
              x = "keyword")
  a
  a + 
    geom_line(data = both_background) +
    geom_point(data = both_background)
  
  
  ggsave(paste0(description, "_compare_count_and_tfidf_measures1-", mos, ".jpg"),
         w = 11, h = 8, units = "in")
}
