#%% computes mantel test between models trained with sensor level and source level data

import numpy as np
import os 
import mantel

training_session = 3 # training session used in training the models

fbands = ["delta", "theta", "alpha", "beta", "gamma"] # frequency bands used to train the models

# FC metrics used to train the models
methods = ["aec_ortho_sym", "aec_ortho_pair", "icoh", "iplv", "pli", "wpli", 
           "plm", "aec", "coh", "plv"] 

K_list = [20]  # the number of latent components of the model


datapath_sensor = "../../../../results/brrr/brrr_distances/connectivity/sensor/"
datapath_source = "../../../../results/brrr/brrr_distances/connectivity/source/"

savefolder = "../../../../results/mantel_test/mantel_test_space/connectivity/"

for K in K_list:
    for method in methods:
        for fband in fbands:
                corr = np.zeros((1, 1))
                p = np.zeros((1, 1))
                
                dist1 = np.loadtxt(os.path.join(datapath_sensor, method, fband, 
                                                f"K{K}_{training_session}.txt"))
                dist2 = np.loadtxt(os.path.join(datapath_source, method, fband, 
                                                f"K{K}_{training_session}.txt"))
                
                # compute correlation between distance matrices
                t = mantel.test(dist1, dist2, perms=1000, method='pearson', tail='upper')
    
                corr[0] = t[0]
                p[0] =  t[1]
                
                savepath = os.path.join(savefolder, f"corr_K{K}_{method}_{fband}_{training_session}.txt")
                np.savetxt(savepath, corr, delimiter=',')
                savepath = os.path.join(savefolder, f"p_K{K}_{method}_{fband}_{training_session}.txt")
                np.savetxt(savepath, p, delimiter=',')