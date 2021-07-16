def import_keywords_list(dir_path):
    with open(dir_path) as f:
        keywords_list = f.read().splitlines()[1:] # skip the header
    return keywords_list
