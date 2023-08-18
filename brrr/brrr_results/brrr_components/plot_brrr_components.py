## visualizes the latent components using t-SNE

import numpy as np
import matplotlib.pyplot as plt
from sklearn.manifold import TSNE
import os 
import random

datatype = "spectra" # spectra or connectivity
space = "source" # sensor or source level data 

# fc metric and frequency band, if connectivity is used
fc_metric = "plv" 
fband = "delta" 

K = 20 # number of latent components

train_meas = 3 # measurement session (3-5) used in extracting the components
n_test_meas = 3 # total number of resting-state sessions that are visualized

n_total_subj = 89 # total number of subjects

nsubj = 50 # number of subjects that are visualized 

# set the folder where the latent components are stored
mainfolder = "../../../../results/brrr/brrr_components/"
if datatype =="spectra":
    datafolder = os.path.join(mainfolder, f"spectra/{space}/")
elif datatype =="connectivity":
    datafolder = os.path.join(mainfolder, f"connectivity/{space}/{fc_metric}/{fband}")
    

### define markers for visualization
dotsize = 80
bordersize = 2

c_list = ["tab:blue","tab:orange","tab:green","tab:red","tab:purple","tab:brown",
          "tab:pink","tab:gray","tab:olive","tab:cyan","k"]
n_colors = len(c_list)

value_pairs = []
i = 0
j = 0
while i < n_colors:
    while j < n_colors:
        if i != j and ([i,j] or [j,i]) not in value_pairs: 
            value_pairs.append([i,j])
            value_pairs.append([j,i])
        j = j + 1
    j = 0
    i = i + 1
###
    
    
### t-SNE parameters
perplexity = 30 # default = 30
early_exaggeration = 12 # default = 12
learning_rate = 200 # default = 200
###

# load the latent components
comp = np.loadtxt(os.path.join(datafolder, f"K{K}_{train_meas}.txt"))



## take a random set of subjects
subj_ids = random.sample(range(1, n_total_subj), nsubj)
subj_ids.sort()
comp_temp = np.zeros((nsubj*n_test_meas, K))
i = 0
for subj in subj_ids:
    for j in range(0, n_test_meas):
        comp_temp[i+j] = comp[(subj-1)*n_test_meas+j, :]
    i = i + n_test_meas 
comp = comp_temp
##

## compute t-SNE, when K>2
if K != 2:
    comp = TSNE(perplexity=perplexity, early_exaggeration=early_exaggeration,
                   learning_rate=learning_rate).fit_transform(comp)


plt.figure(figsize=[7, 5])
## plot as scatter plot
color_i = 0 # color index
for subj in range(0, nsubj*n_test_meas, n_test_meas): # loop through individual subjects
    c_fill = c_list[value_pairs[color_i][0]] # fill color
    c_edge = c_list[value_pairs[color_i][1]] # edge color
    for subj_meas in range(0, n_test_meas, 1): # loop through measurements of a given subject
        plt.scatter(comp[subj+subj_meas, 0], comp[subj+subj_meas, 1], 
                    color=c_fill, edgecolor=c_edge, 
                    s=dotsize, linewidths=bordersize)
    plt.xticks([])
    plt.yticks([])
    color_i = color_i + 1

