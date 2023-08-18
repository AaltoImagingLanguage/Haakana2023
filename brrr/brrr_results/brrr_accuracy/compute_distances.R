compute_distances <- function(proj=proj) {

  n_measurements <- dim(proj)[1] # total number of measurement sessions
  measurement_ids <- rownames(proj) # get all the measurement ids
  
  # create a distance matrices
  distances_cos <- matrix(nrow=n_measurements, ncol=n_measurements)
  rownames(distances_cos) <- measurement_ids
  colnames(distances_cos) <- measurement_ids
  
  distances_l2 <- matrix(nrow=n_measurements, ncol=n_measurements)
  rownames(distances_l2) <- measurement_ids
  colnames(distances_l2) <- measurement_ids
  
  distances_l1 <- matrix(nrow=n_measurements, ncol=n_measurements)
  rownames(distances_l1) <- measurement_ids
  colnames(distances_l1) <- measurement_ids
  
  # loop through all the measurement sessions and compute the distance
  for(i in 1:n_measurements){
    s1 <- proj[i, ]
    for(j in 1:n_measurements){
      s2 <- proj[j, ]
      if (i == j) {
        distances_cos[i,j] <- 0
        distances_l2[i,j] <- 0
        distances_l1[i,j] <- 0
      } 
      else {
        distances_cos[i,j] <- 1 - ( sum( s1 * s2 ) / (sqrt( sum( s1^2 ) ) * sqrt( sum( s2^2 ) ) ) )
        distances_l2[i,j] <- sqrt( sum( ( s1 - s2 )^2 ) )
        distances_l1[i,j] <- sum( abs( s1 - s2 ) )
      }    
    }
  }
  
  distances <- list(cos_dist=distances_cos, l1_dist=distances_l1, l2_dist=distances_l2)
  
  return(distances)

}