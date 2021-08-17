import glob
import os 
import pandas as pd 

os.chdir('/users/sbuongiorno/democracy-lab/util/')
from pyfunctions.interval_subsetter import interval_subset
from pyfunctions.str_functions import str_split_df_sentences
from pyfunctions.parallelize_operation import parallelize_operation

all_data = pd.read_csv('/users/sbuongiorno/stanford_congressional_records_w_year.csv')

interval_subset(all_data, 'year', 1870, 2010, 10, '/users/sbuongiorno/stanford_congressional_records')

dir_path = '/users/sbuongiorno/stanford_congressional_records_subsets/'

cycle = 0

for fname in os.listdir(dir_path):
    if '.csv' in fname:    
        cycle = cycle + 1
        try:
            imported_data = pd.read_csv(open(dir_path + fname,'r'), encoding='utf-8', engine='python', error_bad_lines = False)
        except UnicodeDecodeError:
            imported_data = pd.read_csv(dir_path + fname, encoding = 'ISO-8859-1', engine='c', error_bad_lines = False) 
            
        out = fname[['triple', 'year']] # new
            
        out = parallelize_operation(out, str_split_df_sentences, 36)
        
        out = parallelize_operation(out, lower, 36) # new
        
        out.to_csv('/users/sbuongiorno/stanford_congressional_records_subsets/' + '_' + cycle)

all_data = pd.DataFrame()

for fname in os.listdir(dir_path):
    if 'cycle' in fname:
        
        inputf = pd.read_csv(dir_path + fname)
        
        all_data = pd.concat([all_data, inputf], axis=0)
        
all_data.to_csv('/scratch/group/pract-txt-mine/clean_stanford_congressional_records_w_year.csv', index = False)
