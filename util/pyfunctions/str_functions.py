import pandas as pd
import re
from nltk.stem import WordNetLemmatizer

def lemmatizer(text):
    lemmatizer = WordNetLemmatizer()
    
    return [lemmatizer.lemmatize(w) for w in text]


def lemmatize_df_text(df):
    df['speech'] = df['speech'].apply(lemmatize)
    
    return df


def str_split_df_sentences(df):
    split_rule = r"(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?)\s"
    
    df['speech'] = df['speech'].apply(lambda x: re.split(split_rule, x))
    
    df = df.explode('speech')
    df.reset_index()
    df.rename(columns = {'speech': 'sentence'}, inplace = True)
    
    #if remove_punctuation == True:
    df['sentence'] = df['sentence'].str.replace('[^\w\s]','')
    
    return df


