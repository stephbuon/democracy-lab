# remember that "d" is currently set to a decade, not the loop 
# setwd("~/hansard_ner")


select_events <- TRUE 
select_triples <- FALSE

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
    
    hansard_named_temporal_events_triples <- distinct(hansard_named_temporal_events_triples) # check to see if duplicates are in original csv files--check to see if I want duplicates 
    
    hansard_named_temporal_events_triples <- hansard_named_temporal_events_triples %>%
      drop_na("triple")
    
    hansard_named_temporal_events_triples <- hansard_named_temporal_events_triples[,c(1,2,4,3)] 
    
    hansard_named_temporal_events_triples[2:3] <- lapply(hansard_named_temporal_events_triples[2:3], tolower)
    
    write_csv(hansard_named_temporal_events_triples, "hansard_named_temporal_events_triples.csv") }

interval <- 10

hansard_named_temporal_events_triples <- hansard_named_temporal_events_triples %>%
  mutate(decade = year - year %% interval)


if(select_events == TRUE) {
  
  events_for_1900 <- c("french revolution",
                       "boer war",
                       "act", 
                       "crimean war")
  
  events_for_1890 <- c("transvaal war",
                       "crimean war",
                       "contagious diseases acts",
                       "indian mutiny",
                       "crimean war",
                       "1881", #tenant seek relief 
                       "treaty", # treaty enter between france
                       "afghan war", # war pay by india 
                       "land act") # tenant seek relief, tenant-labour-under-injustice
  
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
  
  events_for_1870 <- c("zulu war",
                       "afghan war",
                       "crimean war",
                       "contagious diseases acts",
                       "act of 1869",
                       "act",
                       "american war",
                       "war of independence",
                       "vietriples_counta exhibition",
                       "french treaty",
                       "indian mutiny",
                       "treaty",
                       "treaty of san stefano")
  
  events_for_1860 <- c("french revolution",
                       "crimean war",
                       "revolution",
                       "russian war",
                       "great exhibition")
  
  events_for_1850 <- c("french revolution",
                       "vietriples_counta conference",
                       "revolution",
                       "chinese passengers act")
  
  events_for_1840 <- c("french revolution",
                       #"lent",
                       "st. domingo",
                       "revolution",
                       "revolution of 1688",
                       "treaty")
  
  events_for_1830 <- c("french revolution", 
                       "national convention",
                       "revolution",
                       #"lent",
                       "st. domingo",
                       "1807", 
                       "st. domingo and guadaloupe")
  
  events_for_1820 <- c("french revolution",
                       "spanish revolution",
                       "revolution",
                       "st. domingo", 
                       "french war")
  
  events_for_1810 <- c("french revolution", 
                       "crimean war",
                       "american war",
                       "revolution of 1688", 
                       "grand orange lodge") 
  
  events_for_1800 <- c("st. domingo",
                       "revolution",
                       "convention of cintra") }


