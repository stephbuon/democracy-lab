first use interval subset 

hansard = pd.read_csv('hansard_justnine_debate_titles_w_year.csv')
interval_subset(hansard, 'year', 1800, 1920, 10, 'hansard_justnine_decades')

cd to that directory 
run all the code.


counts two key words per row of debate text
