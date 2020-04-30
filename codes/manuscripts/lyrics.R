#path <- "E:\\lyrics\\korean_lyrics_textmining"
#setwd(path)
getwd()

Sys.getlocale()
#Sys.setlocale("LC_ALL","Korean")
#Sys.setlocale("LC_ALL","Chinese")
#Sys.setlocale("LC_ALL","English")
Sys.setenv(JAVA_HOME='D:\\programs\\java\\jre8')
x <- c("rvest", "data.table", "pbapply", "dplyr", "xml2", "topicmodels", "tm", "quanteda", "parallel", "doParallel", "foreach",
       "ggplot2", "reshape", "openxlsx", "stm", "lubridate", "tidyr", "stringr", "curl", "RCurl", "KoNLP")
lapply(x, require, character.only = TRUE)

dg<-debugGatherer()
mheader<-c("User-Agent"="Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36",
           "Accept"="texthtml,applicationxhtml+xml,applicationxml;q=0.9,;q=0.8",
           "Accept-Language"="en-us",
           "Connection"="keep-alive",
           "Accept-Charset"="GB2312,utf-8;q=0.7,;q=0.7")
melon_url0 <- "https://www.melon.com/search/lyric/index.htm?q=%EC%82%AC%EB%9E%91&section=&searchGnbYn=Y&kkoSpl=N&kkoDpType=&ipath=srch_form#params%5Bq%5D=%25EC%2582%25AC%25EB%259E%2591&params%5Bsort%5D=weight&params%5Bsection%5D=&po=pageObj&startIndex="
melon_url <- paste0(melon_url0,  seq(1, 9985, by = 15))
#single "for" method
songs<- c()
for (x in melon_url[1:3]) {
  songid2 <- read_html(getURL(x,httpheader=mheader,debugfunction=dg$update,verbose=TRUE)) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
  #songid <- read_html(curl(melon_url[2], handle = new_handle("useragent" = "Mozilla/5.0"))) %>% html_nodes("dd.lyric") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
  songpage <- paste0("https://www.melon.com/song/detail.htm?songId=", songid)
  songs <- append(songs, songpage)
}

#"lapply" method
songpage_extractor <- function(x){
  songid <- read_html(getURL(x,httpheader=mheader,debugfunction=dg$update,verbose=TRUE)) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
  #songid <- read_html(curl(melon_url[2], handle = new_handle("useragent" = "Mozilla/5.0"))) %>% html_nodes("dd.lyric") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
  songpage <- paste0("https://www.melon.com/song/detail.htm?songId=", songid)
  #songs <- append(songs, songpage)
  #return(c(songpage))
  Sys.sleep(0.5)
}
songs2 <- pblapply(melon_url, FUN = songpage_extractor)

#"parallel" method
songpage_extractor2 <- function(x){
  lapply(c("RCurl", "xml2", "rvest", "stringr"), library, character.only = TRUE)
  dg<-debugGatherer()
  mheader<-c("User-Agent"="Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36",
             "Accept"="texthtml,applicationxhtml+xml,applicationxml;q=0.9,;q=0.8",
             "Accept-Language"="en-us",
             "Connection"="keep-alive",
             "Accept-Charset"="GB2312,utf-8;q=0.7,;q=0.7")
  songid <- getURL(x,httpheader=mheader,debugfunction=dg$update,verbose=TRUE)
  songid <- read_html(songid)
  songid <- html_nodes(songid, css="dd.lyric a")
  songid <- html_attr(songid, "href")
  songid <- lapply(songid, str_extract, pattern = "[0-9]+")
  songid <- unique(songid)
  songpage <- paste0("https://www.melon.com/song/detail.htm?songId=", songid)
  return(c(songpage))
  Sys.sleep(3)
}
system.time({
  cl <- makeCluster(4)
  results <- parLapply(cl=cl,X=melon_url,fun=songpage_extractor2)
  songs <- unlist(results)
  stopCluster(cl)
})
#####################################################################################################

lyrics_extractor1 <- function(y){
  print(paste(y, "start", sep =": "))
  #html <- read_html(curl(y, handle = new_handle("useragent" = "Mozilla/5.0")))
  html <- read_html(getURL(y,debugfunction=dg$update,verbose = TRUE))
  lyrics <- html %>% html_nodes("#d_video_summary") %>% gsub(pattern = "<br>", replacement = ".") %>%  read_html() %>% html_text() %>% gsub(pattern = " \\.", replacement = ".") %>% gsub(pattern = "(\r|\n|\t)", replacement = "")
  name <- html %>% html_nodes(".song_name") %>% html_text() %>% gsub(pattern = "\r|\n|\t|곡명", replacement = "")
  time <- html %>% html_nodes(".list dd:nth-child(4)") %>% html_text()
  album <- html %>% html_nodes(".list dd:nth-child(2)") %>% html_text()
  genre <- html %>% html_nodes("dd:nth-child(6)") %>% html_text()
  artists <- html %>% html_nodes("div.artist a.artist_name span") %>% html_text()
  artists <- paste(artists[nchar(artists) > 0], collapse = ";")
  writers <- html %>% html_nodes("ul.list_person li div.entry")
  writers <- writers[grep("작사", writers)]  %>% html_nodes("a")  %>% html_text()
  writers <- paste(writers[nchar(writers) > 0], collapse = ";")
  likepage <- gsub(y, pattern="song/detail.htm?songId=", replacement = "commonlike/getSongLike.json?contsIds=", fixed =T)
  like <- getURL(likepage, debugfunction=dg$update,verbose = TRUE) %>% str_extract(pattern = "\"SUMMCNT\":[0-9]+") %>% gsub(pattern = "\"SUMMCNT\":", replacement = "")  %>% as.numeric()
  print(paste(y, "done", sep =": "))
  onesong <- c(name, time, album, genre, artists, writers, like, lyrics)
  return(onesong)
  Sys.sleep(0.5)
}

