import os
import pickle
import pandas as pd


def jar_dataframes(pickle_path):
    pickle_jar = pd.DataFrame()
    
    for fname in os.listdir(pickle_path):
        if '.pickle' in fname:
            handler = open(pickle_path + fname, 'rb')
            py_object = pickle.load(handler)
        
            pickle_jar = pd.concat([pickle_jar, py_object], axis=0)
    
    return pickle_jar
  
  
  if __name__ == '__main__':
    try:
        pickle_path = sys.argv[1]
    except IndexError:
        exit('No file named ' + sys.argv[1])
        
    export_folder = sys.argv[2]
    
    export_fname = sys.argv[3]

    if not os.path.exists(export_folder):
        os.mkdir(export_folder)
        
    dataframes = jar_dataframes(pickle_path)
    
    dataframes.to_csv(export_fname, index=False)
