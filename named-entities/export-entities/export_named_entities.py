import sys
import pickle
import pandas as pd
import spacy

nlp = spacy.load('en_core_web_sm', disable=['parser', 'lemmatizer', 'tagger'])

def extract_named_entity(sentence):
    return [str(entity.text) for entity in sentence.ents]   
    # return [(entity.text, entity.label_) for entity in sentence.ents]   
    
def extract_named_entity_category(sentence):
    return [str(entity.label_) for entity in sentence.ents]

def export_named_entities(data, arg1):

    data['sentence'] = data['sentence'].astype(str)
    data['parsed_text'] = list(nlp.pipe(data['sentence']))
    data['named_entities'] = data['parsed_text'].apply(extract_named_entity)
    #data['named_entity_category'] = data['parsed_text'].apply(extract_named_entity_category)

    #data = data[data['named_entities'].map(bool)]

    if not data.empty:
        handle = open(os.path.basename(arg1) + '.pickle', 'wb')
        pickle.dump(data, handle)
        print('Finished and saved pickle')
    else:
        print('Finish and no pickled data produced')
        exit()

arg1 = sys.argv[1]
data = pd.read_csv(arg1)
export_named_entities(data, arg1)

