import pandas as pd
import trafilatura
import os

# f = '/scratch/group/pract-txt-mine/data_sets/hansard/hansard_20191119.tsv' # for all of Hansard. No year column

directory = '/scratch/group/pract-txt-mine'
basename = 'hansard_c19_04152021'

os.chdir(directory)
f = f'{basename}.tsv' # for c19 Hansard. With year column 
print('Reading TSV...')
hansard = pd.read_csv(f, sep='\t')
print('Converting to HTML...')
hansard = hansard.to_html(f'{basename}.html', index=False)
print('Converting to TEI-XML...')
hansard_tei = trafilatura.extract(hansard, tei_output=True, tei_validation=True)
print('Exporting TEI-XML to file...')
with open(f'{basename}.tei', 'w+') as f:
    f.write(hansard_tei)
