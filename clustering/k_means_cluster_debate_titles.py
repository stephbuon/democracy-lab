import csv
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans

with open('/users/sbuongiorno/hansard_c19_debate_titles.csv', newline='') as f:
    imported_data = csv.reader(f)
    header = next(imported_data)
    debate_titles_lists = list(imported_data)
    debate_titles_strings = [''.join(title) for title in debate_titles_lists]
    
vectorizer = TfidfVectorizer()

debate_titles_vectors = vectorizer.fit_transform(debate_titles_strings)

sum_of_squared_distances = []
K = range(2, 10)

for k in K:
    km = KMeans(n_clusters = k, 
                max_iter = 200, 
                n_init = 10)
    km = km.fit(debate_titles_vectors)
    sum_of_squared_distances.append(km.inertia_)
    
true_k = 160

model = KMeans(n_clusters=true_k, 
               init='k-means++', 
               max_iter = 200, 
               n_init = 10)
model.fit(debate_titles_vectors)

labels = model.labels_

test_clusters = pd.DataFrame(list(zip(debate_titles_strings, labels)), columns = ['title','cluster'])

test_clusters.to_csv('test_clusters.csv', index = False)
