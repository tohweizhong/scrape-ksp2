
library(rvest)
library(XML)


# Function to scrape data from one topic url
# url is a string not an external pointer
ScrapeFromTopicURL <- function(url){
    
    topic <- html(url)
    
    # Few things to do here:
    # 1. Look at the total number of pages of posts for this topic
    # 2. Iterate through all the pages (start=?)
    # 3. For each page, each post,
    # @ a.Extract the user and timestamp
    # @ b. Extract the text
    # @ c. Look at whether its the original text or not
    
    topic.pages <- html_nodes(topic, ".pagination")
    temp2 <- gregexpr("[0-9]+", xmlToList(topic.pages[[1]])$text)
    numPosts <- as.numeric(unique(unlist(regmatches(xmlToList(topic.pages[[1]])$text, temp2))))
    numPages <- ceiling(numPosts / 10)
    users.timestamp <- NULL
    text.posts <- NULL
    
    for(i in seq(numPages)){
        
        if(i == 1){ # first page of topic
            all.users <- html_nodes(topic, ".author")
            all.posts <- html_nodes(topic, ".inner .content")
            
            for(j in seq(length(all.users))){
                users.timestamp <- c(users.timestamp, xmlValue(all.users[[j]]))
            }
            for(j in seq(length(all.posts))){
                l <- xmlToList(all.posts[[j]])
                names <- unlist(strsplit(names(l), " "))
                which.are.text <- which(names == "text")
                
                trimmed <- gsub("\r?\n|\r", " ", unlist(l[which.are.text]))
                
                text.posts <- c(text.posts, paste(trimmed, collapse = " "))
            }
        }
        
        else if(i > 1){
            startNum <- (i-1)*10
            nextPage.url <- paste(url, "&start=", startNum, sep = "")
            
            topic.page <- html(nextPage.url)
            all.users <- html_nodes(topic.page, ".author")
            all.posts <- html_nodes(topic.page, ".inner .content")
            
            for(j in seq(length(all.users))){
                users.timestamp <- c(users.timestamp, xmlValue(all.users[[j]]))
            }
            for(j in seq(length(all.posts))){
                l <- xmlToList(all.posts[[j]])
                names <- unlist(strsplit(names(l), " "))
                which.are.text <- which(names == "text")
                trimmed <- gsub("\r?\n|\r", " ", unlist(l[which.are.text]))
                
                text.posts <- c(text.posts, paste(trimmed, collapse = " "))
                
#                 if(j == 1){
#                     cat(text.posts[length(text.posts)])
#                     cat("\n")
#                 }
            }
            
        }
        
    }
    
    return.df <- cbind(users.timestamp, text.posts)
    return.df <- cbind(return.df, c("Yes", rep("No", nrow(return.df) - 1)))
    colnames(return.df) <- c("users.timestamp", "post", "isOriginal")
    
    return(data.frame(return.df, stringsAsFactors = F))
}

#example
# foo <- ScrapeFromTopicURL("http://www.kiasuparents.com/kiasu/forum/viewtopic.php?f=27&t=4105")
# str(foo)
# View(foo)
# foo$post[2]
