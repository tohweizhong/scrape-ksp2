
# Function to check for updates in all the forum boards
# This is done by looking at the last post timestamps of each board
# and comparing them to those found in the current local copy of schooling.xml


# ====

CheckForUpdates <- function(){
    
    
    library(rvest)
    library(XML)
    
    # ====
    # Current
    
    # Access the main forum page at current moment
    ksp <- html("http://www.kiasuparents.com/kiasu/forum")
    
    # Access all nodes with CSS ".forabg"
    # These are the boards
    nodes <- html_nodes(ksp, ".forabg")
    
    # Only take the 3rd .forabg node, for the schooling board
    # save to a file
    saveXML(html_nodes(ksp, ".forabg")[[3]], "codes/schooling-updates.xml")
    
    # Parse it
    schooling.updates <- htmlTreeParse("codes/schooling-updates.xml", useInternal = TRUE)
    
    # Extract all last post timestamps for each forum
    last.timestamp <- html_nodes(schooling.updates, ".lastpost")
    
    # Last post timestamp by forum
    curr.last <- list()
    
    for(i in 2:8){
        
        timestamp.string <- xmlValue(last.timestamp[[i]])
        
        trimmed <- gsub("\r?\n|\r|\t", "", timestamp.string)
        trimmed.vec <- unlist(strsplit(trimmed, " "))
        trimmed.vec <- tail(trimmed.vec, n = 5)
        trimmed.vec[2] <- unlist(strsplit(trimmed.vec[2], split = ","))
        
        date <- paste0(trimmed.vec[1:3], collapse = " ")
        time <- paste0(trimmed.vec[4:5], collapse = " ")
        datetime <- paste0(trimmed.vec, collapse = " ")
        
        date <- strptime(date, format = "%b %d %Y")
        time <- strptime(time, format = "%I:%M %p")
        datetime <- as.POSIXct(datetime, format = "%b %d %Y %I:%M %p")
        
        
        curr.last[[i-1]] <- datetime
    }
    
    curr.last
    
    
    
    # ====
    # Previous
    
    # Access the current XML file
    schooling.board <- htmlTreeParse("codes/schooling.xml", useInternal = T)
    
    # Extract all last post timestamps for each forum
    last.timestamp <- html_nodes(schooling.board, ".lastpost")
    
    
    # Last post timestamp by forum
    prev.last <- list()
    
    for(i in 2:8){
        
        timestamp.string <- xmlValue(last.timestamp[[i]])
        
        trimmed <- gsub("\r?\n|\r|\t", "", timestamp.string)
        trimmed.vec <- unlist(strsplit(trimmed, " "))
        trimmed.vec <- tail(trimmed.vec, n = 5)
        trimmed.vec[2] <- unlist(strsplit(trimmed.vec[2], split = ","))
        
        date <- paste0(trimmed.vec[1:3], collapse = " ")
        time <- paste0(trimmed.vec[4:5], collapse = " ")
        datetime <- paste0(trimmed.vec, collapse = " ")
        
        date <- strptime(date, format = "%b %d %Y")
        time <- strptime(time, format = "%I:%M %p")
        datetime <- as.POSIXct(datetime, format = "%b %d %Y %I:%M %p")
        
        prev.last[[i-1]] <- datetime
    }
    
    prev.last
}
# ====


