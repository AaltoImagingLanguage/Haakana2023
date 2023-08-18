load_data <- function(subj_ids=subj_ids, method_band_folder=method_band_folder, measurements=measurements,
                      train_measurement=train_measurement) {
  
  nsubj <- length(subj_ids) # number of classes (i.e. individual subjects)
  n_measurements <- length(measurements)
  
  subj_measurements <- list()
  for (s_id in subj_ids) { # get subject ids and their measurement session numbers
    subj <- sprintf("%s", s_id)
    for (meas in measurements) {
      subj_meas <- paste0(subj, "_", meas)
      subj_measurements[[subj]] <- c(subj_measurements[[subj]], subj_meas)
    }
  }
  
  
  Y_mat_exist <- 0
  for (s_id in subj_ids) { # load the subjects and store their measurement data into Y_mat and Y_mat_all
    subj <- sprintf("%s", s_id)
    
    for (meas in measurements) {
      
      subj_meas <- paste0(subj, "_", meas)
        
      datafile <- paste0(method_band_folder, subj, "/", subj_meas, ".txt")
  
      meas_data <- t(read.table(datafile, sep=",",header=F)) # load the subject measurement data
      meas_data[is.nan(meas_data)] <- 1

      
      # create matrices for the measurement data
      if (Y_mat_exist == 0) {
        Y_size <- prod(dim(meas_data)) # the number of datapoints
        
        Y_mat <- matrix(NA, nsubj, Y_size, dimnames=list(subj_ids, c()))
        colnames(Y_mat) <- c(outer(paste0("s", 1:nrow(meas_data),"."), 1:ncol(meas_data), paste0))
        
        Y_mat_all <- matrix(NA, nsubj*n_measurements, Y_size, dimnames=list(unlist(subj_measurements)))
        
        Y_mat_exist <- 1
      }
      
      # set mirror values and diagonal in a square matrix to zero
      if(nrow(meas_data) == ncol(meas_data)) { 
        meas_data[lower.tri(meas_data)] <- 0 
        diag(meas_data) <- 0
      }
      
      if (meas == train_measurement) {
        Y_mat[subj,] <- c(meas_data) # contains the measurement data that is defined as train_measurement
      }
      
      Y_mat_all[subj_meas,] <- c(meas_data) # contains all the measurement data
      
    }
  }

  # remove zero values from Y_mat_all
  keepFeat <- which(apply(Y_mat_all, 2, var, na.rm=T) > 0) # apply var to each column
  Y_mat_all <- Y_mat_all[,keepFeat]
  # scale values
  Y_mat_all <- scale(Y_mat_all, center=TRUE, scale=TRUE)
  
  # remove zero values from Y_mat
  keepFeat <- which(apply(Y_mat, 2, var, na.rm=T) > 0) # apply var to each column
  Y_mat <- Y_mat[,keepFeat]
  # scale values
  Y_mat <- scale(Y_mat, center=TRUE, scale=TRUE)
  
  # create a list that identifies classes
  fam <- rep(NA, nsubj)
  names(fam) <- subj_ids
  for(s_i in 1:nsubj) {
    fam[s_i] <- s_i
  }
  # create a matrix that identifies classes
  X_mat <- matrix(0, nsubj, nsubj, dimnames=list(subj_ids, paste0("class",1:nsubj)))
  for(i in 1:length(fam)) {
    if(!is.na(fam[i])) {
      X_mat[i,fam[i]] <- 1
    }
  } 
  
  data <- list(Y_mat_all=Y_mat_all, Y_mat=Y_mat, X_mat=X_mat, fam=fam, keepFeat=keepFeat)
  
  return(data)
  
}
