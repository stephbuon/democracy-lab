# Is 1881 mentioned 976 times in 1882? or overall? 
# let's order this by the year of mention and then 
# in descending order the events mentioned, and mentions-per-yr 
# (those should also match the order, l to r, of the column)


############ GO BACK AND MAKE SURE COUNT IS CORRECT -- in fact, get count early on and paste it so I am not counting the number of events joined to triples


library(tidyverse)
#library(formattable)
#library(DT)
library(gt)
library(ngram)
library(mgsub)


setwd("~/hansard_ner")

hansard_event_time_triple <- read_csv("hansard_event_time_triple.csv")

hansard_event_time_triple <- hansard_event_time_triple %>%
  drop_na(c("event", "time", "triple"))


hansard_event_time_triple$event <- tolower(hansard_event_time_triple$event)
hansard_event_time_triple$time <- tolower(hansard_event_time_triple$time)
hansard_event_time_triple$triple <- tolower(hansard_event_time_triple$triple)

###################
#trouble_shooting <- hansard_event_time_triple %>%
#  select(time) %>%
#  distinct()
###################



# keep these words if they appear in the time column
keep_these <- c("inquisition", "duties", "holy", "seven years", "revolution", "war", "act", "eleven years", 
                "ten years", "century", "christmas", "three years", "easter", "treaty", "1s12", "last parliament",
                "code", "convention", "dark days", "late king", "lent", "modern days")

filtered_time_triple <- tibble()

for(i in 1:length(keep_these)) {
  
  keep <- keep_these[i]
  
  filtered_hansard <- hansard_event_time_triple %>%
    filter(str_detect(time, keep))
  
  filtered_time_triple <- bind_rows(filtered_time_triple, filtered_hansard) }



# keep these because they are years, not something like currency tagged as a year 
years <- as.character(1000:1910)

filtered_years <- tibble()

for(i in 1:length(years)) {
  
  y <- years[i]
  
  filtered_hansard <- hansard_event_time_triple %>%
    filter(str_detect(time, y))
  
  filtered_years <- bind_rows(filtered_years, filtered_hansard) }


keep_times <- bind_rows(filtered_years, filtered_time_triple)


# now I create a new df that merges events and the items from the time column that I wish to keep (i.e. preprocessed_hansard)
keep_times <- keep_times %>%
  select(sentence_id, time, year, triple) %>%
  rename(event = time) # rename to event so I can mush the two DFs together 

hansard_event_time_triple <- hansard_event_time_triple %>%
  select(-(time)) 

preprocessed_hansard <- bind_rows(hansard_event_time_triple, keep_times)

preprocessed_hansard <- preprocessed_hansard %>%
  distinct(sentence_id, event, year, triple)

#hansard_event_time_triple <- hansard_event_time_triple %>%
#  distinct(sentence_id, triple, .keep_all = T)



interval <- 10

preprocessed_hansard <- preprocessed_hansard %>%
  mutate(decade = year - year %% interval)

#hansard_event_time_triple$event_time <- paste(hansard_event_time_triple$event, "-", hansard_event_time_triple$time)

preprocessed_hansard <- preprocessed_hansard %>%
  select(c("sentence_id", "decade", "event", "triple", "year")) # adding year so we can see when a temporal event was stated




decades <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900")


events_for_1900 <- c("french revolution",
                     "boer war",
                     "act", # landlord
                     "crimean war")

# done 
events_for_1890 <- c("transvaal war", # pass 
                     "crimean war",
                     "contagious diseases acts",
                     "indian mutiny",
                     "crimean war",
                     "1881", #tenant seek relief 
                     "treaty", # treaty enter between france
                     "afghan war", # war pay by india 
                     "land act") # tenant seek relief, tenant-labour-under-injustice

# done 
events_for_1880 <- c("1870",
                     "1878",
                     "1881", 
                     "1882", 
                     "1885",
                     "amendment", # landlord-remove-tenant, tenant-entitle-to-compensation, tenant-receive-notice
                     "afghan war",
                     "american war",
                     "contagious diseases acts",
                     "crimean war",
                     "service of protestant chaplains",
                     "transvaal war",
                     "treaty", 
                     "zulu war")

