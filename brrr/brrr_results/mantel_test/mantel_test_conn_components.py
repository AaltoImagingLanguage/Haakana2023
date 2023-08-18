#%% computes mantel test between models with different numbers of components

import numpy as np
import os 
import mantel

training_session = 3 # training session used in training the models

space = "source" # model trained with sensor or source level data

fbands = ["delta", "theta", "alpha", "beta", "gamma"] # frequency bands used to train the models

# FC metrics used to train the models
methods = ["aec_ortho_sym", "aec_ortho_pair", "icoh", "iplv", "pli", "wpli", 
           "plm", "aec", "coh", "plv"] 

K_list = [2,6,10,20,50,80] # the latent component numbers to compare
n_K = len(K_list)
K_i = list(range(n_K))

datapath = f"../../../../results/brrr/brrr_distances/connectivity/{space}/"
savefolder = f"../../../../results/mantel_test/mantel_test_components/connectivity/{space}/"


for method in methods:
    for fband in fbands:
                    
        corr = np.zeros((n_K, n_K))
        p = np.zeros((n_K, n_K))

        for K1, K_i1 in zip(K_list, K_i):
            
            for K2, K_i2 in zip(K_list, K_i):
            
                dist1 = np.loadtxt(os.path.join(datapath, method, fband, 
                                                f"K{K1}_{training_session}.txt"))
                dist2 = np.loadtxt(os.path.join(datapath, method, fband, 
                                                f"K{K2}_{training_session}.txt"))
                
                # compute correlation between distance matrices
                t = mantel.test(dist1, dist2, perms=1000, method='pearson', tail='upper')
    
                corr[K_i1 ,K_i2] =  t[0]
                p[K_i1, K_i2] = t[1]
        
        savepath = os.path.join(savefolder, f"corr_{method}_{fband}_{training_session}.txt")
        np.savetxt(savepath, corr, delimiter=',')
        savepath = os.path.join(savefolder, f"p_{method}_{fband}_{training_session}.txt")
        np.savetxt(savepath, p, delimiter=',')