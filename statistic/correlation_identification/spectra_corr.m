%% correlation-based fingerprinting with power spectra

% computes correlations between power spectra from different measurement sessions across all the subjecs 
% and calculates identification accuracy based on the correlation values

clc; clear;

datapath = "../../../data/statistic/spectra/HCP/source/";
savepath_acc = "../../../results/correlations/correlation_acc/HCP/Restin/source/spectra/";
savepath_corr = "../../../results/correlations/correlation_values/HCP/Restin/source/spectra/";

subjects = dlmread("../../../data/hcp_subject_ids_restin.txt");
nsubj = numel(subjects);


% measurement sessions that are compared (3-5; 3-Restin, 4-Restin, 5-Restin)
s1 = [3,4];
s2 = [4,5];
n_sessions = numel(s1);

correlations = zeros(nsubj,nsubj);
accuracy = 0;


% loops through the measurement session pairs
for sessions = 1:n_sessions
    target_session = s1(sessions);
    test_session = s2(sessions);

    for target_subj = 1:nsubj
        target_id = subjects(target_subj);
        target = dlmread(fullfile(datapath, sprintf("%d", target_id), sprintf("%d_%d.txt", target_id, target_session)));  

        % loops through the subjects and calculates the correlation between their FC
        for test_subj = 1:nsubj
            test_id = subjects(test_subj);
            test = dlmread(fullfile(datapath, sprintf("%d", test_id), sprintf("%d_%d.txt", test_id, test_session)));  

            if target_subj == test_subj && target_session == test_session
                correlations(test_subj, target_subj) = 1;
            else
                correlations(test_subj, target_subj) = setdiff(unique(corrcoef(target, test)), 1);
            end
    
        end
    
        % calculates identification accuracy of the correlation-based fingerprinting:
        % if the highest correlation between measurement sessions is from the same subject, identification is considered successful
        [~, id] = max(correlations(:, target_subj));
        if id == target_subj
           accuracy = accuracy + 1;
        end
    
    end
    
    % divides the number of correctly classified subjects by the total number of subjects
    accuracy = accuracy / nsubj * 100;
    
    dlmwrite(fullfile(savepath_acc, sprintf("acc_%d_%d.txt", target_session, test_session)), accuracy);
    dlmwrite(fullfile(savepath_corr, sprintf("corr_%d_%d.txt", target_session, test_session)), correlations);

end