# done 
events_for_1870 <- c("zulu war",
                     "afghan war",
                     "crimean war",
                     "contagious diseases acts",
                     "act of 1869", # woman 
                     "act", # woman
                     "american war",
                     "war of independence",
                     "vienna exhibition",
                     "french treaty",
                     "indian mutiny",
                     "treaty", # china 
                     "treaty of san stefano") # by turky to russia 



# done 
events_for_1860 <- c("french revolution",
                     "crimean war",
                     "revolution",
                     "russian war",
                     "great exhibition")



# done
events_for_1850 <- c("french revolution",
                     "vienna conference",
                     "revolution",
                     "chinese passengers act") # cary -- 110 parish 


# done
events_for_1840 <- c("french revolution",
                     "lent",
                     "st. domingo",
                     "revolution",
                     "revolution of 1688",
                     "treaty") # brazile 


# done 
events_for_1830 <- c("french revolution", 
                     "national convention",
                     "revolution",
                     "lent",
                     "st. domingo",
                     "1807", # papist, murder, cry 
                     "st. domingo and guadaloupe") # buonaparte-contemplate-slavery

# done
events_for_1820 <- c("french revolution", # pope excommunicate concil 
                     "spanish revolution",
                     "revolution",
                     "st. domingo", 
                     "french war")


# done 
events_for_1810 <- c("french revolution", 
                     "crimean war",
                     "american war",
                     "revolution of 1688", # recover and deprive trade
                     "grand orange lodge") # meeting 

# I use counted not clean_count
events_for_1800 <- c("st. domingo",
                     "revolution",
                     "convention of cintra")



# done
triples_for_1900 <- c("it-be-in-1794", "country-be-in-jeopardy", "word-speak-against-king",
                      "history-mislead-by-error", "we-have-war", "exaggeration-indulge-during-war",
                      "tenant-do-repair", "tenant-hold-farm", "tenant-have-landlord",
                      "debt-stand-in-1866", "he-propose-taxation", "we-march-through-london")



# done
triples_for_1890 <- c("which-cost-million", "we-liberate-portion", "i-ask-for-war",
                      "regulation-regard-disease", "regulation-introduce-into-perak", "acts-be-in-force",
                      "tenant-seek-relief", "tenant-deprive-of-benefit", "privilege-confer-upon-tenant", 
                      "state-vote-without-voice", "million-squander-on-war", "india-go-through-experience", 
                      "tenant-pay-rent", "tenant-refund-by-landlord", "tenant-refund-difference",
                      "tariff-come-into-force", "end-put-to-war", "treaty-negotiate-in-1882",
                      "soldier-wound-in-action", "which-lame-him", "which-lame-for-life")

# done
triples_for_1880 <- c("drunkenness-decrease-in-city", "torpedo-bring-to-country", "drunkenness-decrease-from-1871", 
                      "hydrographer-make-investigation", "increase-pay-by-tenant", "landlord-pay-for-disturbance", 
                      "glander-prevail-among-horse", "member-confound-with-russia", "vessel-arrive-at-suez",
                      "arrest-increase-during-period", "arreset-increase-in-county", "intemperance-decrease-in-district", 
                      "they-complete-curlew", "law-maintain-ireland", "overseer-misdescribe-nature", 
                      "france-be-independent", "tunis-be-independent", "engagement-take-by-country", 
                      "war-labour-in-gloom", "order-send-for-army", "order-send-for-gun", 
                      "england-make-contribution", "500-grant-from-fund", "500-grant-reward",
                      "bill-propose-repeal", "disease-rise-between-year", "disease-rise-in-number",
                      "expenditure-incur-in-year", "he-ask-for-war", "officer-reward-for-service",
                      "they-engage-in-war", "government-protect-ally", "government-protect-from-ruin",
                      "operation-be-effectual", "bill-propose-repeal", "disease-rise-in-number",
                      "mutiny-come-after-war", "concession-grow-gloomy", "concession-have-trouble",
                      "landlord-remove-tenant", "tenant-entitle-to-compensation", "tenant-receive-notice",
                      "catholics-attend-service", "prayer-read-for-catholics", "troopship-have-chaplain")


