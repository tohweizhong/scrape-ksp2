# Harvest Facebook Information

#_________________________________________________________________________________________
# there are two ways of doing it

# OPtion One: facepager GUI 

# App ID = 1477669212529680
# App Secret = c6c779f5b92b98888ed5c539d66461d1

# get the access token from https://smashballoon.com/custom-facebook-feed/access-token/

# fetch the data and save it into CSV N.B. the seperator is ";"

# example of reading a .csv file
# read.csv(file = "C:/Users/chenxi/Desktop/example.csv", sep = ";")
#_________________________________________________________________________________________

# Option Two: Using Rfacebook package to scrape facebook information

## install_packages("Rfacebook")
library(Rfacebook)
library(devtools)
# A token can be generated here: https://developers.facebook.com/tools/explorer.
# NB: This token generated is temporary - valid for 2 hrs only. To generate 
# a 'long-lived' token that is valid for 2 months, use the fbOAuth function.

# Alternatively the token can be found from
# https://smashballoon.com/custom-facebook-feed/access-token/
# in the website below by providing yourapp ID and app Secret
# App ID = 1477669212529680
# App Secret = c6c779f5b92b98888ed5c539d66461d1
# N.B. no information on the valid period of the token generated from the website above

token <- "1477669212529680|RumqzSWyLlxXbifMqSKNDDv2Nyw"

# Created App at Facebook developers "AndrewZ", site url = http://localhost:1410/

fb_oauth <- fbOAuth(app_id="1477669212529680", app_secret="c6c779f5b92b98888ed5c539d66461d1")
save(fb_oauth, file="fb_oauth")
load("fb_oauth")
# fb_oauth doesn't work because i do not have live app, so use temporary token.
# After the introduction of version 2.0 of the Graph API, only friends who are 
# using the application used to generate the token to query the API will be returned

# for getFriends.
my_friends <- getFriends(token=token, simplify=TRUE)
me1 <- getUsers("me", token=token, private_info = TRUE)
my_likes <- getLikes(user="me", token=token)

# Again, only friends who use the Graph API will be returned
mat <- getNetwork(token=token, format="adj.matrix")
library(igraph)
network <- graph.adjacency(mat, mode="undirected")
pdf("network_plot.pdf")
plot(network)
dev.off()

# capturing 100 most recent posts on my newsfeed. Error because my account does 
# not allow extended permission
my_newsfeed <- getNewsfeed(token=token, n=100)

# Getting posts from the admin of a specific facebook page, including reposts by 
# other users, feed = FALSE if no reposts
# Max no. of post from getPage is 100

page <- getPage(page="humansofnewyork", token=token,n=50, feed=TRUE)
page1 <- getPage(page="humansofnewyork", token=token,n=50, feed=FALSE)
page2 <- getPage(page="thestraitstimes", token=token,n=50, feed=FALSE)
page3 <- getPage(page="PunggolPrimary", token=token, feed=FALSE)
page4 <- getPage(page="377018182346496", token=token, feed=FALSE)

# N.B. in practice, for url is in the form of https://www.facebook.com/PunggolPrimary
# the string of the page = 'PunggolPrimary'
# see page3
# for url is in the form of https://www.facebook.com/South-View-Primary-School-377018182346496
# the string of the page is the suffix number '377018182346496' ,i.e. page =  '377018182346496'
# see page4
# for url is in the form 
# https://www.facebook.com/pages/Sembawang-Primary-School/114836068549583
# note that in such page the post are not from the admin of the page
# the page is the suffix number, i.e. page = '114836068549583' and with the feed = TRUE


# searchFacebook is no longer functionable with version 2.0 of Facebook Graph API
# alternative is to use searchPages/getPage and searchGroup
pages_Rprog <- searchPages( string="R programming", token=token, n=50 )
pageid <- pages_Rprog[3,1]
pages_Rprog_post <- getPage(page=pageid, token=token,n=10, feed=FALSE)



