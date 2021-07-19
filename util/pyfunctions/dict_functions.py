import re

def dict_keyword_lookup(dic, keywords_list):
    filtered_dic = {}
    
    regex = re.compile('|'.join(keywords_list))
    
    for key, value in dic.items():
        for item in value:
            if regex.search(item):
                if key in filtered_dic:
                    filtered_dic[key].append(item)
                else:
                    filtered_dic[key] = [item]
    
    return filtered_dic
