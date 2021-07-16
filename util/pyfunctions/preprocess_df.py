import csv
import pandas as pd

def standardize_spelling_df(data, text_col, fpath_replace_list):
    with open(fpath_replace_list, 'r') as f:
        csv_reader = csv.reader(f)
        replace_list = list(csv_reader)
        
    data[text_col] = data[text_col].str.lower()
    
    for replace in replace_list:
        data[text_col] = data[text_col].str.replace('\\b' + '(?i)' + replace[0] + '\\b', replace[1])
    
    return data
