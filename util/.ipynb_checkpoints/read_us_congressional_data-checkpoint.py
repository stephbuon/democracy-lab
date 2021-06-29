import glob
import os
import csv
import pandas as pd
import numpy as np 

def read_speeches():
    all_speech_files = glob.glob('/scratch/group/oit_research_data/stanford_congress/hein-bound/speeches_*.txt')
    CONGRESS_MIN_THRESHOLD = 1
    CONGRESS_MAX_THRESHOLD = 115
    
    speech_files = []
    
    for fn in all_speech_files:
        number = int(fn.rsplit('_', 1)[-1].split('.')[0])
        
        if CONGRESS_MIN_THRESHOLD <= number <= CONGRESS_MAX_THRESHOLD:
            speech_files.append(fn)
            speech_files.sort()
    return speech_files

def read_descriptions():
    all_description_files = glob.glob('/scratch/group/oit_research_data/stanford_congress/hein-bound/descr_*.txt')
    CONGRESS_MIN_THRESHOLD = 1
    CONGRESS_MAX_THRESHOLD = 115
    
    description_files = []
    
    for fn in all_description_files:
        number = int(fn.rsplit('_', 1)[-1].split('.')[0])
        
        if CONGRESS_MIN_THRESHOLD <= number <= CONGRESS_MAX_THRESHOLD:
            description_files.append(fn)
            description_files.sort()
    return description_files
        
def reader(fn):
    print(f'Reading {fn}...')
    return pd.read_csv(fn, sep='|', encoding="ISO-8859-1", error_bad_lines=False, warn_bad_lines=False, quoting=csv.QUOTE_NONE)

def clean_data(all_data):
    all_data = all_data.drop(['chamber', 'speech_id', 'number_within_file', 'speaker', 'first_name'], 1)
    all_data = all_data.drop(['last_name', 'state', 'gender', 'line_start', 'line_end', 'file', 'char_count', 'word_count'], 1)
    all_data['date']=pd.to_datetime(all_data['date'],format='%Y%m%d')
    all_data['year'] = pd.to_datetime(all_data['date']).dt.year
    all_data['5yrperiod'] = np.floor(all_data['year'] / 5) * 5 # round each year to the nearest 5 -- by dividing by 5 and "flooring" to the lowest integer
    all_data = all_data.drop(['date', '5yrperiod'], 1)
    all_data['index'] = np.arange(len(all_data)) # create an 'index' column
    return all_data
    
def import_congressional_data(*args, **kwargs):
    cd = kwargs.get('clean_data', None)
    speech_files = read_speeches()
    description_files = read_descriptions()
    
    speeches_df = pd.concat((reader(fn) for fn in speech_files))
    speeches_df.dropna(how='any', inplace=True)
    
    description_df = pd.concat((reader(fn) for fn in description_files))
    
    all_data = pd.merge(speeches_df, description_df, on = 'speech_id')
    all_data.fillna(0, inplace=True)
    
    if cd == True:
        all_data = clean_data(all_data)
    
    return all_data

#congressional_data = import_congressional_data(clean_data = True)
