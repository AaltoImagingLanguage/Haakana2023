#%% computes mantel test between models trained with different resting-state sessions

import numpy as np
import os 
import mantel


space = "source" # model trained with sensor or source level data

fbands = ["delta", "theta", "alpha", "beta", "gamma"] # frequency bands used to train the models

# FC metrics used to train the models
methods = ["aec_ortho_sym", "aec_ortho_pair", "icoh", "iplv", "pli", "wpli", 
           "plm", "aec", "coh", "plv"] 

K_list = [20] # the number of latent components of the model
  
rs_sessions = [3,4,5] # resting-state sessions used in training the models
n_rs = len(rs_sessions)
rs_i = list(range(n_rs))

datapath = f"../../../../results/brrr/brrr_distances/connectivity/{space}/"
savefolder = f"../../../../results/mantel_test/mantel_test_sessions/connectivity/{space}/"

for method in methods:
    for fband in fbands:
        for K in K_list:
                    
            corr = np.zeros((n_rs, n_rs))
            p = np.zeros((n_rs, n_rs))


            for restin1, r1 in zip(rs_sessions, rs_i):
                
                for restin2, r2 in zip(rs_sessions, rs_i):
                
                    dist1 = np.loadtxt(os.path.join(datapath, method, fband,
                                                    f"K{K}_{restin1}.txt"))
                    dist2 = np.loadtxt(os.path.join(datapath, method, fband,
                                                    f"K{K}_{restin2}.txt"))
                    
                    # compute correlation between distance matrices
                    t = mantel.test(dist1, dist2, perms=1000, method='pearson', tail='upper')
        
                    corr[r1 ,r2] =  t[0]
                    p[r1 ,r2] =  t[1]
        
            savepath = os.path.join(savefolder, f"corr_K{K}_{method}_{fband}.txt")
            np.savetxt(savepath, corr, delimiter=',')
            savepath = os.path.join(savefolder, f"p_K{K}_{method}_{fband}.txt")
            np.savetxt(savepath, p, delimiter=',')
