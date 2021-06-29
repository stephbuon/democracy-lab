workhorse-parallel-context-vectors.ipynb pulls from https://smu.app.box.com/folder/135631615557

congress_model-1890-2010


This is all post-model code 


The gensim Word2Vec model does not expect strings as its text examples (sentences), 
but lists-of-tokens. Thus, it's up to your code to tokenize your text, 
before passing it to Word2Vec. 
