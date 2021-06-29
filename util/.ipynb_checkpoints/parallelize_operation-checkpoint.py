import numpy as np
import re
import pandas as pd
from multiprocessing import Process, Queue, cpu_count, Pool

def parallelize_operation(df, function, n_cores):
    split_df = np.array_split(df, n_cores)
    pool = Pool(n_cores)
    df = pd.concat(pool.map(function, split_df))
    pool.close()
    pool.join()
    return df
