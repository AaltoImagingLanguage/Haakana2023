%% computes sensor level power spectra

clc; clear;

datapath = "/scratch/shareddata/set1/HCP-MEG/meg_extracted"; % path to the HCP data
savepath = "../../../data/statistic/spectra/sensor/";

addpath '../../toolboxes/fieldtrip-20210114'; % fieldtrip is used for interpolating missing channels
ft_defaults

%% get HCP subject ids

subjects = dlmread("../../../data/hcp_subject_ids.txt");
nsubj = numel(subjects);

%% frequency intervals for averaging power spectra

fbands = dlmread("../../../data/mean_spectra_freqs.txt");
nbands = size(fbands, 1);

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
        
        %% compute power spectra
              
        [pxx, f] = pwelch(sensordata, [], [], [], fs);

        % average over the frequency ranges
        spectra_mean = zeros(nbands, nchannels);
        for b = 1:nbands
            s = fbands(b, :);
            ids = find(f > s(1) & f <= s(2)); % ids that are in the current frequency interval
            tmp = pxx(ids, :);
            spectra_mean(b, :) = mean(tmp,1);  % take the mean power of the frequency interval
        end

        mkdir(fullfile(savepath, subj_id));
        dlmwrite(fullfile(savepath, subj_id, sprintf('%s_%d.txt', subj_id, restin)), spectra_mean);

        
    end
end