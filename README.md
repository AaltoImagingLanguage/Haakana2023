# MEG fingerprinting

To run this code you need to modify the paths in some files to point to the appropriate parts of the data. It was used to analyse the HCP MEG resting state data, which has the MEG recordings in subject specific folders, and a list of participants in a separate text file. 
The text file is assumed to be located at "../../../data/hcp_subject_ids_restin.txt"
For using it with HCP data, the datapath variable in connectivity_sensor and connectivity_source, as well as in spectra_sensor and spectra_source needs to be set to the location of the HCP MEG data. 
For using with other data, the file loading patterns will also have to be ammended in the same files.
Other paths used in the scripts should be created by the scripts themselves.

In addition Fieldtrip is necessary to do some pre-computations and channel interpolation. The version used was 'fieldtrip-20210114'. Other versions should work, but proceed with caution.

# statistic: 
- contains scripts for computing connectivity and power spectra, and correlation-based fingerprinting

statistic/compute_statistic:
- connectivity_sensor: computes several FC metrics with sensor level data
- connectivity_source: computes several FC metrics with source level data
- spectra_sensor: computes power spectra with sensor level data
- spectra_source: computes power spectra with source level data 

statistic/correlation_identification:
- conn_corr: computes correlations between FC metrics from different measurement sessions and the identification accuracy based on the correlation values
- spectra_corr: computes correlations between power spectra from different measurement sessions and the identification accuracy based on the correlation values
- plot_acc_conn: visualizes the identification accuracies of different FC metrics as bar plot
- plot_correlations_conn: visualizes the correlation values of different FC metrics as violin plot

# brrr: 
- contains scripts for computing BRRR and examining BRRR results

brrr/compute_brrr:
- run_brrr_conn: computes BRRR using different FC metrics as training data
- run_brrr_conn_cv: computes leave-one-out cross-validation with different FC metrics
- run_brrr_spectra: computes BRRR using power spectra as training data
- run_brrr_spectra_cv: computes leave-one-out cross-validation with power spectra

brrr/brrr_results/brrr_accuracy:
- brrr_accuracy_conn: computes accuracy of the different BRRR models
- plot_acc_conn: visualizes accuracy of the different BRRR models as bar plot
- plot_acc_ggplot_conn: visualizes accuracy of the different BRRR models using ggplot

brrr/brrr_results/brrr_components:
- plot_brrr_components: visualizes latent components usign t-SNE

brrr/brrr_results/mantel_test:
- mantel_test_conn: computes mantel test between the distance matrices of different models
- plot_mantel_test_conn: visualizes the mantel test correlations