# done
triples_for_1870 <- c("woman-take-into-custody","woman-take-without-warrant", "woman-detain-in-hospital",
                      "they-have-war", "sum-cover-expenditure", "bonds-make-total",
                      "khan-be-loyal", "india-contribute-for-expenditure", "government-plunge-into-war",
                      "war-increase-debt", "sum-be-great", "war-commence-in-1854",
                      "woman-detain-in-hospital", "woman-subject-by-order", "woman-subject-to-examination",
                      "woman-detain-in-hospital", "penalty-impose-in-england", "gentleman-direct-against-act",
                      "debate-occur-in-1775", "objection-raise-in-1781", "pauperism-increase-between-1859",
                      "cruelty-perpetrate-for-year", "rayahs", "rayahs-enjoy-protection", 
                      "injustice-commit-under-cover", "reply-be-inconclusive", "which-force-conviction",
                      "treaty-conclude-in-1860", "which-organize-during-famine", "minister-extend-power", 
                      "dissatisfaction-prevail-in-china", "sultan-announce-at-council", "china-open-port", 
                      "indemnity-pay-by-turkey", "indemnity-pay-to-russia", "integrity-guarantee-by-powers",
                      "discontent-be-strong", "country-ruin-by-war", "statesman-foresee-downfall", # french rev and blow is just rev
                      "parliament-have-courage", "presbytery-appoint-minister", "house-disregard-restriction") 


# done 
triples_for_1860 <- c("colony-separate-from-england", "i-examine-before-revolution", "she-tax-them", # american revolution 
                      "artist-expose-themselves", "salviati-come-to-england", "artist-have-copyright", # great exhibition 
                      "revolution-stimulate-feeling", "centralization-contribute-to-destruction", "french-take-possession", # french revolution
                      "support-be-prepared", "you-disestablish-church", "lords-guarantee-between-england", # protestant revolution
                      "declaration-adopt-in-1856", "poles-maintain-contest", "militia-supply-man", # crimean war 
                      "paper-establish-throughout-italy", "paper-oppose-progress", "revolution-take-place", # revolution 
                      "dissenters-attract-by-declaration", "jesuitism-insinuate-into-affair", "power-become-supreme") # rev of 1688



#done 
triples_for_1850 <- c("vessel-carry-passenger", "vessel-bind-for-havannah", "110-perish-on-voyage",
                      "bourbons-restore-to-throne", "neutrality-conclude-between-denmark", "restitution-make-for-property",
                      "manufacture-be-on-increase", "object-exclude-catholics", "person-be-anxious",
                      "constitution-become-protestant", "act-pass-after-revolution", "they-suffer-under-enactment",
                      "turks-cross-danube", "turks-declare-war", "one-inspire-by-fanaticism")


# done
triples_for_1840 <- c("revolution-be-in-1792", "revolution-be-at-height", "religion-suffer-in-revolution",
                      "performance-allow-during-lent", "performance-tolerate-during-lent", "duty-be-severe",
                      "law-enact-in-country", "law-enact-in-1688", "system-endure-since-1688-he",
                      "england-establish-faith", "england-shake-domination", "prophet-speak-of-day",
                      "crop-become-unproductive", "prospect-offer-in-country", "he-extend-to-cuba",
                      "americans-have-right", "spain-have-right", "england-watch-over-welfare")

# done
triples_for_1830 <- c("papists-invade-in-country", "atrocity-perpetrate-under-excitement", "countryman-raise-impostor",
                      "dissolution-take-before-revolution", "spain-disgrace-by-atrocity", "event-inflame-people",
                      "prince-pray-for-relaxation", "he-approve-of-relaxation", "it-observe-on-friday",
                      "christianity-abjure-in-1793-in", "slave-send-for-emancipation", "france-reap-from-assembly",
                      "population-enjoy-happiness", "young-be-in-error", "country-border-on-anarchy",
                      "change-take-place", "constitution-be-different", "rebellion-produce-feeling",
                      "domingo-lose-possession", "domingo-sever-from-france", "she-exercise-sovereignty",
                      "buonaparte-contemplate-slavery", "plantation-cultivate-by-labourer", "plantation-cultivate-in-1801")

