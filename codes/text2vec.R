#install(c("text2vec", "LDAvis", "servr"))
lapply(c("text2vec", "LDAvis", "servr"), require, character.only = TRUE)
library(stringr)
data("movie_review")
movie_review_train = movie_review[1:700, ]
movie_review_test = movie_review[701:1000, ]
prep_fun = function(x) {
  x %>% 
    # make text lower case
    str_to_lower %>% 
    # remove non-alphanumeric symbols
    str_replace_all("[^[:alpha:]]", " ") %>% 
    # collapse multiple spaces
    str_replace_all("\\s+", " ")
}
movie_review_train$review = prep_fun(movie_review_train$review)
it = itoken(movie_review_train$review, progressbar = FALSE)
v = create_vocabulary(it) %>% 
  prune_vocabulary(doc_proportion_max = 0.1, term_count_min = 5)
vectorizer = vocab_vectorizer(v)
dtm = create_dtm(it, vectorizer)

tfidf = TfIdf$new()
lsa = LSA$new(n_topics = 10)

# pipe friendly transformation
doc_embeddings = dtm %>% 
  fit_transform(tfidf) %>% 
  fit_transform(lsa)
dim(doc_embeddings)
dim(lsa$components)
new_data = movie_review_test
new_doc_embeddings = 
  new_data$review %>% 
  itoken(preprocessor = prep_fun, progressbar = FALSE) %>% 
  create_dtm(vectorizer) %>% 
  # apply exaxtly same scaling wcich was used in train data
  transform(tfidf) %>% 
  # embed into same space as was in train data
  transform(lsa)
dim(new_doc_embeddings)
#####################################
data("movie_review")  
setDT(movie_review)  
setkey(movie_review, id)  
set.seed(2016L)  
all_ids = movie_review$id  
train_ids = sample(all_ids, 4000)  
test_ids = setdiff(all_ids, train_ids)  
train = movie_review[J(train_ids)]  
test = movie_review[J(test_ids)]
######################################################################################

it_train = itoken(df1$lyrics2)
vocab = create_vocabulary(it_train)
head(vocab)
pruned_vocab = prune_vocabulary(vocab, term_count_min = 10, doc_proportion_max = 0.5, doc_proportion_min = 0.001) 
head(pruned_vocab)
vectorizer = vocab_vectorizer(pruned_vocab)
head(vectorizer)
dtm_train = create_dtm(it_train, vectorizer)
head(dtm_train)


lda_model20 = LDA$new(n_topics = 20)
doc_topic_distr = lda_model20$fit_transform(dtm_train, n_iter = 200)
lda_model20$plot()
#lda_model40 = LDA$new(n_topics = 40)
#doc_topic_distr = lda_model40$fit_transform(dtm_train, n_iter = 20)
#lda_model40$plot()
#lda_model10 = LDA$new(n_topics = 10)
#doc_topic_distr = lda_model10$fit_transform(dtm_train, n_iter = 20)
#lda_model10$plot()
#lda_model5 = LDA$new(n_topics = 5)
#doc_topic_distr = lda_model5$fit_transform(dtm_train, n_iter = 20)
#lda_model5$plot()

perplexity(dtm_train, topic_word_distribution = lda_model$topic_word_distribution, doc_topic_distribution = new_doc_topic_distr)



