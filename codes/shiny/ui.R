# ui.R

shinyUI(fluidPage(
    
    titlePanel("MOE POC - kiasuparents.com"),
    
    mainPanel(
        tabsetPanel(
            tabPanel("1. Timeline"),
            tabPanel("2. Keywords")
        )
    )
    
))