# preprocess2.R

clean.df2 <- clean.df[1,]

for(i in 2:nrow(clean.df)){
    
    if(i %% 10 == 0) print(i)
    
    current.row <- clean.df[i,]
    numrow <- nrow(clean.df2)
    
    # first check: nchar() < 30
    if(nchar(current.row$Post) < 30)
        next
    
    # second check: clean.df2$User == current.row$User and same forum
    else if(clean.df2$User[numrow] == current.row$User)
        clean.df2$Post[numrow] <- paste(clean.df2$Post[numrow], current.row$Post)
    
    else
        clean.df2 <- rbind(clean.df2, current.row)
    
    
}