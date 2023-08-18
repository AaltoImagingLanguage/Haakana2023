%% computes connectivity between sensors

clc; clear;

datapath = "/scratch/shareddata/set1/HCP-MEG/meg_extracted"; % path to the HCP data
savepath = "../../../data/statistic/connectivity/sensor/";

addpath '../../toolboxes/fieldtrip-20210114'; % fieldtrip is used for interpolating missing channels
ft_defaults

%% get HCP subject ids

subjects = dlmread("../../../data/hcp_subject_ids_restin.txt");
nsubj = numel(subjects);

%% frequency bands in which connectivity is computed

fbands = {[1,4], [4,8], [8,13], [13,30], [30,50], [1,90]};
fbandnames = ["delta"; "theta"; "alpha"; "beta"; "gamma"; "broad"]; 

k = 1;
fband = fbands{k};
fbandname = fbandnames(k);

%% connectivity metrics (aec, aec_ortho_pair, aec_ortho_sym, coh, icoh, pli, wpli, plm, plv, iplv)

methods = ["aec";"aec_ortho_pair";"plv";"pli";"plm"];
n_methods = size(methods, 1);

%% loop through the subjects

for subj = 1:nsubj
   
    subj_id = num2str(subjects(subj));  
    
    %% loop through the resting-state sessions
    
    for restin = 3:1:5 % resting-state session (3-5)
        
        %% load preprocessed MEG data
        
        load(fullfile(datapath, subj_id, 'MEG', 'Restin', 'rmegpreproc', sprintf("%s_MEG_%d-Restin_rmegpreproc.mat", subj_id, restin)), 'data');    
        
        %% interpolate removed channels
        
        % replace removed channels with zeros
        label = ft_channelselection('meg', data.hdr.grad.label);
        [notmissing, dummy] = match_str(label, data.label);
        newtrial = cell(size(data.trial));
        for k = 1:numel(data.trial)
            newtrial{k} = zeros(numel(label), size(data.trial{k},2));
            newtrial{k}(notmissing,:) = data.trial{k};
        end
        goodchans = false(numel(label),1);
        goodchans(notmissing) = true;
        badchanindx = find(goodchans==0);

        data.trial = newtrial;
        data.label = label;

        % determine neighbors of channels 
        cfg = [];
        cfg.channel = data.label;
        cfg.method = 'triangulation';
        cfg.showcallinfo = 'no';
        neighbours = ft_prepare_neighbours(cfg, data);  

        % repair removed channels
        cfg = [];
        cfg.badchannel = data.label(badchanindx);
        cfg.neighbours = neighbours;
        cfg.showcallinfo = 'no';
        data = ft_channelrepair(cfg, data);

        %% take all the trials as one timeseries

        sensordata = transpose(cell2mat(data.trial));
        fs = data.fsample;
        nchannels = size(sensordata, 2);
       
        %% filter in to a specific frequency band
        
        sensordata_filt = apply_filter(sensordata, fbandname, fband, fs);

        %% compute connectivity using the metrics defined above
            
        fprintf(sprintf("Computing connectivity for subject=%s\n", subj_id));
    
        for m = 1:n_methods
            conn = compute_connectivity(methods(m), sensordata_filt, nchannels, fs);
            
            mkdir(fullfile(savepath,  methods{m}, fbandname, subj_id));
            dlmwrite(fullfile(savepath,  methods{m}, fbandname, subj_id, sprintf("%s_%d.txt", subj_id, restin)), conn);
        end
        
    end
end