# export_gensim_w2v_models, w2v_embeddings
import os
import sys
import gensim
import pandas as pd

# w2v_visualize_scatter_plot
from matplotlib import cm
from numpy import linspace
from adjustText import adjust_text
from matplotlib import pyplot as plt

# export_gensim_w2v_models, w2v_embeddings
os.chdir('/users/sbuongiorno/')
sys.path.append('../democracy-lab/util/pyfunctions/')

from pyfunctions.parallelize_operation import parallelize_operation
from pyfunctions.str_functions import str_split_df_sentences, lemmatize_df_text


def w2v_export_gensim_models(dir_path, n_cores):
    cores_count = os.cpu_count()
    
    if cores_count != n_cores:
        print('Warning: The number of cores requested does not match the number of cores available.')
        print('Number of cores requested: ' + n_cores)
        print('Number of cores available: ' + cores_count)
        print('Defaulting to using ' + cores_count + ' cores.')
    
    file_names = []
    cycle = 0
    
    for fname in os.listdir(dir_path):
        if '.csv' in fname:
            cycle = cycle + 1
            
            try:
                imported_data = pd.read_csv(open(dir_path + fname,'r'), encoding='utf-8', engine='python', error_bad_lines = False)
            except UnicodeDecodeError:
                imported_data = pd.read_csv(dir_path + fname, encoding = 'ISO-8859-1', engine='c', error_bad_lines = False) 
            
            print(imported_data)
            
            sentences_df = parallelize_operation(imported_data, str_split_df_sentences, n_cores)
            sentences_df = parallelize_operation(sentences_df, lemmatize_df_text, n_cores)
            
            sentences_df['sentence'] = sentences_df['sentence'].str.split()
        
            sentences_df['sentence'] = sentences_df['sentence'].str.split()
        
            period_model = gensim.models.Word2Vec(sentences = sentences_df['sentence'],
                                                 workers = n_cores, 
                                                 min_count = 20, # remove words stated less than 20 times
                                                 size = 100) # size of neural net layers; default is 100 - go higher for larger corpora 
            
            print('Successfully generated period model.')
        
            extention_position = fname.index('.')
            fname = fname[0:extention_position]
                
            if cycle == 1:
                congress_model = period_model
            else:
                congress_model.build_vocab(sentences_df['sentence'], update = True)
                congress_model.train(sentences_df['sentence'], total_examples = period_model.corpus_count, epochs = period_model.epochs)
        
            save_name = os.path.join(dir_path, fname)
        
            congress_model.save(save_name + '_model')
    
        
class w2v_embeddings:
    
    def keyword_context(dir_path, keyword_):
        regex = re.compile(keyword_ + ('($|\s|\.)'))
        
        keyword_context = []
    
        for fname in os.listdir(dir_path):
            if '_model' in fname:
                congress_model = gensim.models.Word2Vec.load(dir_path + fname)
                
                for item in congress_model.wv.key_to_index:
                    if regex.match(item):
                        keyword_context_period = congress_model.wv.most_similar(keyword_, topn = 500)
                        keyword_context.append(keyword_context_period)
                else:
                    keyword_context.append([]) 
                
        return keyword_context


    def keyword_dates(dir_path, keyword_):
        keyword_dates = []
    
        for fname in os.listdir(dir_path):
            if '_model' in fname:
                year_range = re.findall('[0-9]+', fname)
                keyword_dates.append(year_range)
    
        return keyword_dates
    
    
class w2v_visualize_scatter_plot:
    
    def define_periods(start, end, interval):
        periods = range(start, end, interval)
    
        period_names = []
        for period in periods:
            period_names.append(str(period) + '.0')
    
        return period_names


    def collect_text_values(keyword_context, period_names):
        period_words = []
    
        for i in range(0, len(period_names)):
            try:
                words = [value[0] for value in keyword_context[i]]
                period_words.append(words)
            except:
                continue
                
        return period_words
        
        
    def make_1D_list(period_words):
        flat_list = []
    
        for list in period_words:
            for word in list:
                flat_list.append(word)
                
        return flat_list
    
    
    def w2v_scatter_plot(period_names, keyword_context, flat_list, keyword): # add a kw argument for title -- like Hansard debates 
        colors = [ cm.gnuplot(x) for x in linspace(0, 1, len(flat_list)) ]
    
        plt.figure(figsize=(30, 30), dpi = 1000)

        texts = []

        # plt.annotate only plots one label per iteration, so we have to use a for loop 
        for i in range(0,len(period_names)):    # cycle through the period names                     
            for j in range(10):     # cycle through the first ten words (you can change this variable)
                if keyword_context[i]:
                    xx = period_names[i]        # on the x axis, plot the period name
                    yy = [item[1] for item in keyword_context[i]][j]         # on the y axis, plot the distance -- how closely the word is related to the keyword
                    txt = [item[0] for item in keyword_context[i]][j]        # grab the name of each collocated word
                    colorindex = flat_list.index(txt)                     # this command keeps all dots for the same word the same color
        
        
                    plt.scatter(                                           # plot dots
                        xx, #x axis
                        yy, # y axis
                        linewidth=1, 
                        color = colors[colorindex],
                        s = 300, # dot size
                        alpha=0.5)  # dot transparency

                    # make a label for each word
                    texts.append(plt.text(xx, yy, txt))

        # Code to help with overlapping labels -- may take a minute to run
        adjust_text(texts, force_points=0.0001, force_text=0.0035, 
                            expand_points=(2, 2), expand_text=(2, 2), # from 1, 1 
                            arrowprops=dict(arrowstyle="-", color='black', lw=0.5))


        plt.xticks(rotation=90)

        # Add titles
        plt.title("What words were most associated with ''" + keyword + "' in the Hansard debates?", fontsize=20, fontweight=0, color='Red')
        plt.xlabel("period")
        plt.ylabel("similarity to " + keyword)

        plt.savefig(keyword + '_' + period_names[1] + '_' + period_names[-1] +'.pdf')

        plt.show()

        
        
