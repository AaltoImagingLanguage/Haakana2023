#%% computes mantel test between models trained with different FC methods

import numpy as np
import os 
import mantel

training_session = 3 # training session used in training the models

space = "source" # model trained with sensor or source level data

fbands = ["delta", "theta", "alpha", "beta", "gamma"] # frequency bands used to train the models

# FC metrics used to train the models
methods = ["aec_ortho_sym", "aec_ortho_pair", "icoh", "iplv", "pli", "wpli", 
           "plm", "aec", "coh", "plv"] 
n_methods = len(methods)
methods_i = list(range(n_methods))

K_list = [20]  # the number of latent components of the model

datapath = f"../../../../results/brrr/brrr_distances/connectivity/{space}/"
savefolder = f"../../../../results/mantel_test/mantel_test_methods/{space}/"
 

for K in K_list:
    for fband in fbands:
                
        corr = np.zeros((n_methods, n_methods))
        p = np.zeros((n_methods, n_methods))

        for method1, m1 in zip(methods, methods_i):
            
            for method2, m2 in zip(methods, methods_i):
            
                dist1 = np.loadtxt(os.path.join(
                    datapath, method1, fband, f"K{K}_{training_session}.txt"))
                dist2 = np.loadtxt(os.path.join(
                    datapath, method2, fband, f"K{K}_{training_session}.txt"))
                
                # compute correlation between distance matrices
                t = mantel.test(dist1, dist2, perms=1000, method='pearson', tail='upper')
    
                corr[m1,m2] =  t[0]
                p[m1, m2] = t[1]
        
        savepath = os.path.join(savefolder, f"corr_K{K}_{fband}_{training_session}.txt")
        np.savetxt(savepath, corr, delimiter=',')
        savepath = os.path.join(savefolder, f"p_K{K}_{fband}_{training_session}.txt")
        np.savetxt(savepath, p, delimiter=',')
            
            
            