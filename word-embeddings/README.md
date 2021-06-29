# Word Embeddings Directory

| Folder | Description |
| --- | --- |
| **us-congress/congressional_data_word2vec.ipynb** | For making, exploring, and visualizing word embeddings in the US congressional records. |
| **us-congress/originals** | The original code versions. |
| **hansard/hansard_word2vec.ipynb** | For making, exploring, and visualizing word embeddings in the Hansard data. |

Notes: 
- The gensim Word2Vec model does not expect strings as its text input, but rather lists of tokens. Therefore, the coder must tokenize the text before passing it to Word2Vec. 
