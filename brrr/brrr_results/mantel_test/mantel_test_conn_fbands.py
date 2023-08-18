#%% computes mantel test between models trained with different frequency bands

import numpy as np
import os 
import mantel

training_session = 3 # training session used in training the models

space = "source" # model trained with sensor or source level data

fbands = ["delta", "theta", "alpha", "beta", "gamma"] # frequency bands used to train the models
nbands = len(fbands)
fbands_i = list(range(nbands))

# FC metrics used to train the models
methods = ["aec_ortho_sym", "aec_ortho_pair", "icoh", "iplv", "pli", "wpli", 
           "plm", "aec", "coh", "plv"] 

K_list = [20] # the number of latent components of the model

datapath = f"../../../../results/brrr/brrr_distances/connectivity/{space}/"
savefolder = f"../../../../results/mantel_test/mantel_test_fbands/{space}/"


for K in K_list:
    for method in methods:     
                
        corr = np.zeros((nbands, nbands))
        p = np.zeros((nbands, nbands))

        for fband1, f1 in zip(fbands, fbands_i):
            
            for fband2, f2 in zip(fbands, fbands_i):
            
                dist1 = np.loadtxt(os.path.join(datapath, method, fband1, 
                                                f"K{K}_{training_session}.txt"))
                dist2 = np.loadtxt(os.path.join(datapath, method, fband2, 
                                                f"K{K}_{training_session}.txt"))
                
                # compute correlation between distance matrices
                t = mantel.test(dist1, dist2, perms=1000, method='pearson', tail='upper')
    
                corr[f1 ,f2] =  t[0]
                p[f1 ,f2] =  t[1]
        
        savepath = os.path.join(savefolder, f"corr_K{K}_{method}_{training_session}.txt")
        np.savetxt(savepath, corr, delimiter=',')
        savepath = os.path.join(savefolder, f"p_K{K}_{method}_{training_session}.txt")
        np.savetxt(savepath, p, delimiter=',')
                