# server.R

setwd("C:/Users/weizhong/Documents/R/scrape-ksp")
load("data/clean/kiasuparents-scraped-data-14092015.RData")
load("data/clean/annotations-21092015.RData")
keywords <- read.csv("data/meta/keywords.txt", header = F)

shinyServer(function(input, output, session){
    
    
})
