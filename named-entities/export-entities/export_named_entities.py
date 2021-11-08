import sys
import pickle
import pandas as pd
import spacy

nlp = spacy.load('en_core_web_sm', disable=['parser', 'lemmatizer', 'tagger'])


def extract_named_entity(sentence):
    return [str(entity) for entity in sentence.ents]   
    
def export_named_entities(data, arg1):   
    hansard['parsed_text'] = list(nlp.pipe(hansard['text']))
    hansard['named_entities'] = hansard['parsed_text'].apply(extract_named_entity)
    
    
    if not data.empty:
        handle = open(arg1 + '.pickle', 'wb')
        pickle.dump(data, handle)
    else:
        exit()

arg1 = sys.argv[1]
data = pd.read_csv(arg1)
export_named_entities(data, arg1)
