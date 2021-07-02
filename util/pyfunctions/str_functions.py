import pandas as pd
import re
from textblob import Word

def str_split_df_sentences(df):
    split_rule = r"(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?)\s"
    
    df['speech'] = df['speech'].apply(lambda x: re.split(split_rule, x))
    
    df = df.explode('speech')
    df.reset_index()
    df.rename(columns = {'speech': 'sentence'}, inplace = True)
    
    #if remove_punctuation == True:
    df['sentence'] = df['sentence'].str.replace('[^\w\s]','')
    
    return df


def lemmatize_df_text(df):
    df['sentence'] = df['sentence'].str.split()
    df['sentence'] = df['sentence'].apply(lambda x: [Word(word) for word in x])
    df['sentence'] = df['sentence'].apply(lambda x: [word.lemmatize() for word in x])
    df['sentence'] = df['sentence'].apply(lambda x: ' '.join(word for word in x))
    
    return(df)

