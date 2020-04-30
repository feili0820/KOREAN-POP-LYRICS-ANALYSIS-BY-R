#java -jar E:\Selenium\selenium-server-standalone-3.141.59.jar  #selenium java PATH 설정
#path <- "E:\lyrics\korean_lyrics_textmining"  #작업 경로 설정 
#setwd(path) #작업 경로 지정
getwd()

#############################################################
# 한글 문자 입력 및 출력 시 안 깨지기 위한 OS 기본 언어 설정 
#############################################################
Sys.getlocale()
Sys.setlocale("LC_ALL","Korean")
#Sys.setlocale("LC_ALL","Chinese")

##############################################################
#작업에 필요한 기본 R 페키지 볼러옴
##############################################################
x <- c("rvest", "data.table", "pbapply", "dplyr", "xml2", "topicmodels", "tm", "quanteda", "parallel", "doParallel", "foreach",
       "ggplot2", "reshape", "openxlsx", "stm", "lubridate", "tidyr", "stringr", "curl", "RCurl", "KoNLP", "RSelenium")
lapply(x, require, character.only = TRUE)
#Sys.setenv(JAVA_HOME='D:\\programs\\java\\jre8') #konlp 페키지 작동학기 위한 java PATH 설정

##############################################################
#'사랑' 노래 가사를 긁어오기 위한 웹주소 설정
##############################################################
melon_url0 <- "https://www.melon.com/search/lyric/index.htm?q=%EC%82%AC%EB%9E%91&section=&searchGnbYn=Y&kkoSpl=N&kkoDpType=&ipath=srch_form#params%5Bq%5D=%25EC%2582%25AC%25EB%259E%2591&params%5Bsort%5D=weight&params%5Bsection%5D=&po=pageObj&startIndex="
melon_url <- paste0(melon_url0,  seq(1, 9985, by = 150)) #전체 검색 결과 9985개에 대해 10페이지씩 나뉨. 10페이지씩 나눈 이유는 검색 화면에 최대 10페이지까지만 보여주기 때문.

################################################################################
#"사랑" 관련 노래 웹 ID 추출 방법1: 병렬 처리 방식
################################################################################
#songpage_extractor3 <- function(x){
#  i <- 0
#  lapply(c("RCurl", "xml2", "rvest", "stringr", "RSelenium",  "tidyr", "magrittr"), library, character.only = TRUE)
#  remDr <- remoteDriver(remoteServerAddr = "127.0.0.1" , port = 4444, browserName = "chrome")
#  remDr$open(silent = T)
#  remDr$navigate(x)
#  Sys.sleep(2)
#  songid1<-read_html(remDr$getPageSource()[[1]][1]) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()

#  while (i < length(remDr$findElements(using = 'css', value = ".page_num a"))){
#    btn<-remDr$findElement(using = 'css', value = "strong+ a")
#    remDr$mouseMoveToLocation(webElement=btn)
#    remDr$click()
#    Sys.sleep(2)
#    webElem2<-remDr$findElement("css","body")
#    webElem2$sendKeysToElement(list(key="end"))
#    songid2 <- read_html(remDr$getPageSource()[[1]][1]) %>% html_nodes("dd.lyric a") %>% html_attr("href") %>% lapply(str_extract, pattern = "[0-9]+") %>% unique()
#    songid1 <- c(songid1, songid2)
#    i <- i+ 1
#  }
#  song <- paste0("https://www.melon.com/song/detail.htm?songId=", songid1)
#  remDr$close()
#  return(song)
#  Sys.sleep(2)
#}
#songs2 <- pblapply(melon_url, FUN = songpage_extractor3)
#################################################################
#system.time({
#  cl <- makeCluster(4)
#  results <- parLapply(cl=cl,X=melon_url[1:10],fun=songpage_extractor3)
#  songs <- unlist(results)
#  stopCluster(cl)
#})


#########################################################################
#"사랑" 관련 노래 웹 ID 추출 방법2: 단일 순환 for 구문 방식 
#########################################################################
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
  Sys.sleep(1)
  songid<-c(songid,songid1)
  print((paste(x," :done")))
}

songid1 <- unlist(songid) # 사랑 노래 ID 목록 추출
#sameid <- songid1[table(songid1)>1]
write.xlsx(songid1, "songid1.xlsx")
songid1 <- unique(songid1)
songs <- paste0("https://www.melon.com/song/detail.htm?songId=", songid1) # 사랑 노래의 웹주소 목록 정리  

######################################################################################################
#사랑 노래 웹주소 목록에 따라 각 노래의 제목, 가사, 가수, 작사가, 발행시기, 좋아요 수 등 정보 긁어옴
######################################################################################################
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
    error = function(e){cat("html",conditionMessage(e), y, "\n\n")
    })
  Sys.sleep(5)
}

system.time({
  cl <- makeCluster(4)
  results <- parLapply(cl=cl,X=songs[a1],fun=lyrics_extractor2)
  stopCluster(cl)
})

