import os 
import pandas as pd 

def set_dir(data, fname): 
    target_folder = fname + '_subsets'
    os.makedirs(target_folder, exist_ok=True)
    return target_folder

def interval_subset(data, col_name, start, end, intv, fname):
    target_folder = set_dir(data, fname)
    
    start = start
    end = end
    
    data = data.sort_values(by=col_name, ascending=True)

    while start <= end:
        start = start + intv
        subset = data[(data[col_name] >= start - intv) & (data[col_name] <= start - 1)]
        
        if not subset.empty: # just added this line 
            descr = str(subset[col_name].iloc[0])
            descr_2 = str(subset[col_name]. iloc[-1])
            
            file_name = fname + descr + "_" + descr_2
            save_name = os.path.join(target_folder, file_name)
            subset.to_csv(save_name + ".csv", index = False)
            
            
# example
# hansard = pd.read_csv('/scratch/group/pract-txt-mine/sbuongiorno/clean_tokenized_hansard.csv')
# interval_subset(hansard, 'ngram_order', 1800, 1920, 10, '/scratch/group/pract-txt-mine/sbuongiorno/hansard_decades_text2vec')
