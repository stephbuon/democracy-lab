library(tidyverse)
library(tidytext)
library(googleVis)
library(shiny)

triples <- read_csv("landlord_have_power.csv")

ui <- fluidPage(
    
    titlePanel("Triples Explorer"),
    
    sidebarPanel(
      helpText("Triple: \"landlord-have-power\""),
      selectInput("period", "Period:", 
                  choices = c("1800", "1810", "1820", "1830", "1840", "1850", "1860", "1870", "1880", "1890", "1900", "1910")),
      selectInput("word", "Word:",
                  choices = c("power", "landlord")),
      selectInput("length", "Phrase Length:",
                  choices = c("Full", "10", "25")),
      width = 2),
    
    mainPanel(htmlOutput("view")),
    width = 20)


server <- function(input, output) {
    period_input <- reactive({
        switch(input$period,
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
    
    pl_input <- reactive({
        switch(input$length,
               "10" = 10,
               "25" = 25) })
    
    
    output$view <- renderGvis({
        period <- period_input()
        
        out <- triples %>%
            filter(decade == period)
        
        ###########
        #p <- reactive({input$length})
        
        #pp <- p()
        
        #out <- out %>%
        #    unnest_tokens(text, text, token = "ngrams", n = pp)
        
        #filtered_2 <- filtered %>%
        #  filter(str_detect(text, "^landlord"))
        
        ###########
        
        word <- reactive({input$word})
        
        if (word() == "power") {
            gvisWordTree(out,
                         textvar = "text",
                         options = list(fontName = "Times-Roman",
                                        maxFontSize = 15,
                                        wordtree = "{word: 'power'}",
                                        width = 1800)) } else if(word() == "landlord") {
                                            
                                            gvisWordTree(out,
                                                         textvar = "text",
                                                         options = list(fontName = "Times-Roman",
                                                                        maxFontSize = 15,
                                                                        wordtree = "{word: 'landlord'}",
                                                                        width = 1800))}  })}



shinyApp(ui, server)
