### Usage

| Arguments | Description | Required |
| --- | --- | --- |
| `--data` | Name of input data. | True |
| `--sep` | Delimiter of input data. | True |
| `--col_name` | Name of column from which collocates will be extracted. | True |
| `--keywords_list` | List of keywords to guide collocate extraction | True |
| `--fpath_replace_list` | Name of input data. | False |


JUST HAVE `spelling_preprocessor` as the flag which takes the dir as an argument  


### Output

A .csv file with fields for grammatical collocates of keywords and their sentiment scores.

Here, a grammatical collocate is defined as the direct parent or child of the keyword(s) (see: "[Navigating the Parse Tree](https://spacy.io/usage/linguistic-features)"). The sentiment of collocates is scored using: [TextBlob](https://textblob.readthedocs.io/en/dev/), [VADER](https://github.com/cjhutto/vaderSentiment), and [AFINN](https://github.com/fnielsen/afinn). 
