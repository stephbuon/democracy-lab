import glob
import pickle
import pandas as pd

# not growing a df in memory, growing it on disk 

path = "/users/rkalescky/testing/users/sbuongiorno/05_spacy_parallel"
pkls = glob.glob("{}/csv_chunk*.pickle".format(path))

header = True
with open("{}/concat_data.csv".format(path), 'a+') as o:
    for pkl in pkls:
        #print(pkl)
        with open(pkl, 'rb') as p:
            df = pickle.load(p)
        df.to_csv(o, header=header)
        header=False
        del df

