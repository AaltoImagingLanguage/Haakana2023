%% plots brrr model accuracy as bar plot

clc; clear;

datapath = "../../../../results/brrr/brrr_accuracy/connectivity/source/";


method_labels = ["cAECs"; "cAECp"; "iCoh"; "iPLV"; "PLI"; "wPLI"; "PLM"; "AEC"; "Coh"; "PLV"]; 
methods = ["aec_ortho_sym"; "aec_ortho_pair"; "icoh"; "iplv"; "pli"; "wpli"; "plm"; "aec"; "coh"; "plv"];
nmethods = numel(methods);

fband_labels = ["Delta (1-4 Hz)", "Theta (4-8 Hz)", "Alpha (8-13 Hz)", "Beta (13-30 Hz)", "Gamma (30-50 Hz)"];
fbands = ["delta", "theta", "alpha", "beta", "gamma"];
nbands = numel(fbands);

K_list = [20]; % the number of the latent components of the model
n_K = numel(K_list);

training_session = 3; % measurement session used in training the model

for K_ind = 1:n_K

    acc = zeros(nmethods, nbands);

    for method = 1:nmethods
        for band = 1:nbands        
            acc(method,band) = dlmread(fullfile(datapath, methods(method), fbands(band), sprintf("K%d_%d.txt", K_list(K_ind), training_session)));
         end
    end

    K = K_list(K_ind);

    f = figure;
    f.Position = [200 100 1200 600];

       
    width = 0.15;
    xpos = 1:nmethods;

    color_edge = [0 0 0];
    c1 = [0 0.4470 0.7410];
    c2 = [0.8500 0.3250 0.0980];
    c3 = [0.9290 0.6940 0.1250];
    c4 = [0.4940 0.1840 0.5560];
    c5 = [0.4660 0.6740 0.1880];
    c6 = [0.6350 0.0780 0.1840];


    bar(xpos-width*2, acc(:, 1), 'BarWidth', width, ...
        'EdgeColor', color_edge, 'FaceColor', c1);
    hold on;
    bar(xpos-width, acc(:, 2), 'BarWidth', width, ...
        'EdgeColor', color_edge, 'FaceColor', c2);
    hold on;
    bar(xpos, acc(:, 3), 'BarWidth', width, ...
        'EdgeColor', color_edge, 'FaceColor', c3);
    hold on;
    bar(xpos+width, acc(:, 4), 'BarWidth', width, ...
        'EdgeColor', color_edge, 'FaceColor', c4);
    hold on;
    bar(xpos+width*2, acc(:, 5), 'BarWidth', width, ...
        'EdgeColor', color_edge, 'FaceColor', c5);
    hold on

    xticks(xpos);
    xticklabels(method_labels);
    xlim([0.4 10.6]);
    h = gca; 
    h.XAxis.TickLength = [0 0];
    
    yticks([0, 20, 40, 60, 80, 100]);
    ylim([0 100]);
    ylabel('Accuracy (%)', 'FontSize', 24);
    

    a = get(gca, 'XTickLabel');  
    set(gca, 'XTickLabel', a, 'fontsize', 24)
    b = get(gca, 'YTickLabel');  
    set(gca,'YTickLabel', b, 'fontsize', 24)
    

    legend(fband_labels, 'Location', 'SouthEast', 'FontSize', 22);

        
    set(gca, 'YGrid', 'on', 'XGrid', 'off');
    


end
