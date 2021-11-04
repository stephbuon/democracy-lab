import sys
import pickle
import pandas as pd
import spacy

nlp = spacy.load('en_core_web_sm', disable=['dep'])

def export_named_entities(data, arg1):

    named_entities = []

    for sentence in data['speech'].tolist():
        doc = nlp(sentence)
        entities = [str(entity) for entity in doc.ents]
        named_entities.append(entities)

    data['named_entities'] = named_entities

    if not data.empty:
        handle = open(arg1 + '.pickle', 'wb')
        pickle.dump(data, handle)
    else:
	exit()

arg1 = sys.argv[1]
data = pd.read_csv(arg1)
export_named_entities(data, arg1)
