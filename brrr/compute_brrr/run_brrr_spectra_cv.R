# leave-one-out cross-validation with power spectra

source("brrr.R")
source("load_data.R")
source("../brrr_results/brrr_accuracy/compute_distances.R")

n.iter <- 500

K <- 20 # number of latent components

exclude_siblings <- TRUE # whether or not to exclude the sibling of the test subject from the training set

space <- "source" # sensor or source level data


datafolder <- "../../../data/"
stat_folder <- paste0(datafolder, "statistic/spectra/HCP/", space, "/")

## choose measurement session for training
measurements <- list(3,4,5)  # all three measurement sessions
n_measurements <- length(measurements)

train_measurement <- measurements[[1]] # measurement session that is used in training the model
test_measurements <- measurements[measurements!=train_measurement]
###

## a list of the subject measurement ids
subj_ids_file <- paste0(datafolder, "hcp_subject_ids_restin.txt")
subj_ids <- scan(subj_ids_file) # individual subject ids
nsubj <- length(subj_ids)
subj_i <- 1:nsubj
##

### subject info for excluding siblings
subj_info_file <- paste0(datafolder, "hcp_subject_info.csv")
subj_info <- read.csv(subj_info_file)
subj_info <- subj_info[subj_info$Subject %in% subj_ids, ]
###


##### setup save folders
savepath_acc_fold <- "../../../results/brrr/brrr_accuracy_cv/"
dir.create(savepath_acc_fold) 
savepath_acc_data <- paste0(savepath_acc_fold, "spectra/")
dir.create(savepath_acc_data) 
savepath_acc_space <- paste0(savepath_acc_data, space, "/")
dir.create(savepath_acc_space) 
savepath_acc <- savepath_acc_space
##### setup save folders

#### load data
method_band_folder <- stat_folder
data <- load_data(subj_ids=subj_ids, method_band_folder=method_band_folder, 
                  measurements=measurements, train_measurement=train_measurement)

Y_mat <- data$Y_mat # matrix of the data of all the measurements
X_mat <- data$X_mat # matrix that identifies classes
fam <- data$fam #  list that identifies classes
Y_all <- data$Y_mat_all
###


test_ids <- 1:nsubj
for (test_id in test_ids) {
  
  test_subj <- subj_ids[test_id] # the subject who is classified in the cross-validation fold
  train_subj <- subj_ids[!subj_ids %in% test_subj] # the subjects who are used to train the model (all subjects - test subject)
  
  train_ids <- subj_i[!subj_i %in% test_id]
  
  if (exclude_siblings == TRUE) {
    
    test_info <- subj_info[subj_info$Subject %in% test_subj, ] # subj info of the test subjects
    train_info <- subj_info[subj_info$Subject %in% train_subj, ] # subj info of the training subjects
    
    family_id <- test_info$Family_ID # family id of the subject in the test set
    siblings <- subj_info[subj_info$Family_ID %in% family_id, ] # get the subjects with the family id
    
    train_info_updated <- train_info[!train_info$Subject %in% siblings$Subject, ] # remove sibling of test subject from train set
    
    # updated list of train subjects
    train_subj <- train_info_updated$Subject
    
    train_ids <- match(train_subj, subj_ids)
  }
  
  X_mat_cv <- X_mat[train_ids,train_ids,drop=FALSE] # matrix of the data of training measurements
  Y_mat_cv <- Y_mat[train_ids,] # matrix that identifies classes
  fam_cv <- fam[train_ids] # list that identifies classes
  
  # compute brrr
  res <- brrr(X_mat_cv, Y_mat_cv, K=K, n.iter=n.iter, init="LDA", fam=fam_cv)
  
  inv_gamma <- ginv(averageGamma(res)) # inverse projection of gamma
  
  # project the data 
  proj <- Y_all%*%inv_gamma
  
  # compute distances between subjects
  distances <- compute_distances(proj=proj)
  distances_cos <- distances$cos_dist
  
  ##### compute accuracy 
  
  # keep only the columns of the training session
  columns <- seq(train_measurement-2, n_measurements*nsubj, by=n_measurements)
  
  # get the row ids of the test subj
  row1 <- paste0(test_subj, "_", test_measurements[[1]]) 
  row2 <- paste0(test_subj, "_", test_measurements[[2]])
  rows <- c(row1, row2)
  
  # keep only the distances of the test subj
  dist <- distances_cos[rows, columns] 
  n_rows <- nrow(dist)
  
  # compute correct predictions based on the distance
  pred <- 0
  for (row in 1:n_rows) { 
    closest_id <- which.min(dist[row, ])
    closest_subj <- subj_ids[closest_id]
    row_subj <- sub("_.*", "", rows[row])
    if (closest_subj == row_subj) {
      pred <- pred + 1
    }
  }
  
  pred <- pred / n_rows 
  ##### compute accuracy
  
  # save accuracy
  filepath <- paste0(savepath_acc, "acc_K", K, "_", train_measurement, ".txt")
  write.table(pred, file=filepath, row.names=FALSE, col.names=FALSE) 
  
}