if(select_triples == TRUE) {
  
  triples_for_1900 <- c("it-be-in-1794", "country-be-in-jeopardy", "word-speak-against-king", #  french rev: no other options
                        "history-mislead-by-error", "we-have-war", "exaggeration-indulge-during-war", # boer war: history-begin-in-1795, officer-reemploye-during-emergency, officer-hold-rank
                        "tenant-do-repair", "tenant-hold-farm", "tenant-have-landlord", # act of 1881: no other options  
                        "debt-stand-in-1866", "he-propose-taxation", "we-march-through-london") # crimean war: battalion-volunteer-for-service, we-think-with-complacency, minister-yield-allegiance
  
  triples_for_1890 <- c("which-cost-million", "we-liberate-portion", "i-ask-for-war", # crimean war: no other options
                        "regulation-regard-disease", "regulation-introduce-into-perak", "acts-be-in-force", # contagious disease acts: police-engage-in-cotriples_countection, police-live-on-ship, regulation-regard-disease, operation-have-effect
                        "tenant-seek-relief", "tenant-deprive-of-benefit", "privilege-confer-upon-tenant", # 1881: state-vote-without-voice, lessee-apply-for-relief, lessor-enforce-right, lessor-grant-relief, grievance-be-of-consequence
                        "state-vote-without-voice", "million-squander-on-war", "india-go-through-experience", # afghan war: state-vote-without-voice, million-squander-on-frontier, parliament-vote-in-1880, india-go-through-much, it-go-in-famine
                        "tenant-pay-rent", "tenant-refund-by-landlord", "tenant-refund-difference", # land act: tenant-lodge-for-year, government-consider-proposal
                        "tariff-come-into-force", "end-put-to-war", "treaty-negotiate-in-1882", # treaty: treaty-contain-stipulation, britain-defend-acheenese, britain-defend-from-aggression
                        "soldier-wound-in-action", "which-lame-him", "which-lame-for-life") # indian mutany: money-await-claimant
  
  triples_for_1880 <- c("drunketriples_countess-decrease-in-city", "torpedo-bring-to-country", "drunketriples_countess-decrease-from-1871", # 1881: tunis-be-independent, government-arrange-for-dissolution, parliament-promise-to-tenant, act-fix-rent
                        "hydrographer-make-investigation", "increase-pay-by-tenant", "landlord-pay-for-disturbance", # 1870: property-have-protection, tenant-have-claim, landlord-acquire-right, government-exercise-surveillance
                        "glander-prevail-among-horse", "member-confound-with-russia", "vessel-arrive-at-suez", #1882: failure-necessitate-action, land-be-at-unlet
                        #"arrest-increase-during-period", "arreset-increase-in-county", "intemperance-decrease-in-district", # I cant figure out which event/ date these belong to
                        "they-complete-curlew", "party-have-right", "overseer-misdescribe-nature", # 1885: we-avoid-danger, majesty-despatch-with-hope, lord-criticize-provision
                        "france-be-independent", "tunis-be-independent", "engagement-take-by-country", # treaty: treaty-be-insufferable, france-have-treaty, treaty-be-disappointing
                        "war-labour-in-gloom", "order-send-for-army", "order-send-for-gun", # crimean war: germany-be-concern, beaconsfield-increase-force, rent-make-by-farmer, country-help-turkey
                        "england-make-contribution", "500-grant-from-fund", "500-grant-reward", # afghan war: contribution-make-by-government, year-darken-by-war, government-be-ashamed, i-come-to-war
                        "bill-propose-repeal", "disease-rise-between-year", "disease-rise-in-number", # contagious diseases acts: officer-attend-meeting, ward-become-large, officer-command-regiment
                        "expenditure-incur-in-year", "he-ask-for-war", "officer-reward-for-service", # zulu war: chiefs-cede-to-boers, war-break-in-spring, he-command-troop, they-engage-in-war
                        "they-engage-in-war", "government-protect-ally", "government-protect-from-ruin", # transvaal war: boers-make-war, difficulty-appear-from-papers
                        "operation-be-effectual", "bill-propose-repeal", "disease-rise-in-number", # contagious disease acts: state-be-terrible, young-be-rampant, ward-become-large
                        "mutiny-come-after-war", "concession-grow-gloomy", "concession-have-trouble", # american war: no other options
                        "landlord-remove-tenant", "tenant-entitle-to-compensation", "tenant-receive-notice", # amendment: bill-read-mischievous, government-feel-bind, he-reject-amendment, system-oppose-amendment
                        "catholics-attend-service", "prayer-read-for-catholics", "troopship-have-chaplain") # service of protestant chaplains: chaplain-be-available, prayer-read-by-officer, troopship-have-chaplain
  
  triples_for_1870 <- c("woman-take-into-custody","woman-take-without-warrant", "woman-detain-in-hospital", # act: they-complain-of-tramway, person-keep-shop, parliament-pass-act, construction-adopt-by-public
                        "they-have-war", "sum-cover-expenditure", "bonds-make-total", # zulu war: they-be-anxious, troop-engage-during-day, gentleman-be-confident, colonists-be-incline
                        "khan-be-loyal", "india-contribute-for-expenditure", "government-plunge-into-war", # afghan war: i-remember-war, he-be-surprised, war-bring-to-close, war-involve-charge
                        "war-increase-debt", "sum-be-great", "war-commence-in-1854", # crimean war: gentleman-reduce-cavalry, commission-appoint-in-1857, difficulty-lead-to-promulgation, war-follow-period
                        "woman-detain-in-hospital", "woman-subject-by-order", "woman-subject-to-examination", # contagious disease acts: man-have-idea, woman-put-in-position, paris-have-population
                        "woman-detain-in-hospital", "penalty-impose-in-england", "gentleman-direct-against-act", # act of 1869: woman-subject-to-examination 
                        "debate-occur-in-1775", "objection-raise-in-1781", "pauperism-increase-between-1859", # american war: troop-occupy-position, it-advise-sovereign, it-be-beyond-duty
                        "cruelty-perpetrate-for-year", "cruelty-perpetrate-upon-them", "rayahs-enjoy-protection", # war of independence: no other options
                        "injustice-commit-under-cover", "reply-be-inconclusive", "which-force-conviction", # vietriples_counta exhibition: no other options
                        "treaty-conclude-in-1860", "which-organize-during-famine", "minister-extend-power", # french treaty: no other options 
                        "dissatisfaction-prevail-in-china", "sultan-atriples_countounce-at-council", "china-open-port", # treaty: chancellor-include-in-budget, government-accede-to-suggestion, opium-admit-into-japan, nation-be-prepared
                        "indemnity-pay-by-turkey", "indemnity-pay-to-russia", "integrity-guarantee-by-powers") #, # treaty of san stefano: no other options
  # "discontent-be-strong", "country-ruin-by-war", "statesman-foresee-downfall", # french revolution: find the correct decade 
  # "parliament-have-courage", "presbytery-appoint-minister", "house-disregard-restriction") # revolution: find the correct decade 
  
  triples_for_1860 <- c("colony-separate-from-england", "i-examine-before-revolution", "she-tax-them", # american revolution 
                        "artist-expose-themselves", "salviati-come-to-england", "artist-have-copyright", # great exhibition 
                        "revolution-stimulate-feeling", "centralization-contribute-to-destruction", "french-take-possession", # french revolution
                        "support-be-prepared", "you-disestablish-church", "lords-guarantee-between-england", # protestant revolution
                        "declaration-adopt-in-1856", "poles-maintain-contest", "militia-supply-man", # crimean war 
                        "paper-establish-throughout-italy", "paper-oppose-progress", "revolution-take-place", # revolution 
                        "dissenters-attract-by-declaration", "jesuitism-insinuate-into-affair", "power-become-supreme") # rev of 1688
  
  triples_for_1850 <- c("vessel-carry-passenger", "vessel-bind-for-havatriples_countah", "110-perish-on-voyage",
                        "bourbons-restore-to-throne", "neutrality-conclude-between-denmark", "restitution-make-for-property",
                        "manufacture-be-on-increase", "object-exclude-catholics", "person-be-anxious",
                        "constitution-become-protestant", "act-pass-after-revolution", "they-suffer-under-enactment",
                        "turks-cross-danube", "turks-declare-war", "one-inspire-by-fanaticism")
  
  triples_for_1840 <- c("revolution-be-in-1792", "revolution-be-at-height", "religion-suffer-in-revolution",
                        #"performance-allow-during-lent", "performance-tolerate-during-lent", "duty-be-severe",
                        "law-enact-in-country", "law-enact-in-1688", "system-endure-since-1688-he",
                        "england-establish-faith", "england-shake-domination", "prophet-speak-of-day",
                        "crop-become-unproductive", "prospect-offer-in-country", "he-extend-to-cuba",
                        "americans-have-right", "spain-have-right", "england-watch-over-welfare")
  
  triples_for_1830 <- c("papists-invade-in-country", "atrocity-perpetrate-under-excitement", "countryman-raise-impostor",
                        "dissolution-take-before-revolution", "spain-disgrace-by-atrocity", "event-inflame-people",
                        #"prince-pray-for-relaxation", "he-approve-of-relaxation", "it-observe-on-friday",
                        "christianity-abjure-in-1793-in", "slave-send-for-emancipation", "france-reap-from-assembly",
                        "population-enjoy-happiness", "young-be-in-error", "country-border-on-anarchy",
                        "change-take-place", "constitution-be-different", "rebellion-produce-feeling",
                        "domingo-lose-possession", "domingo-sever-from-france", "she-exercise-sovereignty",
                        "buonaparte-contemplate-slavery", "plantation-cultivate-by-labourer", "plantation-cultivate-in-1801")
  
  triples_for_1820 <- c("pope-excommunicate-council", "scarcity-prevail-over-country", "taxation-produce-revolution",
                        "revolution-take-place", "they-acknowledge-him", "they-acknowledge-for-king",
                        "law-pass-against-bribery", "ancestor-consider-at-revolution", "history-date-from-reformation",
                        "war-excite-uneasiness", "government-seize-property", "government-seize-in-violation",
                        "sugar-have-regulation", "sugar-smuggle-into-part", "petitioner-grant-emancipation")
  
  triples_for_1810 <- c("distress-reach-height", "troop-maintain-by-guinea", "crime-augment-in-war",
                        "revolution-spread-throughout-world", "revolution-be-in-vigour", "independence-swallow-in-gulf",
                        "sentiment-take-place", "sentiment-take-in-dublin", "sentiment-express-in-parliament",
                        "it-assail-church", "country-deprive-of-trade", "ireland-recover-trade")
  
  triples_for_1800 <- c("baird-sail-on-9th", "baird-receive-intelligence", "we-send-for-army",
                        "fate-deter-us", "critic-estimate-production", "critic-be-unreasonable",
                        "general-order-delinquent", "court-exercise-power", "they-labour-in-consequence",
                        "that-desolate-world", "which-be-for-year") }