# done
triples_for_1820 <- c("pope-excommunicate-council", "scarcity-prevail-over-country", "taxation-produce-revolution",
                      "revolution-take-place", "they-acknowledge-him", "they-acknowledge-for-king",
                      "law-pass-against-bribery", "ancestor-consider-at-revolution", "history-date-from-reformation",
                      "war-excite-uneasiness", "government-seize-property", "government-seize-in-violation",
                      "sugar-have-regulation", "sugar-smuggle-into-part", "petitioner-grant-emancipation")

# done
triples_for_1810 <- c("distress-reach-height", "troop-maintain-by-guinea", "crime-augment-in-war",
                      "revolution-spread-throughout-world", "revolution-be-in-vigour", "independence-swallow-in-gulf",
                      "sentiment-take-place", "sentiment-take-in-dublin", "sentiment-express-in-parliament",
                      "it-assail-church", "country-deprive-of-trade", "ireland-recover-trade")

# done 
triples_for_1800 <- c("baird-sail-on-9th", "baird-receive-intelligence", "we-send-for-army",
                      "fate-deter-us", "critic-estimate-production", "critic-be-unreasonable",
                      "general-order-delinquent", "court-exercise-power", "they-labour-in-consequence",
                      "that-desolate-world", "which-be-for-year")




