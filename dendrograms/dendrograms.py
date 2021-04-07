%matplotlib inline

from adjustText import adjust_text
# change the figure's size here
plt.figure(figsize=(5,5), dpi = 200)
# label each dot with the name of the word -- note that we have to use a "for" loop for this to work; plt.annotate only plots
# one label per iteration!
for i in range(len(periodnames)):
    for j in range(10):
        xx = periodnames[i]
        yy = [item[1] for item in women_context[i]][j]
        txt = [item[0] for item in women_context[i]][j]
        plt.scatter(
            xx, #x axis
            yy, # y axis
            linewidth=1,
            s = 55, # dot size
            alpha=0.8)  # dot transparency
        # make a label for each word
        plt.annotate(
                txt,
                (xx, yy),
                size = 10,
                color = 'black',
                alpha=0.8 # i've made the fonts transparent as well.  you could play with color and size if you wanted to.
            )
plt.xticks(rotation=90)
# Add titles
plt.title("Word Context Change for ''WOMAN'' Over Time in Congress", fontsize=20, fontweight=0, color='Red')
plt.xlabel("period")
plt.ylabel("similarity of word")
