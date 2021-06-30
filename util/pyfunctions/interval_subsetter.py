import os 
import pandas as pd 

def set_dir(data, fname): 
    path = os.getcwd()
    current_folder = os.path.basename(path)
    target_folder = fname + '_subsets'
    os.makedirs(target_folder, exist_ok=True)
    return target_folder

def interval_subset(data, col_name, start, end, intv, fname):
    target_folder = set_dir(data, fname)
    
    start = start
    end = end

    while start <= end:
        start = start + intv
        subset = data[(data[col_name] >= start - intv) & (data[col_name] <= start - 1)]
        
        if not subset.empty: # just added this line 
            descr = str(subset[col_name].iloc[0])
            descr_2 = str(subset[col_name]. iloc[-1])
            
            file_name = fname + descr + "_" + descr_2
            save_name = os.path.join(target_folder, file_name)
            subset.to_csv(save_name + ".csv", index = False)
