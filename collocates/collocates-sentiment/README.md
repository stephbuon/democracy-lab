### CLI Usage

| Arguments | Description | Format | Required |
| --- | --- | --- | --- |
| `--data` | Name of input data. | A delimited file. | True |
| `--sep` | Delimiter of input data. | Delimiter of the input data | True |
| `--col_name` | Name of column from which collocates will be extracted. | | True |
| `--keywords_list` | List of keywords to guide collocate extraction | A file ENTER | True |
| `--fpath_replace_list` | To find and replace words. | A two-column delimited file with the original spelling on the left, and the replacement on the right. | False |


JUST HAVE `spelling_preprocess` as the flag which takes the dir as an argument  

Example: `srun -p htc -c 1 --mem=20G python collocates_sentiment.py --data=hansard.csv --sep=, --col_name=text --keywords_list=propertywords.csv --spelling_preprocess=find_replace.csv`



### Output

A .csv file with fields for grammatical collocates of keywords and their sentiment scores.

Here, a grammatical collocate is defined as the direct parent or child of the keyword(s) (see: "[Navigating the Parse Tree](https://spacy.io/usage/linguistic-features)"). The sentiment of collocates is scored using: [TextBlob](https://textblob.readthedocs.io/en/dev/), [VADER](https://github.com/cjhutto/vaderSentiment), and [AFINN](https://github.com/fnielsen/afinn). 
