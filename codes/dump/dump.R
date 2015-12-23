# Function to split timestamp into day and time
SplitTimestamp <- function(entry){
    
    l <- strsplit(entry, split = " ", fixed = T)
    vec <- l[[1]]
    day <- vec[1]
    mth <- match(vec[2], month.abb)
    date <- strsplit(vec[3], split = ",")[[1]][1]
    yr <- vec[4]
    time <- str_c(vec[5], vec[6], sep = "")
    
    full.string <- paste(yr, "-", mth, "-", date, " ", time, " +0800", sep = "")
    
    full.time <- strptime(full.string, "%Y-%m-%d %I:%M%p %z")
    
    #         
    #         full.date <- as.Date(str_c(yr, mth, date, sep = "-"), "%Y-%m-%d")
    #         full.time <- as.Date(str_c(full.date, time, "+0800", sep = " "), "%Y-%m-%d %I:%M%p %z")
    #         
    return(full.time)
}

# change the timestamp datatype
tmp <- tapply(df$Timestamp, FUN = SplitTimestamp)
df$Day <- tmp[1,]
df$Date <- tmp[2,]
df$Time <- tmp[3,]