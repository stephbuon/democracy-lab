import pandas as pd
import re

def str_split_sentences(df):
    split_rule = r"(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?)\s"
    
    df['speech'] = df['speech'].apply(lambda x: re.split(split_rule, x))
    
    df = df.explode('speech')
    df.reset_index()
    df.rename(columns = {'speech': 'sentence'}, inplace = True)
    
    return df