import sys
import os
import pickle
import pandas as pd
import spacy

nlp = spacy.load('en_core_web_sm', disable=['parser', 'lemmatizer', 'tagger'])

def extract_person(sentence):
    return [str(entity.text) if entity.label_ == 'PERSON' else '' for entity in sentence.ents]

def extract_norp(sentence):
    return [str(entity.text) if entity.label_ == 'NORP' else '' for entity in sentence.ents]

def extract_fac(sentence):
    return [str(entity.text) if entity.label_ == 'FAC' else '' for entity in sentence.ents]

def extract_org(sentence):
    return [str(entity.text) if entity.label_ == 'ORG' else '' for entity in sentence.ents]

def extract_gpe(sentence):
    return [str(entity.text) if entity.label_ == 'GPE' else '' for entity in sentence.ents]

def extract_loc(sentence):
    return [str(entity.text) if entity.label_ == 'LOC' else '' for entity in sentence.ents]

def extract_product(sentence):
    return [str(entity.text) if entity.label_ == 'PRODUCT' else '' for entity in sentence.ents]

def extract_event(sentence):
    return [str(entity.text) if entity.label_ == 'EVENT' else '' for entity in sentence.ents]

def extract_date(sentence):
    return [str(entity.text) if entity.label_ == 'DATE' else '' for entity in sentence.ents]

def extract_time(sentence):
    return [str(entity.text) if entity.label_ == 'TIME' else '' for entity in sentence.ents]

def extract_named_entity(sentence):
    # returns [ent, ent, ent]
    return [str(entity.text) for entity in sentence.ents] 
    
def extract_named_entity_category(sentence):
    # returns [lab, lab, lab]
    return [str(entity.label_) for entity in sentence.ents]

def extract_named_entity_w_category(sentence):
    # returns [(lab, ent), (lab, ent), (lab, ent)]
    return [(entity.text, entity.label_) for entity in sentence.ents]

def remove_rows_no_entities(data):
    # optional -- can add to export_named_entities()
    return data[data['named_entities'].map(bool)]

def export_named_entities(data, extraction_col, output_path):
    data[extraction_col] = data[extraction_col].astype(str)
    data['parsed_text'] = list(nlp.pipe(data[extraction_col]))
    
    #data['named_entities'] = data['parsed_text'].apply(extract_named_entity)
    
    data['person'] = data['parsed_text'].apply(extract_person)
    data['norp'] = data['parsed_text'].apply(extract_norp)
    data['fac'] = data['parsed_text'].apply(extract_fac)
    data['org'] = data['parsed_text'].apply(extract_org)
    data['gpe'] = data['parsed_text'].apply(extract_gpe)
    data['loc'] = data['parsed_text'].apply(extract_loc)
    data['product'] = data['parsed_text'].apply(extract_product)
    data['event'] = data['parsed_text'].apply(extract_event)
    data['date'] = data['parsed_text'].apply(extract_date)
    data['time'] = data['parsed_text'].apply(extract_time)

    del data['parsed_text']
    data.set_index([extraction_col]).apply(pd.Series.explode).reset_index()

    if not data.empty:
        handle = open(os.path.split(os.getcwd())[0] + '/data/' + str(job_id) + '.pickle', 'wb') # add unique job array task id or whatever. 
        pickle.dump(data, handle)
        print('Finished and saved pickle')
    else:
        print('Finish and no pickled data produced')
        exit()

if __name__ == '__main__':
    try:
        input_file = sys.argv[1]
        extraction_col = sys.argv[2]
        job_id = sys.argv[3]
        
    except IndexError:
        exit('Requires 2 arguments: Name of input CSV and name of column to extract named entities.')
        
    data = pd.read_csv(input_file)
    
    export_named_entities(data, extraction_col, job_id)
