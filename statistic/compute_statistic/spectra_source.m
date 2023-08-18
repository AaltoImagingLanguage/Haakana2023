%% compute source level power spectra

clc; clear;

datapath = "/scratch/shareddata/set1/HCP-MEG/meg_extracted"; % path to the HCP data
savepath = "../../../data/statistic/spectra/source/";

addpath '../../toolboxes/fieldtrip-20210114'; % fieldtrip is used for source reconstruction
ft_defaults

%% get HCP subject ids

subjects = dlmread("../../../data/hcp_subject_ids.txt");
nsubj = numel(subjects);

%% frequency intervals for averaging power spectra

fbands = dlmread("../../../data/mean_spectra_freqs.txt");
nbands = size(fbands, 1);

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

        % all the trials are combined into one timeseries containing the entire measurement session
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
        %cfg.lcmv.fixedori = 'yes';
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
        
        %% compute power spectra
            
        fprintf(sprintf("Computing power spectra for subject=%s\n", subj_id));

        [pxx, f] = pwelch(roidata, [], [], [], fs);

        % average over the frequency ranges
        spectra_mean = zeros(nbands, nrois);
        for b = 1:nbands
            s = fbands(b, :);
            ids = find(f > s(1) & f <= s(2)); % ids that are in the current frequency interval
            tmp = pxx(ids, :);
            spectra_mean(b, :) = mean(tmp,1); % take the mean power of the frequency interval
        end

        mkdir(fullfile(savepath, subj_id));
        dlmwrite(fullfile(savepath, subj_id, sprintf('%s_%d.txt', subj_id, restin)), spectra_mean);
        
    end
end