library(tidyverse)
library(tidytext)
library(googleVis)
library(shiny)



filtered <- filtered %>%
  unnest_tokens(text, text, token = "ngrams", n = p)

filtered_2 <- filtered %>%
  filter(str_detect(text, "^landlord"))


# remember to make project that I can host on ShinyServer -- and read in the landlord data csv 
#triples <- read_csv()




ui <- fluidPage(
  
  titlePanel("Placeholder"),
  
  sidebarPanel(
    selectInput("dataset", "Selection:", 
                choices = c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900", "1910")),
    selectInput("term", "Selection:",
                choices = c("power", "landlord")),
    selectInput("length", "Selection:",
                choices = c("10", "25")),
    width = 2),
  
  mainPanel(htmlOutput("view")),
  width = 20)
  

server <- function(input, output) {
  data_input <- reactive({
    switch(input$dataset,
           "1800" = 1800,
           "1810" = 1810,
           "1820" = 1820,
           "1830" = 1830,
           "1840" = 1840,
           "1850" = 1850,
           "1860" = 1860,
           "1870" = 1870,
           "1880" = 1880,
           "1890" = 1890,
           "1900" = 1900,
           "1910" = 1910) })
  
  data_input_2 <- reactive({
    switch(input$term,
           "power" = "power",
           "landlord" = "landlord") })
  
  data_input_3 <- reactive({
    switch(input$length,
           "10" = 10,
           "25" = 25) })
  
  
  
  output$view <- renderGvis({
    
    dataset <- data_input()
    
    out <- triples %>%
      filter(decade == dataset)
    
    ###########
    p <- reactive({input$length})
    
    out <- out %>%
      unnest_tokens(text, text, token = "ngrams", n = p())
    ######################

    w <- reactive({input$term})

    if (w() == "power") {
      gvisWordTree(out, #data_input(),
                 textvar = "text",
                 options = list(fontName = "Times-Roman",
                                maxFontSize = 15,
                                wordtree = "{word: 'power'}",
                                width = 1800)) } else if(w() == "landlord") {
                                  
                                  gvisWordTree(out,
                                               textvar = "text",
                                               options = list(fontName = "Times-Roman",
                                                              maxFontSize = 15,
                                                              wordtree = "{word: 'landlord'}",
                                                              width = 1800))}  })}

   

shinyApp(ui, server)
