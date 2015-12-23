library(Rfacebook)

token <- "1477669212529680|RumqzSWyLlxXbifMqSKNDDv2Nyw"
#token <- "13cbe5e9919a74db7ebc9d0802a7f64f"

#fb_oauth <- fbOAuth(app_id = "1619069818353022", app_secret="7af810547d820a99aaafa2795712e57e")
#save(fb_oauth, file="fb_oauth")
load("fb_oauth")

page <- getPage("humansofnewyork", token = token, n = 50)
page <- getPage("NUSSingapore", token = token, n = 50)

post <- getPost(page$id[1], token = token, comments = T, n = 50)

