import os
import numpy as np
import pandas as pd
from multiprocessing import Process, Queue, cpu_count, Pool

def parallelize_operation(df, function, n_cores):
    cores_count = os.cpu_count()
    
    if cores_count != n_cores:
        print('Warning: The number of cores requested does not match the number of cores available.')
        print('Number of cores requested: ' + n_cores)
        print('Number of cores available: ' + cores_count)
        print('Defaulting to using ' + cores_count + ' cores.')
    
    split_df = np.array_split(df, n_cores)
    pool = Pool(n_cores)
    df = pd.concat(pool.map(function, split_df))
    pool.close()
    pool.join()
    return df
