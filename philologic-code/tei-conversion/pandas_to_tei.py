#!pip install --user trafilatura

import pandas as pd
import trafilatura

# f = '/scratch/group/pract-txt-mine/data_sets/hansard/hansard_20191119.tsv' # for all of Hansard. No year column

f = '~/hansard_c19_04152021.tsv' # for c19 Hansard. With year column 

hansard = pd.read_csv(f, sep='\t')

hansard.to_html('hansard_c19_12192019.html', index=False)
