import pandas as pd
from gensim import corpora, models, similarities

# TODO: add code to remove stopwords
# also: add astype(str).str.lower()
# subset = clean_strings(subset, topic_model) # add thsi, too -- clean_strings is defined in the dtm version 

def model_topics(dataframe, col_name):
    data = pd.read_csv(dataframe)
    data = data[col_name].str.split()
    data = data.values.tolist() 
    
    dic = corpora.Dictionary(data)
    corpus = [dic.doc2bow(i) for i in data]
    
    tfidf = models.TfidfModel(corpus)
    transformed_tfidf = tfidf[corpus]
    
    lda = models.LdaMulticore(transformed_tfidf, num_topics = 10, id2word=dict_subset)

    return lda
  
  lda = model_topics('/users/sbuongiorno/hansard_samples/full_hansard_sample.csv', 'text')
  
  lda.show_topics()
