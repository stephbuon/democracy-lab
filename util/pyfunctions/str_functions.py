import pandas as pd
import re

import spacy
nlp = spacy.load('en_core_web_sm', disable=['parser', 'ner'])


def str_split_df_sentences(df):
    split_rule = r"(?<!\w\.\w.)(?<![A-Z][a-z]\.)(?<=\.|\?)\s"
    
    df['speech'] = df['speech'].apply(lambda x: re.split(split_rule, x))
    
    df = df.explode('speech')
    df.reset_index()
    df.rename(columns = {'speech': 'sentence'}, inplace = True)
    
    df['sentence'] = df['sentence'].str.replace('[^\w\s]','') #if remove_punctuation == True:
    
    return df


#def lemmatize_df_text(df): # from textblob import Word
#    df['sentence'] = df['sentence'].str.split()
#    df['sentence'] = df['sentence'].apply(lambda x: [Word(word) for word in x])
#    df['sentence'] = df['sentence'].apply(lambda x: [word.lemmatize() for word in x])
#    df['sentence'] = df['sentence'].apply(lambda x: ' '.join(word for word in x))
    
#    return(df)

def lemmatize_df_text(df):    
    #df['sentence'] = list(nlp.pipe(df['sentence']) # instead of this i do nlp(x)
    df['sentence'] = df['sentence'].apply(lambda x: [token.lemma_ for token in nlp(x) if 'PRON' not in token.lemma_])
    df['sentence'] = df['sentence'].apply(lambda x: ' '.join(token for token in x))
    
    return(df)

