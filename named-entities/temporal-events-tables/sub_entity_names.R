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
  decade_of_interest$entity <- gsub("the crimean war lord rokeby", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the crimean war the war department", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("the crimean war enormous quantities of stores", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("another crimean War", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("liberals the crimean war", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("recent crimean war", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("that crimean war", "crimean war", decade_of_interest$entity)
  decade_of_interest$entity <- gsub("crimean war bonds", "crimean war", decade_of_interest$entity)
  
  
  
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
