%% computes connectivity at the source level

clc; clear;

datapath = "/scratch/shareddata/set1/HCP-MEG/meg_extracted"; % path to the HCP data
savepath = "../../../data/statistic/connectivity/Restin/source/";

addpath '../../toolboxes/fieldtrip-20210114'; % fieldtrip is used for source reconstruction
ft_defaults

%% get HCP subject ids

subjects = dlmread("../../../data/hcp_subject_ids_restin.txt");
nsubj = numel(subjects);

%% frequency bands in which connectivity is computed

fbands = {[1,4], [4,8], [8,13], [13,30], [30,50], [1,90]};
fbandnames = ["delta"; "theta"; "alpha"; "beta"; "gamma"; "broad"]; 

k = 3;
fband = fbands{k};
fbandname = fbandnames(k);

%% connectivity metrics (aec, aec_ortho_pair, aec_ortho_sym, coh, icoh, pli, wpli, plm, plv, iplv)

methods = ["aec";"aec_ortho_pair";"plv";"pli";"plm"];
n_methods = size(methods, 1);

%% load aal atlas and interpolate onto the hcp standard sourcemodel
 
aal_ft = ft_read_atlas('../../toolboxes/fieldtrip-20210114/template/atlas/aal/ROI_MNI_V4.nii');
aal_ft = ft_convert_units(aal_ft, 'cm');

load("../../toolboxes/megconnectome-3.0/template/standard_sourcemodel3d8mm.mat", 'sourcemodel');
sourcemodel = ft_convert_units(sourcemodel, 'cm');

s = rmfield(sourcemodel, 'dim');
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
cfg.showcallinfo = 'no';
aal_ft_int = ft_sourceinterpolate(cfg, aal_ft, s);

%% loop through the subjects

for subj = 1:nsubj
   
    subj_id = num2str(subjects(subj));
    
    %% load sourcemodel and headmodel
    
    if subj_id == "100307"
        anatomyfolder = fullfile(datapath, sprintf("%s_2", subj_id), 'MEG', 'anatomy');
    else
        anatomyfolder = fullfile(datapath, subj_id, 'MEG', 'anatomy');
    end

    load(fullfile(anatomyfolder, sprintf("%s_MEG_anatomy_sourcemodel_3d8mm.mat", subj_id)), 'sourcemodel3d'); 
    sourcemodel = ft_convert_units(sourcemodel3d, 'cm');  

    load(fullfile(anatomyfolder, sprintf("%s_MEG_anatomy_headmodel.mat", subj_id)), 'headmodel');
    headmodel = ft_convert_units(headmodel, 'cm');       
    
    %% loop through the resting-state sessions
    
    for restin = 3:1:5 % resting-state session (3-5)
        
        %% load preprocessed MEG data
        
        load(fullfile(datapath, subj_id, 'MEG', 'Restin', 'rmegpreproc', sprintf("%s_MEG_%d-Restin_rmegpreproc.mat", subj_id, restin)), 'data');    
        
        %% compute spatial filters

        % trials are combined into one timeseries containing the entire measurement session
        dummydata = data;
        dummydata.trial = {cell2mat(data.trial)};
        dummydata.time = {[1:size(dummydata.trial{1},2)]/data.fsample};
        dummydata.sampleinfo = [1 size(dummydata.trial{1},2)];
        cfg = [];
        cfg.covariance = 'yes';
        cfg.keeptrials = 'no';
        cfg.showcallinfo = 'no';
        data_full = ft_timelockanalysis(cfg, dummydata);

        cfg = [];
        cfg.grad = data.grad;
        cfg.headmodel = headmodel;
        cfg.sourcemodel = sourcemodel;
        cfg.normalize = 'yes';
        cfg.unit = 'cm';
        cfg.method = 'lcmv';
        cfg.lcmv.fixedori = 'yes';
        cfg.lcmv.keepfilter = 'yes';
        cfg.lcmv.keepmom = 'no';
        cfg.showcallinfo = 'no';
        source = ft_sourceanalysis(cfg, data_full);  

        %% compute ROI timeseries
        
        fs = data.fsample;
        sensordata = data_full.avg;
        nsamples = size(sensordata, 2);

        nrois = numel(aal_ft_int.tissuelabel); % number of ROIs
        source_roi = aal_ft_int.tissue; % list of sources and corresponding ROIs
        
        roidata = zeros(nsamples, nrois);
        for roi = 1:nrois
            ids = find(source_roi==roi);    
            roi_filters = cell2mat(source.avg.filter(ids)); % spatial filters for the source within a ROI
            sourcesignals = transpose(roi_filters*sensordata); % signals of the sources within a ROI
            % take 1st principal component to represent the ROI
            [~, score, ~] = pca(sourcesignals, 'NumComponents', 1);
            roidata(:, roi) = score;
        end
        
        %% filter in to a specific frequency band

        roidata_filt = apply_filter(roidata, fbandname, fband, fs);

        %% compute connectivity using the metrics defined above

        fprintf(sprintf("Computing connectivity for subject=%s\n", subj_id));
    
        for m = 1:n_methods
            conn = compute_connectivity(methods(m), roidata_filt, nrois, fs);
            
            mkdir(fullfile(savepath,  methods{m}, fbandname, subj_id));
            dlmwrite(fullfile(savepath,  methods{m}, fbandname, subj_id, sprintf("%s_%d.txt", subj_id, restin)), conn);
        end

        
    end
end