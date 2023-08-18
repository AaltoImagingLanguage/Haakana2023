## computes brrr with connectivity metrics

source("brrr.R")
source("load_data.R")

n.iter <- 500

K_list <- list(2,6,10,20,50,80) # number of components (reduced rank) to use (max number of classes - 1)

# FC metrics used in training the models
methods <- list("aec", "aec_ortho_sym", "aec_ortho_pair", "coh", "icoh", "plv", "iplv", "pli", "wpli", "plm")

# frequency bands of FC metrics
fbands <- list("delta", "theta", "alpha", "beta", "gamma")

# resting-state sessions used in training the models
measurements <- list(3,4,5)


datafolder <- "../../../data/statistic/connectivity/HCP/Restin/source/"
results_folder <- "../../../results/brrr/"

for (method in methods) {
  for (fband in fbands) {
    
    ##### setup save folders
    savepath_invgamma_data <- paste0(results_folder, "brrr_invgamma_hcp/connectivity/")
    dir.create(savepath_invgamma_data)
    savepath_invgamma_method <- paste0(savepath_invgamma_data, method, "/")
    dir.create(savepath_invgamma_method) 
    savepath_invgamma_fband <- paste0(savepath_invgamma_method, fband, "/")
    dir.create(savepath_invgamma_fband) 
    savepath_invgamma <- savepath_invgamma_fband
    ##
    
    for (measurement in measurements) {
      
      #### load data
      method_band_folder <- paste0(datafolder, method, "/", fband, "/")
      subj_ids <- dir(method_band_folder)
      
      data <- load_data(subj_ids=subj_ids, method_band_folder=method_band_folder, 
                          measurements=measurements, train_measurement=measurement)

      Y_mat <- data$Y_mat # matrix of the data of all the measurements
      X_mat <- data$X_mat # matrix that identifies classes
      fam <- data$fam #  list that identifies classes
      ####
    
      for (K in K_list) {
        
        # compute brrr 
        res <- brrr(X_mat, Y_mat, K=K, n.iter=n.iter, init="LDA", fam=fam)
        
        inv_gamma <- ginv(averageGamma(res)) # inverse projection of gamma
        
        # save the projection matrix 
        savefile <- paste0(savepath_invgamma, "invgamma_K", K, "_", measurement, ".RData")
        save(inv_gamma, file=savefile)
      
      }

    }
  }
}
