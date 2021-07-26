## Please note that by default the googleVis plot command
## will open a browser window and requires Internet
## connection to display the visualisation.

library(googleVis)

wt1 <- gvisWordTree(Cats, textvar = "Phrase")
plot(wt1)

Cats2 <- Cats
Cats2$Phrase.style <- ifelse(Cats$Sentiment >= 7, "green", 
                             ifelse(Cats$Sentiment <= 3, "red", "black"))

wt2 <- gvisWordTree(Cats2, textvar = "Phrase", stylevar = "Phrase.style",
                    options = list(fontName = "Times-Roman",
                                   wordtree = "{word: 'cats'}",
                                   backgroundColor = "#cba"))
plot(wt2)

# Explicit word tree
exp.data <- data.frame(id = as.numeric(0:9),
                       label = letters[1:10],
                       parent = c(-1, 0, 0, 0, 2, 2, 4, 6, 1, 7),
                       size = c(10, 5, 3, 2, 2, 2, 1, 1, 5, 1),
                       stringsAsFactors = FALSE)

wt3 <- gvisWordTree(exp.data, idvar = "id", textvar = "label", 
                    parentvar = "parent", sizevar = "size",
                    options = list(wordtree = "{format: 'explicit'}"),
                    method = "explicit")
plot(wt3)
