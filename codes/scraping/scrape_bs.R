
library(rvest)
library(XML)

urls <- c("http://forum.brightsparks.com.sg/forumdisplay.php?f=3",
          "http://forum.brightsparks.com.sg/forumdisplay.php?f=4")

one.url <- "http://forum.brightsparks.com.sg/forumdisplay.php?f=5"

for(one.url in urls){
    
    forum.page.html <- html(one.url)
    
    alt1active.nodes <- html_nodes(forum.page.html, ".alt1Active")
    
    foo <- newXMLNode(alt1active.nodes[[1]])
    
    saveXML(foo, "codes/scraping/tmp_bs.xml")
    
    tborder.parsed <- htmlTreeParse("codes/scraping/tmp_bs.xml", useInternal = T)
    
    html_nodes(tborder.parsed, )
}

# ====

html_nodes(forum.page.html, "#threadslist")

html_nodes(forum.page.html, "a, #threadslist")

html_nodes(forum.page.html, ".alt1, a")
