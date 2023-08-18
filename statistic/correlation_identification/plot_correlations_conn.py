## plot correlations as violin plot

import numpy as np
import os 
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

datapath = "../../../results/correlations/correlation_values/HCP/Restin/source/connectivity/"

subjects = os.listdir("../../../data/statistic/spectra/HCP/source/")
nsubj = len(subjects)
subj_i = list(range(0,nsubj))

# frequency bands
fband_title = ["Delta (1-4 Hz)", "Theta (4-8 Hz)", "Alpha (8-13 Hz)",
                "Beta (13-30 Hz)", "Gamma (30-50 Hz)"]
fbands = ["delta", "theta", "alpha", "beta", "gamma"]
nbands = len(fbands)
bands_i = list(range(nbands))

# connectivity metrics
method_title = ["cAEC", "PLI", "PLM", "AEC", "PLV"]
methods = ["aec_ortho_pair", "pli", "plm", "aec", "plv"]
n_methods = len(methods)
methods_i = list(range(n_methods))

# measurement sessions that are compared
sessions1 = [3,4]    
sessions2 = [4,5]
n_session_pairs = len(sessions1)

for band, fb in zip(fbands, bands_i):   
    
    print(f"Frequency: {fband_title[fb]}")
    
    n_idx = n_session_pairs*nsubj*(nsubj-1)*n_methods+nsubj*n_session_pairs*n_methods
    df_columns = ['Method', 'Comparison', 'Session 1', 'Session 2', 'Correlations']
    df = pd.DataFrame(0, index=np.arange(n_idx), columns=df_columns)
    
    
    df_idx = 0
    for sess_i in range(0, n_session_pairs):
        
        s1 = sessions1[sess_i]
        s2 = sessions2[sess_i]
        
        for method, m in zip(methods, methods_i):    

            corr = pd.read_csv(os.path.join(datapath, method, band, f"corr_{s1}_{s2}.txt"), header=None)
            corr = corr.to_numpy()       
            corr = np.abs(corr)   
            
            other_corr_temp = np.copy(corr)
            
            corr_temp = np.zeros((nsubj,1))
            i = 0
            for subj in subj_i:
                corr_temp[i] = corr[subj,subj]
                other_corr_temp[subj, subj] = 0
                i = i + 1
                
            df.loc[df_idx:df_idx+nsubj-1] = [method_title[m], 'Self', s1, s2, np.squeeze(corr_temp)]
            df_idx = df_idx + nsubj
        
            corr_temp = np.zeros((nsubj*(nsubj-1), 1))
            i = 0
            x, y = np.nonzero(other_corr_temp)
            for  i in range(0, len(x)):
                corr_temp[i] = other_corr_temp[x[i], y[i]]
                i = i + 1
    
            df.loc[df_idx:df_idx+nsubj*(nsubj-1)-1] = [method_title[m], 'Other', s1, s2, np.squeeze(corr_temp)]
            df_idx = df_idx + nsubj*(nsubj-1)
            
            
          
    colors = sns.color_palette("tab10")
    palette = {'Self': colors[3], 'Other': colors[0]}
    
    sns.set(font_scale=1.8, rc={'figure.figsize':(8, 5)}) 
    sns.set_style("whitegrid")
    p = sns.violinplot(data=df, x="Method", y="Correlations", hue="Comparison", 
                       palette=palette, cut=0, split=True, linewidth=1.5, inner=None)
    
    p.set_yticks([0, 0.2, 0.4, 0.6, 0.8, 1.0])
    p.set(title=fband_title[fb], xlabel="", ylabel="Correlations")
    p.legend(title="", loc='lower right')
    p.tick_params(labelsize=18)
    p.set_xticklabels(method_title, rotation=30)
    
    plt.close()
    
    fig = p.get_figure()
    
    figname = os.path.join("../../../figures/correlations/", f"{band}.svg")
    fig.savefig(figname) 