results <- pblapply(songs, FUN = lyrics_extractor1)

lyrics_extractor2 <- function(y){
  lapply(c("RCurl", "xml2", "rvest", "stringr", "tidyr", "magrittr"), library, character.only = TRUE)
  #print(paste(y, "start", sep = ": "))
  dg<-debugGatherer()
  mheader<-c("User-Agent"="Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36",
             "Accept"="texthtml,applicationxhtml+xml,applicationxml;q=0.9,;q=0.8",
             "Accept-Language"="en-us",
             "Connection"="keep-alive",
             "Accept-Charset"="GB2312,utf-8;q=0.7,;q=0.7")
  tryCatch({
  html <- read_html(getURL(y,httpheader=mheader,debugfunction=dg$update,verbose=TRUE))
  lyrics <- html %>% html_nodes("#d_video_summary") %>% gsub(pattern = "<br>", replacement = ".") %>%  read_html() %>% html_text() %>% gsub(pattern = " \\.", replacement = ".") %>% gsub(pattern = "(\r|\n|\t)", replacement = "")
  name <- html %>% html_nodes(".song_name") %>% html_text() %>% gsub(pattern = "\r|\n|\t|곡명", replacement = "")
  time <- html %>% html_nodes(".list dd:nth-child(4)") %>% html_text()
  album <- html %>% html_nodes(".list dd:nth-child(2)") %>% html_text()
  genre <- html %>% html_nodes("dd:nth-child(6)") %>% html_text()
  artists <- html %>% html_nodes("div.artist a.artist_name span") %>% html_text()
  artists <- paste(artists[nchar(artists) > 0], collapse = ";")
  writers <- html %>% html_nodes("ul.list_person li div.entry")
  writers <- writers[grep("작사", writers)]  %>% html_nodes("a")  %>% html_text()
  writers <- paste(writers[nchar(writers) > 0], collapse = ";")
  likepage <- gsub(y, pattern="song/detail.htm?songId=", replacement = "commonlike/getSongLike.json?contsIds=", fixed =T)
  like <- getURL(likepage,httpheader=mheader,debugfunction=dg$update,verbose=TRUE) %>% str_extract(pattern = "\"SUMMCNT\":[0-9]+") %>% gsub(pattern = "\"SUMMCNT\":", replacement = "")  %>% as.numeric()
  #print(paste(y, "done", sep =": "))
  onesong <- c(name, time, album, genre, artists, writers, like, lyrics)
  return(onesong)},
  error=function(e){cat("html",conditionMessage(e), y, "\n\n")}
  )
  
  Sys.sleep(5)
}

system.time({
  cl <- makeCluster(4)
  results <- parLapply(cl=cl,X=songs[a1],fun=lyrics_extractor2)
  stopCluster(cl)
})

lovesongs <- t(data.frame(matrix(unlist(results), nrow=8)))
#df<-lovesongs[!duplicated(lovesongs[8,]),]
colnames(lovesongs) <- c("name", "time", "album", "genre", "singers", "writers", "like", "lyrics")
row.names(lovesongs) <- c(1:length(lovesongs[,1]))
#index <- duplicated(lovesongs$lyrics)
#lovesongs2<-lovesongs[!index,]
write.csv(lovesongs, file = "lovesongs.csv", row.names = F, fileEncoding = "UTF-8")
write.xlsx(lovesongs, file = "lovesongs.xlsx")



lyrics<-scan(file.choose(), what="c", sep = "\n", fileEncoding = "UTF-8") # reading the "lyrics_tag.txt"
mainwords <- function(x) {
  x<-gsub("+", " ", x, fixed = T)  %>% strsplit(" ") %>% unlist()
  x<-x[grepl(pattern = "(NNG)|(NNP)|(NP)|(VV)|(VA)|(MM)|(MA)|(IC)", x)] %>% gsub(pattern = "[A-Z]|_|[0-9]|/", replacement = "") %>% paste(collapse = " ")
  }
lyrics_main <- pblapply(lyrics, mainwords)
df <- read.xlsx("lovesongs.xlsx")
class(df)
df$lyrics2<-unlist(lyrics_main)

Sys.setenv(JAVA_HOME='D:\\programs\\java\\jre8')
System.setProperty("webdriver.chrome.driver", "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chromedriver.exe")
library(rJava)
library(KoNLP)

library(RSelenium)
#library(devtools)     
#install_github(repo="Rwebdriver",username="crubba")
#devtools::install_github("ropensci/RSelenium")
fuctions
remDr <- remoteDriver(remoteServerAddr = "127.0.0.1" , port = 4444, browserName = "chrome")
remDr$open()
remDr$navigate(melon_url[2])
element1 <- remDr$findElement(using = "class", "lyric")
songid<-read_html(remDr$getPageSource(melon_url[2])[[1]][1]) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
songpage <- paste0("https://www.melon.com/song/detail.htm?songId=", songid)
