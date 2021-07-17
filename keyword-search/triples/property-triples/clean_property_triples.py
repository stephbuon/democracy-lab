import re
import pandas as pd


def clean_property_triples(f_path, keywords_path):
    hansard_triples = pd.read_csv(f_path)
    
    hansard_triples['triple'] = hansard_triples['triple'].str.lower()

    with open(keywords_path) as f:
        keywords_list = f.read().splitlines()[1:] # skip the header   
    
    clean_hansard_triples = pd.DataFrame()
    for keyword in keywords_list:
        
        regex_1 = re.compile('-' + keyword + ('$'))
        filtered_hansard_triples = hansard_triples[hansard_triples['triple'].str.match(regex_1)]
        clean_hansard_triples = pd.concat([clean_hansard_triples, filtered_hansard_triples], axis=0)
        
        regex_2 = re.compile('^' + keyword + '-')
        filtered_hansard_triples = hansard_triples[hansard_triples['triple'].str.match(regex_2)]
        clean_hansard_triples = pd.concat([clean_hansard_triples, filtered_hansard_triples], axis=0)
        
        regex_3 = re.compile('-' + keyword + '-')
        filtered_hansard_triples = hansard_triples[hansard_triples['triple'].str.match(regex_3)]
        clean_hansard_triples = pd.concat([clean_hansard_triples, filtered_hansard_triples], axis=0)
        
        
    return clean_hansard_triples

data = clean_property_triples('/users/sbuongiorno/triples_in_hansard/hansard_c19_debate_text_property_triples.csv', 
                              '/users/sbuongiorno/propertywords_cleaned_for_w2v_1grams.csv')

del data['X1']
del data['n']
del data['Unnamed: 0']

data.to_csv('/scratch/group/pract-txt-mine/stuff_from_last_couple_months/hansard_c19_clean_property_triples_07162021.csv', index = False)
