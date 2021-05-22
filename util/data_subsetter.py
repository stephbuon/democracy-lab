import os 
import pandas as pd 
from varname import nameof

def set_dir(data): 
    path = os.getcwd()
    current_folder = os.path.basename(path)
    target_folder = nameof(data) + '_subsets'

    if current_folder != target_folder:
        os.makedirs(target_folder)
        os.chdir(target_folder)
        
def interval_subset(data, col_name, start, end, intv):
    set_dir(data)
    
    start = start
    end = end

    while start <= end:
        start = start + intv
        subset = data[(data[col_name] >= start - intv) & (data[col_name] <= start - 1)]
        
        descr = str(subset[col_name].iloc[0])
        descr_2 = str(subset[col_name]. iloc[-1])
        
        file_name = "stanford_congressional_records_" + descr + "_" + descr_2
        
        subset.to_csv(file_name + ".csv", index = False)
