import os 
import re
import csv
import sys
import numpy as np
import pandas as pd 

from gensim.models import ldaseqmodel
from gensim.corpora import Dictionary

from operator import itemgetter

#os.chdir('/users/sbuongiorno/democracy-lab/util/')

#from pyfunctions.str_functions import lemmatize_df_text
#from pyfunctions.parallelize_operation import parallelize_operation

#os.chdir('/users/sbuongiorno/hansard-debate-titles/dynamic-topic-modeling/')

import warnings; warnings.simplefilter('ignore')

hansard = pd.read_csv('/users/sbuongiorno/hansard_justnine_w_year.csv')  

hansard = hansard.rename(columns = {'text': 'sentence'})

stopwords = pd.read_csv('/users/sbuongiorno/stopwords.csv')

list_of_stopwords = stopwords['stop_word'].tolist()

def clean_strings(data, group):   
    patterns = ['\[', '\]', '\(', '\)', '—$', '^—', '\"', '^ ', '^\'', '—', '\.', '\,', '\?']

    for pattern in patterns:
        regex = re.compile(pattern)
        data[group] = data[group].str.replace(regex, '')
        
    shortword = re.compile(r'\W*\b\w{1,3}\b')
    data[group] = data[group].str.replace(shortword, '')
    
    return data

def dtm_dates(data, date_col, group, start, end, intv):
    start = start
    end = end
    
    date_exists = []
    
    while start < end:
        data = data[[date_col, group]]
        subset = data[(data[date_col] >= start) & (data[date_col] <= start + 9)]
        
        if not subset.empty:
            date_exists.append(1)
            
        else:
            date_exists.append(0)
            
        start = start + intv
    
    return date_exists

def dtm_model(data, date_col, topic_model, start, end, intv, num_topics, **kwargs):
    stopwords_list = kwargs.get('stopwords_list', None)
    
    start = start
    end = end
    
    corpus = []
    time_slice = []
    dict_subset = Dictionary()
    
    while start < end:
        
        data = data[[date_col, topic_model]]
        subset = data[(data[date_col] >= start) & (data[date_col] <= start + 9)]
        
        if not subset.empty:
            subset[topic_model] = subset[topic_model].astype(str).str.lower()
            
            subset = clean_strings(subset, topic_model)
            subset = subset.drop(columns=[date_col])
            
            subset = subset.drop_duplicates()
            
            subset[topic_model] = subset[topic_model].apply(lambda x: ' '.join([word for word in x.split() if word not in (stopwords_list)]))
                
            #subset = parallelize_operation(subset, lemmatize_df_text, n_cores)
                
            subset = subset[topic_model].str.split()       
            
            current_time_slice = int(subset.shape[0])
            time_slice.append(current_time_slice) 
                        
            subset = subset.values.tolist()
                        
            current_dict_subset = Dictionary(subset)
            dict_subset.merge_with(current_dict_subset)

            current_corpus = [dict_subset.doc2bow(s) for s in subset]
            corpus.extend(current_corpus)

        start = start + intv
    
    ldaseq = ldaseqmodel.LdaSeqModel(corpus=corpus,
                                     id2word=dict_subset,
                                     time_slice=time_slice,
                                     num_topics=num_topics)

    return ldaseq


ldaseq = dtm_model(data=hansard,
                   date_col='year', 
                   topic_model='sentence', 
                   start=1800, 
                   end=1920,
                   intv=10, 
                   num_topics=2,
                   stopwords_list=list_of_stopwords)

ldaseq.save('/users/sbuongiorno/hansard-debate-titles/dynamic-topic-modeling/ldaseq_test_model')