for (i in 1:length(decades)) {
  
  d <- decades[i]
  #d <- 1830
  
  decade_of_interest <- preprocessed_hansard %>%
    filter(decade == d)
  
  decade_of_interest$event <- mgsub(decade_of_interest$event,
                                    c("[[:punct:]]", "the year ", "the ", "end of ", "january ", "february ", "march ", "april", "may ", "june ", "july ","august ", "september ", "october ", "november ", "december "), 
                                    c("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""), 
                                    ignore.case = TRUE)
  
  decade_of_interest$event <- gsub("these contagious diseases acts", "contagious diseases acts", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("service of protestant chaplains on", "service of protestant chaplains", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("zulu war of", "zulu war", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("crimean war a commission", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean war i", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("the crimean war", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("a crimean war", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("the crimean war two", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("the crimean war the turks", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("the crimean war—eleven years and a half", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean war been reduced to", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean war turks", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean wareleven and a half", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean warlarge reductions", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("another crimean war", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean war 198 millions of debt", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean war fund", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean war two", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean wareleven and a half", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("war malt duty of crimean war", "crimean war", decade_of_interest$event)
  decade_of_interest$event <- gsub("crimean war about", "crimean war", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("crofters acts", "crofters act", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("american warthe", "american war", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("year ", "", decade_of_interest$event)
  decade_of_interest$event <- gsub("years ", "", decade_of_interest$event)
  decade_of_interest$event <- gsub("year ", "", decade_of_interest$event)
  decade_of_interest$event <- gsub("the year ", "", decade_of_interest$event)
  decade_of_interest$event <- gsub("the years ", "", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the afghan war", "afghan war", decade_of_interest$event)
  decade_of_interest$event <- gsub("this afghan war", "afghan war", decade_of_interest$event)
  decade_of_interest$event <- gsub("affghan war", "afghan war", decade_of_interest$event)
  decade_of_interest$event <- gsub("the affghan war", "afghan war", decade_of_interest$event)
  decade_of_interest$event <- gsub("this affghan war", "afghan war", decade_of_interest$event)
  decade_of_interest$event <- gsub("afghan war liberal party", "afghan war", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the indian mutiny war", "indian mutiny", decade_of_interest$event)
  decade_of_interest$event <- gsub("the indian mutiny", "indian mutiny", decade_of_interest$event)
  decade_of_interest$event <- gsub("indian mutiny war", "indian mutiny", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the lent", "lent", decade_of_interest$event)
  decade_of_interest$event <- gsub("lent assizes", "lent", decade_of_interest$event)
  decade_of_interest$event <- gsub("the yorkshire lent assizes", "lent", decade_of_interest$event)
  decade_of_interest$event <- gsub("the lent assizes", "lent", decade_of_interest$event)
  decade_of_interest$event <- gsub("yorkshire lent", "lent", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the french revolution", "french revolution", decade_of_interest$event)
  decade_of_interest$event <- gsub("the then french revolution", "french revolution", decade_of_interest$event)
  decade_of_interest$event <- gsub("the revolution of france", "french revolution", decade_of_interest$event)
  decade_of_interest$event <- gsub("revolution of france", "french revolution", decade_of_interest$event)
  decade_of_interest$event <- gsub("then french revolution", "french revolution", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the french war", "french war", decade_of_interest$event)
  decade_of_interest$event <- gsub("the french war against", "french war", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the vienna conferences", "the vienna conference", decade_of_interest$event)
  decade_of_interest$event <- gsub("the conference at vienna", "the vienna conference", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the american war", "american war", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("st. domingo)", "st. domingo", decade_of_interest$event)
  decade_of_interest$event <- gsub("st domingo", "st. domingo", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("st domingo and guadaloupe", "st. domingo and guadaloupe", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the convention of cintra", "convention of cintra", decade_of_interest$event)
  decade_of_interest$event <- gsub("the convention of cintra", "convention of cintra", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the revolution", "revolution", decade_of_interest$event)
  decade_of_interest$event <- gsub("this revolution", "revolution", decade_of_interest$event)
  decade_of_interest$event <- gsub("revolutionthat", "revolution", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the spanish revolution", "spanish revolution", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the national convention", "national convention", decade_of_interest$event)
  decade_of_interest$event <- gsub("a national convention", "national convention", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("the vienna conference", "vienna conference", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("revolution of 1688down", "revolution of 1688", decade_of_interest$event)
  decade_of_interest$event <- gsub("revolution of 1688it", "revolution of 1688", decade_of_interest$event)
  decade_of_interest$event <- gsub("the revolution of 1688", "revolution of 1688", decade_of_interest$event)
  decade_of_interest$event <- gsub("revolution of 1688parliament", "revolution of 1688", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("exhibition of 1851", "great exhibition", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("contagious diseases act", "contagious diseases acts", decade_of_interest$event)
  decade_of_interest$event <- gsub("contagious diseases actss", "contagious diseases acts", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("clause of land act", "land act", decade_of_interest$event)
  decade_of_interest$event <- gsub("land acts", "land act", decade_of_interest$event)
  
  decade_of_interest$event <- gsub("a boer war", "boer war", decade_of_interest$event)
  
  
  # test <- str_replace(test, ".*(1.*)$", "\\1")
  
  #clean_decade_count$event <- gsub(".*1", "", clean_decade_count$event)
  #clean_decade_count$event <- gsub(".*[[:digit:]]", "", clean_decade_count$event)
  
  
  #counted_triple_per_event <- decade_of_interest %>% # will produce too much if I don't make distinct w/o id
  #  group_by(event, triple) %>%
  #  add_count(triple) %>%
  #  ungroup()
  
  correct_count <- decade_of_interest %>%
    distinct(sentence_id, event) %>%
    group_by(event) %>%
    add_count(event) %>%
    select(-(event)) %>%
    ungroup()
  
  counted_events <- left_join(decade_of_interest, correct_count)
  
  counted <- counted_events %>% # notice that I changed counted to counted_events for this experiment
    distinct(decade, event, triple, n, .keep_all = T)
  
  
  counted <- counted %>%
    select(-(sentence_id))
  
  # counted <- counted[,c(1,2,4,3)] 
  
  counted <- counted[,c(1,2,5,4,3)] 
  
  #version_1 <- counted %>%
  #  arrange(desc(n)) %>%
  #  slice(seq_len(15))
  
  #version_1 %>%
  #  gt() %>%
  #  cols_width(vars(triple) ~ px(300),
  #vars(`temporal event`) ~ px(200),
  #vars(time) ~ px(200),
  #             vars(event) ~ px(200),
  #             vars(decade) ~ px(100)) %>%
  #  cols_align(align = "right") # do right for event, left for triple 
  
  ############
  
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
  #filter(nn >= 2) %>%
  #  ungroup()
  
  triples_count <- counted %>%
    group_by(event, triple) %>%
    add_count(event, triple) %>%
    ungroup() %>%
    select(-c("decade", "n", "year"))
  
  
  # destroy_event <- tibble("event" = c("war", "three years", "1887", "1884", "1883", "1886"))  
  
  # clean_counted <- for_clean_counted %>%
  #   anti_join(destroy_event)
  
  event_regex <- paste0("events_for_", d)
  
  events_to_match <- get(event_regex)
  
  
  matched_events <- tibble()
  
  for(i in 1:length(events_to_match)) {
    
    event_to_match <- events_to_match[i]
    
    filtered_hansard <- counted %>% # change from counted to clean_counted if I want triples said 2 or more times  
      filter(str_detect(event, event_to_match))
    
    matched_events <- bind_rows(matched_events, filtered_hansard) }
  
  
  
  
  triples_regex <- paste0("triples_for_", d)
  
  triples_to_match <- get(triples_regex)
  
  matched_triples <- tibble()
  
  for(i in 1:length(triples_to_match)) {
    
    triple_to_match <- triples_to_match[i]
    
    filtered_hansard <- matched_events %>%
      filter(str_detect(triple, triple_to_match))
    
    matched_triples <- bind_rows(matched_triples, filtered_hansard) }
  
  
  include_triples_count <- left_join(matched_triples, triples_count, by = c("event", "triple")) # optional for including triples count 
  
  include_triples_count <- include_triples_count %>%
    distinct(event, triple, .keep_all = T)
  
  include_triples_count$nn <- gsub("^", "(", include_triples_count$nn)
  include_triples_count$nn <- gsub("$", ")", include_triples_count$nn)
  
  include_triples_count$triple_and_count <- paste(include_triples_count$triple, include_triples_count$nn)
  
  
  for_viz_option_2 <- include_triples_count %>% #matched_triples %>% 
    group_by(event) %>%
    #mutate(flattened = paste0(concatenate(triple, collapse = ": "))) %>%
    mutate(flattened = paste0(concatenate(triple_and_count, collapse = ": "))) %>%
    select(-triple) %>%
    select(-nn) %>% # if I am using include_triples_count
    select(-triple_and_count) %>% # if I am using include_triples_count
    ungroup()
  
  
  n <- 3
  pat <- paste0('^([^:]+(?::[^:]+){',n-1,'}).*') # mine
  for_viz_option_2$flattened <- sub(pat, '\\1', for_viz_option_2$flattened)
  
  
  for_viz_option_2$flattened <- gsub(":", ";  ", for_viz_option_2$flattened)
  
  for_viz_option_2 <- for_viz_option_2 %>%
    distinct(decade, event, n, flattened) 
  
  for_viz_option_2 <- for_viz_option_2 %>%
    rename(triple = flattened)
  
  option_2 <- for_viz_option_2 %>%
    arrange(desc(n)) %>%
    slice(seq_len(15)) %>%
    select(-decade)  %>%
    rename(`event count` = n) #%>%
  #rename(`year mentioned` = year) %>%
  #select(-`year mentioned`) # added this 
  
  # maybe include an empty column so this is aligned better 
  
  option_2$event <- option_2$event %>%
    str_to_title()
  
  option_2$triple <- option_2$triple %>%
    str_to_title() 
  
  # contents can be copied/pasted into a word doc
  # inside the word doc, the user can highlight the contents and go to table -> convert -> convert text to table 
  write.table(option_2, paste0(file = "triples_table_", d, ".txt"), sep = ",", quote = FALSE, row.names = F)
  
  html <- option_2 %>%
    gt() %>%
    tab_header(title = md(paste0("Lemmatized Triples Co-Occuring with Temporal Events in ", d)),
               subtitle = md("Searching the Hansard Parliamentary Debates")) %>%
    tab_source_note(source_note = md("Description: Three triples per event chosen for exemplarity Triple count is in parentheses.")) %>%
    cols_width(vars(triple) ~ px(800),
               #vars(`temporal event`) ~ px(200),
               #vars(time) ~ px(200),
               vars(event) ~ px(200)) %>% #,
    #vars(decade) ~ px(100)) %>%
    cols_align(align = "left") # do right for event, left for triple 
  
  
  gtsave(html, paste0("triples_table_", d, ".html"))
  
  
}
