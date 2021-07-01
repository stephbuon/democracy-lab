import os
import sys
import gensim
import pandas as pd

os.chdir('/users/sbuongiorno/')
sys.path.append('../democracy-lab/util/pyfunctions/')

from pyfunctions.parallelize_operation import parallelize_operation
from pyfunctions.str_functions import str_split_df_sentences


def export_gensim_models(dir_path, n_cores):
    file_names = []
    cycle = 0
    
    for fname in os.listdir(dir_path):
        file_names.append(fname)
        
    for fname in file_names:
        cycle = cycle + 1
        
        imported_data = pd.read_csv(dir_path + fname, encoding = 'ISO-8859-1') # just added the encoding argument 
        
        sentences_df = parallelize_operation(imported_data, str_split_df_sentences, n_cores)
        
        sentences_df['sentence'] = sentences_df['sentence'].str.split()
        
        period_model = gensim.models.Word2Vec(sentences = sentences_df['sentence'],
                                             workers = n_cores, 
                                             min_count = 20, # remove words stated less than 20 times
                                             size = 100) # size of neuralnet layers; default is 100 - go higher for larger corpora 
        
        extention_position = fname.index('.')
        fname = fname[0:extention_position]
                
        if cycle == 1:
            congress_model = period_model
        else:
            congress_model.build_vocab(sentences_df['sentence'], update = True)
            congress_model.train(sentences_df['sentence'], total_examples = period_model.corpus_count, epochs = period_model.epochs)
        
        save_name = os.path.join(dir_path, fname)
        
        congress_model.save(save_name + '_model')
    
        
class kw_context:
    
    def record_keyword_context(dir_path, keyword_): # if this works, I will update gensim_functions on gh 
        keyword_context = []
    
        for fname in os.listdir(dir_path):
            if '_model' in fname:
                congress_model = gensim.models.Word2Vec.load(dir_path + fname)
                if type(keyword_) == str:
                    if keyword_ in congress_model.wv.vocab:
                        keyword_context_period = congress_model.wv.most_similar(keyword_, topn = 1000)
                        keyword_context.append(keyword_context_period)
                    else:
                        keyword_context.append([]) 
                    
                if type(keyword_) == list:
                    for word in keyword_:
                        if word in congress_model.wv.vocab:
                            keyword_context_period = congress_model.wv.most_similar(word, topn = 1000)
                            keyword_context.append(keyword_context_period)
                        else:
                            keyword_context.append([])
                
        return keyword_context


    def record_keyword_dates(dir_path, keyword_):
        keyword_dates = []
    
        for fname in os.listdir(dir_path):
            if '_model' in fname:
                year_range = re.findall('[0-9]+', fname)
                keyword_dates.append(year_range)
    
        return keyword_dates
    
    
