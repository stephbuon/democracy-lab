import pandas as pd

from afinn import Afinn
from textblob import TextBlob
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from nltk.corpus import sentiwordnet as swn
from nltk.sentiment.vader import SentimentIntensityAnalyzer


def afinn_sentiment(text):
    return Afinn().score(text)


def textblob_sentiment(text):
    return TextBlob(text).sentiment.polarity


def vader_sentiment(text):
    return SentimentIntensityAnalyzer().polarity_scores(text)

  
def sentiment_score_df(df, col_name):
    df['afinn'] = df[col_name].apply(afinn_sentiment)
    df['textblob'] = df[col_name].apply(textblob_sentiment)
    df['vader'] = df[col_name].apply(vader_sentiment)
    df['vader'] = df['vader'].apply(lambda score_dict: score_dict['compound'])    
    return df
