class collocate_analysis:

    def import_data(fpath, sep, extraction_col, year_col, **kwargs): #col_name, **kwargs):
        preprocess_find_replace = kwargs.get('preprocess_find_replace', None)
    
        data = pd.read_csv(fpath, sep=sep)
    
        data = data[[extraction_col, year_col]]
    
        if preprocess_find_replace is not None:
            data = preprocess_df.find_replace(data, extraction_col, preprocess_find_replace)
   
        year = []
        text = []

        for index, row in data.iterrows():
            year.append(row['year'])
            text.append(row['text'])
        
        year_text_list = list(zip(year, text))
        
        year_text_dict = {}
    
        for (tup1, tup2) in year_text_list:
            if tup1 in year_text_dict:
                year_text_dict[tup1].append(tup2)
            else:
                year_text_dict[tup1] = [tup2]
            
        year_text_dict = {str(key): value for key, value in year_text_dict.items()}

        return year_text_dict
        
    
    def extract_grammatical_collocates(dic, keywords_list, **kwargs):
    
        if type(keywords_list) != list:
            raise TypeError('keywords_list must be a list.')
        
        regex = re.compile('|'.join(keywords_list))
    
        all_collocates_df = pd.DataFrame()
    
        for key, value in dic.items():
            year = key
        
            for sentence in value:
                doc = nlp(sentence)
            
                collocates = []
                for token in doc:
                    if regex.match(token.text):
                        if token.dep == nsubj or nsubjpass or dobj or pobj:
                            for child in token.children:
                                if child.dep_ == 'amod':
                                    collocates.append(str(token.text) + ' ' + str(child))
                        
                collocates_df = pd.DataFrame(collocates, columns=['grammatical_collocates'])
                collocates_df['year'] = year
            
                all_collocates_df = pd.concat([all_collocates_df, collocates_df], axis=0)

        return all_collocates_df