decades <- c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900")

for (i in 1:length(decades)) {
  
  #d <- decades[i]
  d <- 1870
  
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
  
  #counted <- counted_events %>% # notice that I changed counted to counted_events for this experiment
  #  distinct(decade, entity, triple, n, .keep_all = T)
  
  # counted <- counted[,c(1,2,4,3)] 
  
  # viz_version_1 <- entites_triples_w_event_count[,c(2,5,4,3)] 
  
  #version_1 <- viz_version_1 %>%
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
  #filter(triples_count >= 2) %>%
  #  ungroup()
  

  # destroy_event <- tibble("entity" = c("war", "three years", "1887", "1884", "1883", "1886"))  
  # clean_counted <- for_clean_counted %>%
  #   anti_join(destroy_event)
  
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
  
  #include_triples_count <- include_triples_count %>%
  #  distinct(event, triple, .keep_all = T)
  
  include_triples_count$triples_count <- gsub("^", "(", include_triples_count$triples_count)
  include_triples_count$triples_count <- gsub("$", ")", include_triples_count$triples_count)
  
  include_triples_count$triple_and_count <- paste(include_triples_count$triple, include_triples_count$triples_count)
  
  
  for_viz_option_2 <- include_triples_count %>% #matched_triples %>% 
    group_by(entity) %>%
    #mutate(flattened = paste0(concatenate(triple, collapse = ": "))) %>%
    mutate(flattened = paste0(concatenate(triple_and_count, collapse = ": "))) %>%
    select(-triple) %>%
    select(-triples_count) %>% # if I am using include_triples_count
    select(-triple_and_count) %>% # if I am using include_triples_count
    ungroup()
  
  
  n <- 3
  pat <- paste0('^([^:]+(?::[^:]+){',n-1,'}).*') # mine
  for_viz_option_2$flattened <- sub(pat, '\\1', for_viz_option_2$flattened)
  
  
  for_viz_option_2$flattened <- gsub(":", ";  ", for_viz_option_2$flattened)
  
  for_viz_option_2 <- for_viz_option_2 %>%
    distinct(decade, entity, n, flattened) 
  
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
  
  option_2$entity <- option_2$entity %>%
    str_to_title()
  
  option_2$entity <- option_2$entity %>%
    str_to_title() 
  
  # contents can be copied/pasted into a word doc
  # inside the word doc, the user can highlight the contents and go to table -> convert -> convert text to table 
  write.table(option_2, paste0(file = "triples_table_", d, ".txt"), sep = ",", quote = FALSE, row.names = F)
  
  #html <- option_2 %>%
  option_2 %>%
    gt() %>%
    tab_header(title = md(paste0("Lemmatized Triples Co-Occuring with Temporal Events in ", d)),
               subtitle = md("Searching the Hansard Parliamentary Debates")) %>%
    tab_source_note(source_note = md("Description: Three triples per event chosen for exemplarity Triple count is in parentheses.")) %>%
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
