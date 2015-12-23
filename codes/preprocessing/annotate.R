# annotate topics

# search in both topic and posts

# can read in a metafile here
#keywords <- c("PSLE", "Primary School Leaving Examination")


keywords <- readLines("data/meta/keywords.txt")
sentiments <- readLines("data/meta/sentiments.txt")

keywords <- c(keywords, sentiments)

# function to tag
Tag <- function(df, keywords){
    
    all.tags <- NULL
    
    for(i in seq(nrow(df))){
        one.topic <- df$Topic[i]
        one.post  <- df$Post[i]
        
        tmp.tags <- NULL
        
        for(j in seq(length(keywords))){
            one.keyword <- keywords[j]
            if(grepl(one.topic, pattern = one.keyword)){
                tmp.tags <- c(tmp.tags, one.keyword)
            }else if(grepl(one.post, pattern = one.keyword)){
                tmp.tags <- c(tmp.tags, one.keyword)
            }else{
                tmp.tags <- c(tmp.tags, NA)
            }
        }
        
        
        all.tags <- c(all.tags, list(tmp.tags))
    }
    return(all.tags)
}

# # trying out
# try.df <- clean.df[20:60,]
# foo <- Tag(df = try.df, keywords = keywords)
# str(foo)

#tags <- Tag(df = clean.df, keywords = keywords)


# rewrite the tagging function in a more efficient manner
# input: df and vector of keywords
# output: a sparse binary matrix indicated which post has a given keyword

Tag2 <- function(df, keywords){
    
    # function to match one keyword within one entry
    isIn <- function(entry, keyword){
        if(grepl(entry, pattern = keyword, ignore.case = TRUE) == TRUE)
            return(1)
        else return(0)
    }
    
    
    indicator.matrix <- matrix(NA, nrow = nrow(df), ncol = 1)

    for(a.keyword in keywords){
        
        indicate.topic <- NULL
        indicate.post  <- NULL
        
        indicate.topic <- c(indicate.topic, unlist(sapply(df$Topic, FUN = isIn, keyword = a.keyword)))
        indicate.post  <- c(indicate.post, unlist(sapply(df$Post,  FUN = isIn, keyword = a.keyword)))
        
        topicPlusPost <- as.logical(indicate.topic + indicate.post)
        indicator.matrix <- cbind(topicPlusPost, indicator.matrix)
    }

    indicator.df <- data.frame(indicator.matrix[, -ncol(indicator.matrix)])
    colnames(indicator.df) <- keywords
    
    return(indicator.df)
}

#foo <- Tag2(try.df, keywords = keywords)
annotations <- Tag2(clean.df, keywords = keywords)


save(list=c("annotations"),file="data/clean/annotations-21092015.RData")

