
library(rvest)
library(XML)

urls <- c("http://www.moe.gov.sg/media/press/2015/"
          ,"http://www.moe.gov.sg/media/press/2014/"
          ,"http://www.moe.gov.sg/media/press/2013/"
          ,"http://www.moe.gov.sg/media/press/2012/"
          ,"http://www.moe.gov.sg/media/press/2011/"
          ,"http://www.moe.gov.sg/media/press/2010/")

news.vec <- NULL

for(one.url in urls){
    
    page.html <- html(one.url)
    
    main.content.nodes <- html_nodes(page.html, "#main-content")
    
    saveXML(html_nodes(page.html, "#main-content")[[1]], "codes/tmp_moe.xml")
    
    main.content.parsed <- htmlTreeParse("codes/tmp_moe.xml", useInternal = T)
    
    news.entry.nodes <- html_nodes(main.content.parsed, ".media-archive-entry")
    
    for(j in seq(length(news.entry.nodes))){
        
        news.topic <- xmlValue(news.entry.nodes[[j]])
        
        date <- unlist(strsplit(news.topic, split = "\r\n"))[2]
        topic <- unlist(strsplit(news.topic, split= "\r\n"))[3]
        
        news.vec <- c(news.vec, date, topic)
    }
}

news.df <- data.frame(matrix(news.vec,
                             nrow = length(news.vec)/2, ncol = 2,
                             byrow = T))

colnames(news.df) <- c("Date", "Entry")
