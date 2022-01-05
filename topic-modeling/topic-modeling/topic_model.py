import re
import csv
import pandas as pd
import pickle
import os, sys

from collections import Counter

import gensim
from gensim import corpora

class topic_model:
    
    def import_data(path, fname): # read data (one sentence per row) as list of lists
        with open(path + fname, newline='') as f:
            reader = csv.reader(f)
            text = list(reader)[1:]
        
        text = list(map(str, text))

        return text


    def import_stopwords(): # read stop words as list of strings
        with open(path + 'topic-modeling/stopwords.csv') as f:
            stopwords = f.read().splitlines()[1:]
            
        stopwords = re.compile('|'.join(stopwords))

        return stopwords


    def clean_data(df):
        df = [re.sub(r'\b[A-Z]+(?:\s+[A-Z]+)*\b', '', ls) for ls in df] # remove words that are all upper case - so names 
        df = [re.sub(r'\\\\n|\\\\t|\'s', '', ls) for ls in df] # remove lien breaks, tab breaks, and possessive "s"
        df = [re.sub(r'[^\w\s]|_', '', ls) for ls in df] # remove punctuation and underscore
        df = [re.sub(r'\d{1, 3}', '', ls) for ls in df] # remove digits that are a minimum of 1 and a maximum of 3
        df = [re.sub(r'\b\w{1,3}\b', '', ls) for ls in df] # test
        df = [re.sub(r'\w*\d\w*', '', ls) for ls in df] # remove character strings that contain a digit
            
        df = [word.lower() for word in df]
    
        df = [ls.split() for ls in df]
        #df = [[word for word in ls if not stopwords.match(word)] for ls in df]

        return df


    def save_model(corpus, dictionary, lda_model, target_folder):
        export_folder = path + 'lda_topic_model_' + target_folder + '/'

        if not os.path.exists(export_folder):
            os.mkdir(export_folder)

        pickle.dump(corpus, open(export_folder + target_folder + '_corpus.pkl', 'wb'))
        dictionary.save(export_folder + target_folder + '_dictionary.gensim')
        lda_model.save(export_folder + target_folder + '_model.gensim')


    def lda_topic_model(dictionary, corpus, n_topics, w, save_model, target_folder):
        
        lda_model = gensim.models.LdaMulticore(corpus, num_topics = n_topics, id2word=dictionary, workers = w, passes=15)

        if save_model == True:
            topic_model.save_model(corpus, dictionary, lda_model, target_folder)

        return lda_model

    def dictionary(data):
        return corpora.Dictionary(data)

    def corpus(data, dictionary):
        return [dictionary.doc2bow(text) for text in data]

class load_model_component:

    def dictionary(target_folder):
        import_folder = path + 'lda_topic_model_' + target_folder + '/'
        return gensim.corpora.Dictionary.load(import_folder + target_folder + '_dictionary.gensim')

    def corpus(target_folder):
        import_folder = path + 'lda_topic_model_' + target_folder + '/'
        return pickle.load(open(import_folder + target_folder + '_corpus.pkl', 'rb'))

    def lda_model(target_folder):
        import_folder = path + 'lda_topic_model_' + target_folder + '/'
        return gensim.models.ldamodel.LdaModel.load(import_folder + target_folder + '_model.gensim')

def run(n_topics, path, decade, w):
    target_folder = decade

    for fname in os.listdir(path):
        if decade in fname and '.csv' in fname:            

            data = topic_model.import_data(path, fname)
            # I hashed-out the stop words removal code (per Schofield, Magnusson, and Mimno)
            # stopwords = topic_model.import_stopwords()
            data = topic_model.clean_data(data)
            dictionary = topic_model.dictionary(data)
            corpus = topic_model.corpus(data, dictionary)
            ldamodel = topic_model.lda_topic_model(data, dictionary, corpus, n_topics = n_topics, w = w, save_model = True, target_folder = target_folder)
            
            dictionary = load_model_component.dictionary(target_folder)
            corpus = load_model_component.corpus(target_folder)
            ldamodel = load_model_component.lda_model(target_folder)
            
            topics = ldamodel.show_topics(formatted=False, num_topics = 30)
            
            data_flat = [w for w_list in data for w in w_list]
            counter = Counter(data_flat)
            
            out = []
            for i, topic in topics:
                for word, weight in topic:
                    out.append([word, i , weight, counter[word]])
                    
            df = pd.DataFrame(out, columns=['word', 'topic_id', 'importance', 'word_count'])        
            export_folder = path + 'lda_topic_model_' + target_folder + '/'
            df.to_csv(export_folder + target_folder + '_topics_' + str(n_topics) + '.csv')

if __name__ == "__main__":
    n_topics = int(sys.argv[1])
    path     = sys.argv[2]
    decade   = sys.argv[3]
    w        = int(sys.argv[4])
    run(n_topics, path, decade, w)
 