#긁어모은 데이터를 lovesongs라는 dataframe에 저장하기 
lovesongs <- t(data.frame(matrix(unlist(results), nrow=8)))
#df<-lovesongs[!duplicated(lovesongs[8,]),]
colnames(lovesongs) <- c("name", "time", "album", "genre", "singers", "writers", "like", "lyrics")
row.names(lovesongs) <- c(1:length(lovesongs[,1]))
#index <- duplicated(lovesongs$lyrics)
#lovesongs2 <- lovesongs[!index,]
#write.csv(lovesongs, file = "lovesongs.csv", row.names = F, fileEncoding = "UTF-8")
write.xlsx(lovesongs, file = "lovesongs.xlsx")

#긁어온 가사를 utagger로 형태소 분석한 후에 일부 실질적 어휘만 추출해 'lyrics2' 만들기
lyrics<-scan(file.choose(), what="c", sep = "\n", fileEncoding = "UTF-8") # reading the "lyrics_tag.txt"
mainwords <- function(x) {
  x<-gsub("+", " ", x, fixed = T)  %>% strsplit(" ") %>% unlist()
  x<-x[grepl(pattern = "(NNG)|(NNP)|(NP)|(VV)|(VA)|(MM)|(MA)|(IC)", x)] %>% gsub(pattern = "[A-Z]|_|[0-9]|/", replacement = "") %>% paste(collapse = " ")
}
lyrics_main <- pblapply(lyrics, mainwords)
df <- read.xlsx("lovesongs3.xlsx")
class(df)
df$lyrics2<-unlist(lyrics_main)
which(df$lyrics2 < 1)
df1<- df[-which(df$lyrics2 < 1),]
write.xlsx(df1, "df1_new.xlsx")

#########################################################################
#STM 모델 만들기
#########################################################################
#df1<-read.xlsx('E:\\lyrics\\korean_lyrics_textmining\\df1.xlsx', 1)
fcorpus <- corpus(df1$lyrics2)
dfm2 <- dfm(fcorpus, verbose = FALSE, tolower = TRUE)
textstat_frequency(dfm2) 
dfm2@Dimnames$features
dfm3 <- dfm2[, -c(18, 20, 26, 41, 44)]
dfm3@Dimnames$features
dfm2.trim <- dfm_trim(dfm2, min_docfreq = 0.05,  max_docfreq = .90,  docfreq_type = "prop")
dfm2.stm <- convert(dfm2, to = "stm")
df2 <- df1[order(df1$time, decreasing = FALSE), ]
#df2[1, ]

# 발해시기에 대해 연,월,일 형식을 표준화하기 
df1$time <- df1$time %>% gsub(pattern = ".", replacement = "-", fixed = T)
date <- c()
for (i in df1$time) {
  if (nchar(i) == 1) {date <- c(date,  "1970-01-01")}
  if (nchar(i) == 4) {date <- c(date, paste(i, "-01-01", sep = ""))}
  if (nchar(i) == 7) {date <- c(date, paste(i, "-01", sep = ""))}
  if (nchar(i) == 10) {date <- c(date,i)}
}
df1$time <- date
date1 <- as.Date(date)
df2$time <- date1
df2$year <- year(date1)
df2$month <- month(date1)
df2$day <- day(date1)

dfm2.stm$meta <- df2[, c(2, 10:12)]

out <- dfm2.stm
docs <- out$documents
vocab <- out$vocab
meta <- out$meta
meta

# 메모리 조회 및 관리
memory.limit()
memory.limit(12400)
memory.size(T)
memory.size(F)
memory.size()
gc()

K = c(5, 10, 15, 20, 25, 30)
kresult2 <- searchK(docs, vocab, K, prevalence =~ s(year + month), data = meta)
plot(kresult2)

K = c(2, 4, 6, 8, 10, 15, 20, 25, 30)
kresult1 <- searchK(docs, vocab, K, prevalence =~ s(year + month), data = meta)
plot(kresult1)

agendaPrevFit25 <- stm(documents = out$documents, vocab = out$vocab, K = 25, prevalence =~ s(year + month), max.em.its = 75, data = out$meta, init.type = "Spectral")
agendaSelect25 <- selectModel(out$documents, out$vocab, K = 25, prevalence =~ s(year + month), max.em.its = 75, data = out$meta, runs = 20)
agendaPrevFit20 <- stm(documents = out$documents, vocab = out$vocab, K = 20, prevalence =~ s(year + month), max.em.its = 75, data = out$meta, init.type = "Spectral")
agendaSelect20 <- selectModel(out$documents, out$vocab, K = 20, prevalence =~ s(year + month), max.em.its = 75, data = out$meta, runs = 50)
agendaPrevFit4 <- stm(documents = out$documents, vocab = out$vocab, K = 4, prevalence =~ s(year + month), max.em.its = 75, data = out$meta, init.type = "Spectral")
agendaSelect4 <- selectModel(out$documents, out$vocab, K = 4, prevalence =~ s(year + month), max.em.its = 75, data = out$meta, runs = 20)



set.seed(1)
sample(c(1:10), 5, replace = TRUE)
warnings()

