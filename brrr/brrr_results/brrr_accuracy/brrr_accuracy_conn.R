# computes accuracy of the models trained with FC metrics

source("../../compute_brrr/load_data.R")
source("compute_distances.R")
source("compute_accuracy.R")

K_list <- list(20) # number of latent components

space <- "source" # source or sensor level data

train_measurement <- 3 # the resting-state session used to train the model

methods <- list("aec", "aec_ortho_pair", "plv", "pli", "plm")
fbands <- list("delta", "theta", "alpha", "beta", "gamma")


measurements <- list(3, 4, 5) # all measurement session ids
n_measurements <- length(measurements)

## setup save folders
savepath_acc_data <- "../../../../results/brrr/brrr_accuracy/connectivity/"
dir.create(savepath_acc_data) 
savepath_acc_space <- paste0(savepath_acc_data, space, "/")
dir.create(savepath_acc_space) 

savepath_comp_data <- "../../../../results/brrr/brrr_components/connectivity/"
dir.create(savepath_comp_data) 
savepath_comp_space <- paste0(savepath_comp_data, space, "/")
dir.create(savepath_comp_space) 

savepath_dist_data <- "../../../../results/brrr/brrr_distances/connectivity/"
dir.create(savepath_dist_data) 
savepath_dist_space <- paste0(savepath_dist_data, space, "/")
dir.create(savepath_dist_space) 
##


for (K in K_list) {
  for (method in methods) {
    print(method)
    for (fband in fbands) {
      print(fband)
      
      ### create save folders
      savepath_acc_method <- paste0(savepath_acc_space, method, "/")
      dir.create(savepath_acc_method) 
      savepath_acc_fband <- paste0(savepath_acc_method, fband, "/")
      dir.create(savepath_acc_fband) 
      savepath_acc <- savepath_acc_fband
      
      savepath_comp_method <- paste0(savepath_comp_space, method, "/")
      dir.create(savepath_comp_method) 
      savepath_comp_fband <- paste0(savepath_comp_method, fband, "/")
      dir.create(savepath_comp_fband) 
      savepath_comp <- savepath_comp_fband
      
      savepath_dist_method <- paste0(savepath_dist_space, method, "/")
      dir.create(savepath_dist_method) 
      savepath_dist_fband <- paste0(savepath_dist_method, fband, "/")
      dir.create(savepath_dist_fband) 
      savepath_dist <- savepath_dist_fband
      ####
      
      ## get the subj ids 
      method_band_folder <- paste0("../../../../data/statistic/connectivity/HCP/Restin/", space, "/", method, "/", fband, "/")
      subj_ids <- dir(method_band_folder)
      nsubj <- length(subj_ids)
      
      #### load data
      data <- load_data(subj_ids=subj_ids, method_band_folder=method_band_folder, 
                        measurements=measurements, train_measurement=train_measurement)
      
      Y_mat_all <- data$Y_mat_all # matrix of the data of all the measurements
      ####
      
      
      # load the inverse of gamma
      invgamma_folder <- paste0("../../../../results/brrr/brrr_invgamma_hcp/connectivity/Restin/", space, "/")
      filepath <- paste0(invgamma_folder, method, "/", fband, "/", "invgamma_K", K, "_", train_measurement, ".RData")
      load(filepath)
          
      # project the data 
      proj <- Y_mat_all%*%inv_gamma
      
      # compute distances between subjects
      distances <- compute_distances(proj=proj)
      distances_cos <- distances$cos_dist
      
      
      subj_measurements <- list()
      for (s_id in subj_ids) { # get subject ids and their measurement session numbers
        subj <- sprintf("%s", s_id)
        for (meas in measurements) {
          subj_meas <- paste0(subj, "_", meas)
          subj_measurements[[subj]] <- c(subj_measurements[[subj]], subj_meas)
        }
      }
      
      # compute accuracy from the distances
      train_ids <- seq(train_measurement-2, n_measurements*nsubj, by=n_measurements)
      test_ids <- seq(1, n_measurements*nsubj)
      test_ids <- setdiff(test_ids, train_ids)
      accuracy <- compute_accuracy(subj_measurements=subj_measurements, distances_cos=distances_cos,
                                   train_ids=train_ids, test_ids=test_ids, subj_ids=subj_ids)
      
      
      # save dist
      filepath <- paste0(savepath_dist, "K", K, "_", train_measurement, ".txt")
      write.table(distances_cos, file=filepath, row.names=FALSE, col.names=FALSE) 
      
      # save comp
      filepath <- paste0(savepath_comp, "K", K, "_", train_measurement, ".txt")
      write.table(proj, file=filepath, row.names=FALSE, col.names=FALSE) 
      
      # save accuracy
      filepath <- paste0(savepath_acc, "K", K, "_", train_measurement, ".txt")
      write.table(accuracy, file=filepath, row.names=FALSE, col.names=FALSE) 
      
      
    }
  }
}