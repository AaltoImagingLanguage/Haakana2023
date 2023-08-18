compute_accuracy <- function(subj_measurements=subj_measurements, distances_cos=distances_cos,
                             train_ids=train_ids, test_ids=test_ids, subj_ids=subj_ids) {
  
  all_meas <- unlist(subj_measurements)
  
  test_meas <- all_meas[test_ids]
  train_meas <- all_meas[train_ids] # measurement sessions used in training the model
  
  nsubj <- length(subj_measurements)
  
  # create a confusion matrix 
  conf_mat <- matrix(0, nsubj, nsubj, dimnames=list(paste("True", subj_ids), paste("Pred", subj_ids)))
  
  
  dist <- distances_cos[test_ids, train_ids] # distances between subjects in latent space
  
  for (row in 1:length(test_meas)) {
    closest_id <- which.min(dist[row, ])
    test_subj <- paste("Pred", sub("_.*", "", train_meas[closest_id]))
    true_subj <-  paste("True", sub("_.*", "", test_meas[row]))
    conf_mat[true_subj, test_subj] <- conf_mat[true_subj, test_subj] + 1
  }
  
  
  # calculate the accuracy
  accuracy <- (sum(diag(conf_mat)) / sum(conf_mat))*100
  print(accuracy)
  
  return(accuracy)
  
}