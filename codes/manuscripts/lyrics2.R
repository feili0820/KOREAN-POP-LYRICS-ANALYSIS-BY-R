#java -jar E:\Selenium\selenium-server-standalone-3.141.59.jar

library(RSelenium)
#library(devtools)     
#install_github(repo="Rwebdriver",username="crubba")
#devtools::install_github("ropensci/RSelenium")
#"parallel" method
melon_url0 <- "https://www.melon.com/search/lyric/index.htm?q=%EC%82%AC%EB%9E%91&section=&searchGnbYn=Y&kkoSpl=N&kkoDpType=&ipath=srch_form#params%5Bq%5D=%25EC%2582%25AC%25EB%259E%2591&params%5Bsort%5D=weight&params%5Bsection%5D=&po=pageObj&startIndex="
melon_url <- paste0(melon_url0,  seq(1, 9985, by = 150))

#songpage_extractor3 <- function(x){
#  i <- 0
#  lapply(c("RCurl", "xml2", "rvest", "stringr", "RSelenium",  "tidyr", "magrittr"), library, character.only = TRUE)
#  remDr <- remoteDriver(remoteServerAddr = "127.0.0.1" , port = 4444, browserName = "chrome")
#  remDr$open(silent = T)
#  remDr$navigate(x)
#  Sys.sleep(1)
#  songid1<-read_html(remDr$getPageSource()[[1]][1]) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
  
#  while (i < length(remDr$findElements(using = 'css', value = ".page_num a"))){
#    btn<-remDr$findElement(using = 'css', value = "strong+ a")
#    remDr$mouseMoveToLocation(webElement=btn)
#    remDr$click()
#    Sys.sleep(1)
#    webElem2<-remDr$findElement("css","body")
#    webElem2$sendKeysToElement(list(key="end"))
#    songid2 <- read_html(remDr$getPageSource()[[1]][1]) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
#    songid1 <- c(songid1, songid2)
#    i <- i+ 1
#  }
#  song <- paste0("https://www.melon.com/song/detail.htm?songId=", songid1)
#  remDr$close()
#  return(song)
#  Sys.sleep(1)
#}
#songs2 <- pblapply(melon_url, FUN = songpage_extractor3)
#######################
#system.time({
#  cl <- makeCluster(4)
#  results <- parLapply(cl=cl,X=melon_url[1:10],fun=songpage_extractor3)
#  songs <- unlist(results)
#  stopCluster(cl)
#})

songid<-c()
remDr <- remoteDriver(remoteServerAddr = "127.0.0.1" , port = 4444, browserName = "chrome")
remDr$open(silent = T)
for (x in melon_url){
  i <- 0
  #lapply(c("RCurl", "xml2", "rvest", "stringr", "RSelenium",  "tidyr", "magrittr"), library, character.only = TRUE)
  
  remDr$navigate(x)
  Sys.sleep(1)
  songid1<-read_html(remDr$getPageSource()[[1]][1]) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
  
  while (i < length(remDr$findElements(using = 'css', value = ".page_num a"))){
    btn<-remDr$findElement(using = 'css', value = "strong+ a")
    remDr$mouseMoveToLocation(webElement=btn)
    remDr$click()
    Sys.sleep(1)
    webElem2<-remDr$findElement("css","body")
    webElem2$sendKeysToElement(list(key="end"))
    songid2 <- read_html(remDr$getPageSource()[[1]][1]) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
    songid1 <- c(songid1, songid2)
    i <- i+ 1
  }
  Sys.sleep(0.5)
  songid<-c(songid,songid1)
  print((paste(x," :done")))
}

songid1 <- unlist(songid)
#sameid <- songid1[table(songid1)>1]
write.xlsx(songid1, "songid1.xlsx")
songid1 <- unique(songid1)
songs <- paste0("https://www.melon.com/song/detail.htm?songId=", songid1)


  songid<-read_html(remDr$getPageSource(x)[[1]][1]) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
  songpage <- paste0("https://www.melon.com/song/detail.htm?songId=", songid)



  
  lovesongs <- t(data.frame(matrix(unlist(list), nrow=8)))
  #df<-lovesongs[!duplicated(lovesongs[8,]),]
  colnames(lovesongs) <- c("name", "time", "album", "genre", "singers", "writers", "like", "lyrics")
  row.names(lovesongs) <- c(1:3215)
  index <- duplicated(lovesongs$lyrics)
  lovesongs2<-lovesongs[!index,]
  write.csv(lovesongs, file = "lovesongs.csv", row.names = F, fileEncoding = "UTF-8")
  write.xlsx(lovesongs, file = "lovesongs.xlsx")
  
  list<-unique(c(results,results11, results12))
  list1<-c(unique(results),unique((results11)), unique(results12))
  list2<-list1[which(duplicated(list1))]
  length(unique(results11))
  a<-c()
  for (i in seq(1:length(results))) {if(length(unlist(results[i]))<2){a<-c(a,i)}}
  a1<-c()
  for (i in seq(1:length(results11))) {if(length(unlist(results11[i]))<2){a1<-c(a1,i)}}
  
mainwords <- fuction(x) {
    x<-gsub("+", " ", x, fixed = T)  %>% strsplit(" ") %>% unlist()
    x<-x[grepl(pattern = "(NNG)|(NNP)|(NP)|(VV)|(VA)|(MM)|(MA)|(IC)", x)] %>% gsub(pattern = "[A-Z]|_|[0-9]|/", replacement = "") %>% paste(collapse = " ")
}
  
  
