import csv
import pandas as pd

class preprocess_df:
    
    def find_replace(data, extraction_col, fpath_replace_list):
        with open(fpath_replace_list, 'r') as f:
            csv_reader = csv.reader(f)
            replace_list = list(csv_reader)
        
        data[extraction_col] = data[extraction_col].str.lower()
    
        for replace in replace_list:
            data[extraction_col] = data[extraction_col].str.replace('\\b' + '(?i)' + replace[0] + '\\b', replace[1])
    
    return data
   
