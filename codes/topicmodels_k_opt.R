
set.seed(12345) 
sampling <- sample(1:5082, replace = FALSE,size = nrow(df1)*0.8)

train_data <- df1[sampling,]$lyrics2

test_data <- df1[-sampling,]$lyrics2
##Creating the document-term matrix for train data
doc.vec_train <- VectorSource(train_data)
doc.corpus_train <- Corpus(doc.vec_train)
#doc.corpus_train <- tm_map(doc.corpus_train , tolower)
#doc.corpus_train <- tm_map(doc.corpus_train, removePunctuation)
#doc.corpus_train <- tm_map(doc.corpus_train, removeNumbers)
#doc.corpus_train <- tm_map(doc.corpus_train, removeWords, stopwords("english"))
#doc.corpus_train <- tm_map(doc.corpus_train, stripWhitespace)

TDM_train <- TermDocumentMatrix(doc.corpus_train)
DTM_train <- DocumentTermMatrix(doc.corpus_train)

##Creating the document term matrix for test data
doc.vec_test <- VectorSource(test_data)
doc.corpus_test  <- Corpus(doc.vec_test)
#doc.corpus_test  <- tm_map(doc.corpus_test, tolower)
#doc.corpus_test  <- tm_map(doc.corpus_test, removePunctuation)
#doc.corpus_test  <- tm_map(doc.corpus_test, removeNumbers)
#doc.corpus_test  <- tm_map(doc.corpus_test, removeWords, stopwords("english"))
#doc.corpus_test  <- tm_map(doc.corpus_test, stripWhitespace)

TDM_test <- TermDocumentMatrix(doc.corpus_test)
DTM_test <- DocumentTermMatrix(doc.corpus_test)

##plot the metrics to get number of topics
library(ldatuning)
system.time({
  tunes <- FindTopicsNumber(
    dtm = DTM_train,
    topics = seq(2, 32, by = 5),
    metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010"),
    method = "Gibbs",
    control = list(seed = 12345),
    mc.cores = 4L,
    verbose = TRUE
  )
})
FindTopicsNumber_plot(tunes)

#######################################################################################
perplexity_df <- data.frame(train=numeric(), test=numeric())
topics <- seq(2, 32, by = 5)
burnin = 100
iter = 1000
keep = 50

set.seed(12345)
for (i in topics){
  
  fitted <- LDA(DTM_train, k = i, method = "Gibbs",
                control = list(burnin = burnin, iter = iter, keep = keep) )
  perplexity_df[i,1] <- topicmodels::perplexity(fitted, newdata = DTM_train)
  perplexity_df[i,2] <- topicmodels::perplexity(fitted, newdata = DTM_test) 
}
perplexity_df0<-data.frame(train = perplexity_df$train[!is.na(perplexity_df$train)], test=perplexity_df$test[!is.na(perplexity_df$test)])
row.names(perplexity_df0)<-c(topics)
g1 <- ggplot(data=perplexity_df0, aes(x= as.numeric(row.names(perplexity_df0)))) + labs(y="Perplexity",x="Number of topics") + ggtitle("Perplexity of hold out  and training data")
g1 <- g1 + geom_line(aes(y=test), colour="red")
g1 <- g1 + geom_line(aes(y=train), colour="green")
g1


topics1 <- seq(2, 10, by = 1)
perplexity_df1 <- data.frame(train=numeric(), test=numeric())
set.seed(12345)
for (i in topics1){

  fitted1 <- LDA(DTM_train, k = i, method = "Gibbs",
                 control = list(burnin = burnin, iter = iter, keep = keep) )
  perplexity_df1[i,1] <- topicmodels::perplexity(fitted1, newdata = DTM_train)
  perplexity_df1[i,2] <- topicmodels::perplexity(fitted1, newdata = DTM_test) 
}


perplexity_df11<-data.frame(train = perplexity_df1$train[!is.na(perplexity_df1$train)], test=perplexity_df1$test[!is.na(perplexity_df1$test)])
row.names(perplexity_df11)<-topics1
g <- ggplot(data=perplexity_df11, aes(x= as.numeric(row.names(perplexity_df11)))) + labs(y="Perplexity",x="Number of topics") + ggtitle("Perplexity of hold out  and training data")
g <- g + geom_line(aes(y = test), colour="red")
g <- g + geom_line(aes(y = train), colour="green")
g

######################################################
