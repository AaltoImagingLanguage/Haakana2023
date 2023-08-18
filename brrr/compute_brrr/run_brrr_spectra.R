## computes brrr with power spectra

source("brrr.R")
source("load_data.R")

n.iter <- 500

K_list <- list(10,20) # number of components (reduced rank) to use (max number of classes - 1)

# resting-state sessions used in training the models
measurements <- list(3,4,5) 


datafolder <- "../../../data/statistic/spectra/source/"
results_folder <- "../../../results/brrr/"

##### setup save folders
savepath_invgamma_data <- paste0(results_folder, "brrr_invgamma_hcp/spectra/")
dir.create(savepath_invgamma_data)
savepath_invgamma_space <- paste0(savepath_invgamma_data, "source/")
dir.create(savepath_invgamma_space) 
savepath_invgamma <- savepath_invgamma_space
##### 
    
subj_ids <- dir(datafolder)

for (measurement in measurements) {
  
  #### load data
  data <- load_data(subj_ids=subj_ids, method_band_folder=datafolder, 
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