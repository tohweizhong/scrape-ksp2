library(stringr)

all.files <- list.files("data/raw")
clean.df <- NULL

for(a.file in all.files){
    
    cat(paste("Processing ", a.file, "\n", sep = ""))
    
    file.num <- strsplit(a.file, split =".csv")[[1]][1]
    file.num <- as.numeric(str_sub(file.num, start = -2, end = -1))
    
    # Raw data
    a.file.name <- paste("data/raw/", a.file, sep = "")
    lines <- readLines(a.file.name)
    
    # delimit by "sepsepsep"
    vec <- unlist(sapply(lines, FUN = strsplit, split = "sepsepsep", fixed = T, USE.NAMES = F, simplify = F))
    
    # column names
    datafields <- vec[1:7]
    vec <- vec[-c(1:7)]
    
    # convert to data.frame
    df <- data.frame(matrix(vec, ncol = 7, nrow = length(vec)/7, byrow = T), stringsAsFactors = F)
    colnames(df) <- datafields
    
    # preprocessing to do:
    # @ Convert Replies and Views to numeric
    # @ Split user.timestamp
    
    # Function to remove "Replies" or "Views"
    RemoveWord <- function(entry, word){
        return(as.numeric(strsplit(entry, paste(" ", word, sep = ""))[1]))
    }
    
    df$Replies <- unlist(sapply(df$Replies, FUN = RemoveWord, word = "Replies"))
    df$Views <- unlist(sapply(df$Views, FUN = RemoveWord, word = "Views"))
    
    # Function to split user.timestamp
    SplitUserTimestamp <- function(entry){
        
        l <- strsplit(entry, split = " » ", fixed = T)
        timestamp <- l[[1]][2]
        user <- strsplit(l[[1]][1], split = "by ")[[1]][2]
        return(c(user, timestamp))
    }
    
    tmp <- unlist(sapply(df$User.timestamp, FUN = SplitUserTimestamp))
    df$User <- tmp[1,]
    df$Timestamp <- tmp[2,]
    
    # Remove "user.timestamp" column
    df <- subset(df, select = -User.timestamp)
    
    # Add a whichFile column
    df$whichFile <- rep(file.num, times = nrow(df))
    
    # typo in column name isOriginal
    colnames(df)[6] <- "isOriginal"
    
    cat(paste(dim(df), "\n"))
    
    clean.df <- rbind(clean.df, df)
}

dim(clean.df)

# edit row number 138115
clean.df$isOriginal[138115] <- "No"




save(list=c("clean.df"),file="data/clean/kiasuparents-scraped-data-14092015.RData")

write.csv(clean.df, "data/clean/ksp-posts.csv")

View(clean.df)