dev.off()
agendaSelect20
par(cex = 1.1); plotModels(agendaSelect20, pch = c(1,2,3,4,5,6,7,8,9,10), legend.position = "bottomright")
agendaSelect20$runout
par(cex = 1.1); plotModels(agendaSelect25, pch = c(1,2,3,4,5,6,7,8,9,10), legend.position = "bottomright")
agendaSelect20$runout

# semantic coherence: words belonging to the same topic occur together
length(agendaSelect20$semcoh[[1]])

# exclusivity: words belonging to different topics do not occur together
length(agendaSelect20$exclusivity[[1]])

#(agendaPrevFit.labels <- labelTopics(agendaPrevFit20, c(1:10)))
(agendaPrevFit.labels1 <- labelTopics(agendaPrevFit20, c(1:20)))

df.agenda.prob1 <- data.frame(t(labelTopics(agendaPrevFit20, n = 20)$prob))
df.agenda.frex1 <- data.frame(t(labelTopics(agendaPrevFit20, n = 20)$frex))
df.agenda.lift1 <- data.frame(t(labelTopics(agendaPrevFit20, n = 20)$lift))
df.agenda.score1 <- data.frame(t(labelTopics(agendaPrevFit20, n = 20)$score))

shortdoc <- str_extract_all(df1$lyrics2, regex("^.{1,200}"))
(thoughts1 <- findThoughts(agendaPrevFit20, texts = shortdoc, n = 3, topics = 20)$docs[[1]])
(thoughts2 <- findThoughts(agendaPrevFit20, texts = shortdoc, n = 3, topics = 10)$docs[[1]])
(thoughts3 <- findThoughts(agendaPrevFit20, texts = shortdoc, n = 3, topics = 15)$docs[[1]])

par(mfrow = c(1, 3), mar = c(.5, .5, 1, .5), cex = 0.9)
plotQuote(thoughts1, width = 50, main = "Topic 20")
plotQuote(thoughts2, width = 50, main = "Topic 10")
plotQuote(thoughts3, width = 50, main = "Topic 15")

prep1 <- estimateEffect(1:20 ~ s(year + month), agendaPrevFit20,
                       meta = out$meta, uncertainty = "Global")
summary(prep1, topics = c(1:5))

dev.off()

par(cex = 1)
plot(agendaPrevFit20, type = "summary", xlim = c(0, .15))

prep1$varlist
par(mfrow = c(2, 2), cex = 1)
for(i in c(17,18,19,20)){
  plot(prep1, "year", method = "continuous", topics = i,
       main = paste0(agendaPrevFit.labels1$prob[i, 1:6], collapse = ", "), 
       printlegend = FALSE)
}


dev.off()
?stm::cloud
# wordcloud for each topic

stm::cloud(agendaPrevFit20, topic = 1,
           type = "documents", 
           documents = docs, thresh = 0.7,
           max.words = 50, scale = c(0.2, 1.1))

stm::cloud(agendaPrevFit20, topic = 1,
           type = "model", 
           max.words = 50, scale = c(0.5, 1.5))
##################################################################################
fcorpus <- corpus(df1$lyrics2)
dfmatrix <- dfm(fcorpus, verbose = FALSE, remove_separators = TRUE)
dfmatrix2 <- dfm_tfidf(dfmatrix)
dfmatrix3 <- dfm_select(dfmatrix2, min_nchar = 2L)
dtm <- as.matrix(dfmatrix3)
row_total <- rowSums(dtm)
#table(row_total)

dtm2 <- dtm[row_total > 0, ]
#colnames(dtm2)
#table(rowSums(dtm2))

cluster <- makeCluster(detectCores(logical = TRUE) - 1)
cluster
registerDoParallel(cluster)
clusterEvalQ(cluster, {
  library(topicmodels)
})

folds <- 5
n <- nrow(dtm2)
full_data <- dtm2
burnin = 1000
iter = 1000
keep = 50

splitfolds <- sample(1:folds, n, replace = TRUE)
candidate_k <- c(2, 3, 4, 5, 10, 20, 30, 40, 50, 75, 
                 100, 200, 300)
clusterExport(cluster, c("full_data", "burnin", "iter",
                         "keep", "splitfolds", "folds",
                         "candidate_k"))

system.time({results <- foreach(j = 1: length(candidate_k), 
                                .combine = rbind)%dopar%{
                                  k <- candidate_k[j]
                                  results_1k <- matrix(0, nrow = folds, ncol= 2)
                                  colnames(results_1k) <- c("k", "perplexity")
                                  for(i in 1:folds){
                                    train_set <- full_data[splitfolds != i,]
                                    test_set <- full_data[splitfolds == i,]
                                    
                                    fitted <- LDA(train_set, k = k, method = "Gibbs",
                                                  control = list(burnin = burnin,
                                                                 iter = iter,
                                                                 keep = keep))
                                    results_1k[i,] <- c(k, perplexity(fitted, newdata = test_set))
                                  }
                                  return(results_1k)
                                }
})







