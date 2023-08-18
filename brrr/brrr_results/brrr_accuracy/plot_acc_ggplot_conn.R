library(tidyverse)
library(RColorBrewer)

K_list <- list(2,6,10,20,50,80)
n_K <- length(K_list)

space <- "source" # source or sensor level data

training_id <- 3 # resting-state session used in training the model

methods <- list("aec_ortho_sym", "aec_ortho_pair", "icoh", "iplv", "pli", "wpli", "plm", "aec", "coh", "plv")
method_names <- list("cAECs", "cAECp", "iCoh", "iPLV", "PLI", "wPLI", "PLM", "AEC", "Coh", "PLV")
n_methods <- length(methods)

fbands <- list("delta", "theta", "alpha", "beta", "gamma")
fband_names <- list("Delta (1-4 Hz)", "Theta (4-8 Hz)", "Alpha (8-13 Hz)", "Beta (13-30 Hz)", "Gamma (30-50 Hz)")

datafolder <- "../../../../results/brrr/brrr_accuracy/connectivity/"

acc <- matrix(nrow=n_K*n_methods, ncol=4)
acc <- as.data.frame(acc)
colnames(acc) <- list("K", "Accuracy", "Method", "Frequency")

i <- 1
fband_idx <- 1
for (fband in fbands) {
  
  method_idx <- 1
  for (method in methods) {
    for (K in K_list) {
    
      method_band_folder <-  paste0(datafolder, space, "/", method, "/", fband, "/")
      filepath <- paste0(method_band_folder, "K", K, "_", training_id, ".txt")
      acc_temp <- read.csv(filepath, header = FALSE)
      
      acc[i,1] <- K
      acc[i,2] <- acc_temp[[1]]
      acc[i,3] <- method_names[method_idx]
      acc[i,4] <- fband_names[fband_idx]
        
      i <- i + 1
      
    }
    method_idx <- method_idx + 1
  }
  fband_idx <- fband_idx + 1
  
}

acc$Method <- factor(acc$Method, levels=method_names)
acc$Frequency <- factor(acc$Frequency, levels=fband_names)

p <- ggplot(data = acc, aes(x = K , y = Accuracy, color=Method)) + geom_line(size=1.0) + geom_point() + facet_wrap(.~Frequency) + theme_bw()
p <- p + scale_x_continuous(breaks=c(2,20,50,80), limits=c(2,80))
p <- p + scale_y_continuous(breaks=c(0, 20, 40, 60, 80, 100), limits=c(0,100))
p <- p + theme(axis.text.x = element_text(size=15), axis.text.y = element_text(size=15),
               axis.title.x = element_text(size=15), axis.title.y = element_text(size=15),
               legend.text=element_text(size=15), legend.title=element_text(size=15),
               strip.text  = element_text(size=15))
p <- p + scale_color_brewer(palette="Paired")
p



