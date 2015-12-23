# code currently only works using the rvest pkg, version 0.2.0 (latest version: 0.3.0)
# to install this specific version of rvest, run the following:
# packageurl <- "https://cran.r-project.org/src/contrib/Archive/rvest/rvest_0.2.0.tar.gz"
# install.packages(packageurl, repos=NULL, type="source")

# load required packages
library(rvest)
library(XML)

source("codes/scraping/ScrapeFromTopicURL.R")

# Access the main forum page
ksp <- html("http://www.kiasuparents.com/kiasu/forum/index.php")

# Access all nodes with CSS ".forabg"
# These are the boards
nodes <- html_nodes(ksp, ".forabg")

# Only take the 3rd .forabg node, for the schooling board
# save to a file
saveXML(html_nodes(ksp, ".forabg")[[3]], "codes/schooling.xml")

# parse it
schooling.board <- htmlTreeParse("codes/schooling.xml", useInternal = T)

# extract all the URLs linking to the forums
forum.urls <- html_nodes(schooling.board, ".forabg .forumtitle")

# objects that should not be removed
dont.remove <- c("ksp", "nodes", "schooling.board", "forum.urls")

for(i in seq(7)){ # 7 iterations for the schooling board
    #seq(length(forum.urls)
    # URL to one forum
    forum.url <- xmlAttrs(forum.urls[[i]])[1]
    print(forum.url)
    
    # forum name
    forum.name <- xmlValue(forum.urls[[i]])
    print(forum.name)
    
    # Access the ith forum
    forumpage <- html(forum.url)
    
    # Access all nodes with CSS ".forumbg"
    # These are the topics
    nodes <- html_nodes(forumpage, ".forumbg")
    cat(paste("number of .forumbg: ", length(nodes), "\n", sep = ""))
    
    # Count how many topics are there
    forum.pages <- html_nodes(forumpage, ".pagination")
    temp2 <- gregexpr("[0-9]+", xmlToList(forum.pages[[1]])$text)
    numTopics <- as.numeric(unique(unlist(regmatches(xmlToList(forum.pages[[1]])$text, temp2))))
    numPages <- ceiling(numTopics/50)
    
    cat(paste("number of topics: ", numTopics, "\n", sep = ""))
    cat(paste("number of pages: ", numPages, "\n", sep = ""))
    
    exception.forums <- c("Primary Schools - Academic Support",
                          "Secondary Schools - Academic Support",
                          "Tertiary Education - A-Levels, Diplomas, Degrees")
    
    # iterate through all the pages
    for(j in seq(numPages)){
        
        # one data.frame for one page, to be written to file
        forum.df <- NULL
        
        if(j == 1){
            
            # Create a tmp xml file
            # Special case for Primary Schools - Academic Support
            if(forum.name %in% exception.forums){
                saveXML(html_nodes(forumpage, ".forumbg")[[1]], "codes/tmp.xml")
            }
            else if(!(forum.name %in% exception.forums)){
                saveXML(html_nodes(forumpage, ".forumbg")[[2]], "codes/tmp.xml")
            }
            # parse it
            topics <- htmlTreeParse("codes/tmp.xml", useInternal = T)
            
            # extract the posts and replies
            topics.replies <- html_nodes(topics, ".posts")
            topics.views <- html_nodes(topics, ".views")
            
            # extract all the URLS linking to all topics, and their titles
            topics <- html_nodes(topics, ".topictitle")
            
            # now loop through all the topics
            for(k in seq(length(topics))){
                
                topic.replies <- xmlValue(topics.replies[[k+1]])
                topic.views <- xmlValue(topics.views[[k+1]])
                cat(paste(Sys.time(), " || Replies: ", topic.replies, " || ", sep = ""))
                #print(topic.views)
                
                topic.url <- xmlAttrs(topics[[k]])["href"]
                topic.title <- xmlValue(topics[[k]])
                
                topic.df <- ScrapeFromTopicURL(topic.url)
                
                topic.df <- cbind(rep(forum.name, nrow(topic.df)),
                                  rep(topic.title, nrow(topic.df)),
                                  rep(topic.replies, nrow(topic.df)),
                                  rep(topic.views, nrow(topic.df)),
                                  topic.df)
                
                forum.df <- rbind(forum.df, topic.df)
                
                #View(forum.df)
                cat(paste("Rows so far: ", dim(forum.df)[1], "\n", sep = ""))
                
            }
            colnames(forum.df) <- c("Forum", "Topic", "Replies", "Views",
                                    "User.timestamp", "Post", "isOrginal")
            
            if(j < 10) charnum <- paste("0", j, sep = "")
            else charnum <- as.character(j)
            
            filename <- paste("data/raw/", forum.name, "-", charnum, ".csv", sep = "")
            cat(paste("Writing ", filename, "\n", sep = ""))
            write.table(forum.df, filename,
                      sep = "sepsepsep", eol = "\n", row.names = F, quote = F)
           
        }
        else if(j > 1){
            startNum <- (j-1)*50
            nextPage.url <- paste(forum.url, "&start=", startNum, sep = "")
            print(nextPage.url)
            
            
            # to parse a single forum page, run from here till write.table():
            # must also run forum.df <- NULL
            next.forum.page <- html(nextPage.url)
            nodes <- html_nodes(next.forum.page, ".forumbg")
            
            # Create a tmp xml file
            if(forum.name %in% exception.forums){
                saveXML(html_nodes(next.forum.page, ".forumbg")[[2]], "codes/tmp.xml")
            } else if(!(forum.name %in% exception.forum))
                saveXML(html_nodes(next.forum.page, ".forumbg")[[1]], "codes/tmp.xml")
            
            # parse it
            topics <- htmlTreeParse("codes/tmp.xml", useInternal = T)
            
            # extract the posts and replies
            topics.replies <- html_nodes(topics, ".posts")
            topics.views <- html_nodes(topics, ".views")
            
            # extract all the URLS linking to all topics, and their titles
            topics <- html_nodes(topics, ".topictitle")
            
            # now loop through all the topics
            for(k in seq(length(topics))){
                
                topic.replies <- xmlValue(topics.replies[[k+1]])
                topic.views <- xmlValue(topics.views[[k+1]])
                
                ##########################
                cat(paste(Sys.time(), " || Replies: ", topic.replies, " || ", sep = ""))
                
                topic.url <- xmlAttrs(topics[[k]])["href"]
                topic.title <- xmlValue(topics[[k]])
                
                topic.df <- ScrapeFromTopicURL(topic.url)
                
                topic.df <- cbind(rep(forum.name, nrow(topic.df)),
                                  rep(topic.title, nrow(topic.df)),
                                  rep(topic.replies, nrow(topic.df)),
                                  rep(topic.views, nrow(topic.df)),
                                  topic.df)
                
                forum.df <- rbind(forum.df, topic.df)
                
                #View(forum.df)
                cat(paste("Rows so far: ", dim(forum.df)[1], "\n", sep = ""))
            }
            
            colnames(forum.df) <- c("Forum", "Topic", "Replies", "Views",
                                    "User.timestamp", "Post", "isOrginal")
            
            if(j < 10) charnum <- paste("0", j, sep = "")
            else charnum <- as.character(j)
            
            filename <- paste("data/raw/", forum.name, "-", charnum, ".csv", sep = "")
            cat(paste("Writing ", filename, "\n", sep = ""))
            write.table(forum.df, filename,
                      sep = "sepsepsep", eol = "\n", row.names = F, quote = F)
        }
    }
    rm(list = setdiff(ls(), dont.remove))
    gc()
}
