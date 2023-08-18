%% plot mantel test correlations between methods

clc; clear;

training_session = [3];
n_rs = numel(training_session);

space = "source";

fband_labels = ["Delta (1-4 Hz)"; "Theta (4-8 Hz)"; "Alpha (8-13 Hz)"; "Beta (13-30 Hz)"; "Gamma (30-50 Hz)"];
fbands = ["delta"; "theta"; "alpha"; "beta"; "gamma"];
nbands = numel(fbands);

method_labels = ["cAECs"; "cAECp"; "iCoh"; "iPLV"; "PLI"; "wPLI"; "PLM"; "AEC"; "Coh"; "PLV"]; 
methods = ["aec_ortho_sym"; "aec_ortho_pair"; "icoh"; "iplv"; "pli"; "wpli"; "plm"; "aec"; "coh"; "plv"];
n_methods = numel(methods);
fig_ticks = 1:n_methods;

K = 20;


datapath =  sprintf("../../../../results/mantel_test/mantel_test_methods/%s/", space);

correlations = zeros(n_methods, n_methods, nbands, n_rs);
for band = 1:nbands
    
    for rs = 1:n_rs

        correlations(:,:,band,rs) = dlmread(fullfile(datapath, sprintf("corr_K%d_%s_%d.txt", K, fbands(band), training_session(rs))));
        correlations_temp = correlations(:,:,band,rs);

        idx = tril(correlations_temp);
        correlations_temp(~idx) = nan;

        figure;
        h = imagesc(correlations_temp);
        set(h, 'AlphaData', ~isnan(correlations_temp));
    
        caxis([0 1]);        
        colormap(flipud(summer));
    
        xticks(fig_ticks);
        xticklabels(method_labels);
        yticks(fig_ticks);
        yticklabels(method_labels);
        
        a = get(gca, 'XTickLabel');  
        set(gca, 'XTickLabel', a, 'fontsize', 15)
        b = get(gca, 'YTickLabel');  
        set(gca,'YTickLabel', b, 'fontsize', 15)
    
        title(sprintf("%s", fband_labels(band)), 'FontSize', 16);
    
        xtickangle(45);

    end
end

%% plot mantel test correlations between resting-state sessions

clc; clear; close all;

space = "source";

fband_labels = ["Delta (1-4 Hz)"; "Theta (4-8 Hz)"; "Alpha (8-13 Hz)"; "Beta (13-30 Hz)"; "Gamma (30-50 Hz)"];
fbands = ["delta"; "theta"; "alpha"; "beta"; "gamma"];
nbands = numel(fbands);

method_labels = ["cAECs"; "cAECp"; "iCoh"; "iPLV"; "PLI"; "wPLI"; "PLM"; "AEC"; "Coh"; "PLV"]; 
methods = ["aec_ortho_sym"; "aec_ortho_pair"; "icoh"; "iplv"; "pli"; "wpli"; "plm"; "aec"; "coh"; "plv"];
n_methods = numel(methods);

K = 20;

labels = ["3-Restin","4-Restin","5-Restin"];
n_rs = numel(labels);
fig_ticks = 1:n_rs;


datapath =  fullfile("../../../../results/mantel_test/mantel_test_sessions/connectivity/", space);

correlations = zeros(n_rs, n_rs, nbands, n_methods);
for method = 1:n_methods
    for band = 1:nbands
        
        correlations(:,:, band, method) = dlmread(fullfile(datapath, sprintf("corr_K%d_%s_%s.txt", K, methods(method), fbands(band))));
        correlations_temp = correlations(:,:,band,method);


        idx = tril(correlations_temp);
        correlations_temp(~idx) = nan;

        figure;
        h = imagesc(correlations_temp);
        set(h, 'AlphaData', ~isnan(correlations_temp));
    
        caxis([0.75 1]);
        colormap(flipud(summer));

        xticks(fig_ticks);
        xticklabels(labels);
        yticks(fig_ticks);
        yticklabels(labels);
        
        a = get(gca, 'XTickLabel');  
        set(gca, 'XTickLabel', a, 'fontsize', 17)
        b = get(gca, 'YTickLabel');  
        set(gca,'YTickLabel', b, 'fontsize', 17)

        x = repmat(1:n_rs, n_rs, 1); % generate x-coordinates
        y = x'; % generate y-coordinates
        % Generate Labels
        corr_temp = round(correlations_temp, 2);
        corr_temp = tril(corr_temp);
        corr_temp(corr_temp==1) = 0;
        corr_temp(corr_temp==0) = "";
        t = num2cell(corr_temp); % extact values into cells
        t(cellfun(@isnan,t)) = {""};
        t = cellfun(@num2str, t, 'UniformOutput', false); % convert to string
        % Draw Image and Label Pixels
        text(x(:), y(:), t, 'HorizontalAlignment', 'Center', 'Color', 'black','FontSize', 17)
        

        title(sprintf("%s", fband_labels(band)), 'FontSize', 16);
        
    end

end

%% plot mantel test correlations between fbands

clc; clear; close all;

training_session = [3];
n_rs = numel(training_session);

space = "source";

fband_labels = ["Delta"; "Theta"; "Alpha"; "Beta"; "Gamma"];
fbands = ["delta"; "theta"; "alpha"; "beta"; "gamma"];
nbands = numel(fbands);
fig_ticks = 1:nbands;

method_labels = ["cAECs"; "cAECp"; "iCoh"; "iPLV"; "PLI"; "wPLI"; "PLM"; "AEC"; "Coh"; "PLV"]; 
methods = ["aec_ortho_sym"; "aec_ortho_pair"; "icoh"; "iplv"; "pli"; "wpli"; "plm"; "aec"; "coh"; "plv"];
n_methods = numel(methods);

K = 20;


datapath =  sprintf("../../../../results/mantel_test/mantel_test_fbands/%s/", space);

correlations = zeros(nbands, nbands, n_methods, n_rs);
for method = 1:n_methods

    for rs = 1:n_rs

        correlations(:,:, method, rs) = dlmread(fullfile(datapath, sprintf("corr_K%d_%s_%d.txt", K, methods(method), training_session(rs))));

        correlations_temp = correlations(:,:,method,rs);

        idx = tril(correlations_temp);
        correlations_temp(~idx) = nan;

        figure;
        h = imagesc(correlations_temp);
        set(h, 'AlphaData', ~isnan(correlations_temp));
    
        caxis([0 1]);
        colormap(flipud(summer));
    
        xticks(fig_ticks);
        xticklabels(fband_labels);
        yticks(fig_ticks);
        yticklabels(fband_labels);
        
        a = get(gca, 'XTickLabel');  
        set(gca, 'XTickLabel', a, 'fontsize', 17)
        b = get(gca, 'YTickLabel');  
        set(gca,'YTickLabel', b, 'fontsize', 17)
    
        x = repmat(1:nbands, nbands, 1); % generate x-coordinates
        y = x'; % generate y-coordinates
        % Generate Labels
        corr_temp = round(correlations_temp, 2);
        corr_temp = tril(corr_temp);
        corr_temp(corr_temp==1) = 0;
        corr_temp(corr_temp==0) = "";
        t = num2cell(corr_temp); % extact values into cells
        t(cellfun(@isnan,t)) = {""};
        t = cellfun(@num2str, t, 'UniformOutput', false); % convert to string
        % Draw Image and Label Pixels
        text(x(:), y(:), t, 'HorizontalAlignment', 'Center', 'Color', 'black','FontSize', 14)
    
        title(sprintf("%s", method_labels(method)), 'FontSize', 16);
    
    end
end

%% plot mantel test correlations between components

clc; clear; close all;

space = "source";

fband_labels = ["Delta (1-4 Hz)"; "Theta (4-8 Hz)"; "Alpha (8-13 Hz)"; "Beta (13-30 Hz)"; "Gamma (30-50 Hz)"];
fbands = ["delta"; "theta"; "alpha"; "beta"; "gamma"];
nbands = numel(fbands);

methods = ["aec_ortho_sym"; "aec_ortho_pair"; "icoh"; "iplv"; "pli"; "wpli"; "plm"; "aec"; "coh"; "plv"];
n_methods = numel(methods);

K_labels = ["K=2","K=6","K=10","K=20","K=50","K=80"];
n_K = numel(K_labels);
fig_ticks = 1:n_K;

training_session = [3];
n_rs = numel(training_session);


datapath =  sprintf("../../../../results/mantel_test/mantel_test_components/connectivity/%s/", space);

correlations = zeros(n_K, n_K, nbands, n_rs);
for method = 1:n_methods
    for band = 1:nbands
        for rs = 1:n_rs
    
            correlations(:,:,band,method,rs) = dlmread(fullfile(datapath, sprintf('corr_%s_%s_%d.txt', methods(method), fbands(band), training_session(rs))));
            correlations_temp = correlations(:,:,band,method,rs);
    
            idx = tril(correlations_temp);
            correlations_temp(~idx) = nan;

            figure;
            h = imagesc(correlations_temp);
            set(h, 'AlphaData', ~isnan(correlations_temp));
            
            caxis([0.5 1]);
            colormap(flipud(summer));
    
            xticks(fig_ticks);
            xticklabels(K_labels);
            yticks(fig_ticks);
            yticklabels(K_labels);
            
            a = get(gca, 'XTickLabel');  
            set(gca, 'XTickLabel', a, 'fontsize', 17)
            b = get(gca, 'YTickLabel');  
            set(gca,'YTickLabel', b, 'fontsize', 17)
    
            x = repmat(1:n_K, n_K, 1); % generate x-coordinates
            y = x'; % generate y-coordinates
            % Generate Labels
            corr_temp = round(correlations_temp, 2);
            corr_temp = tril(corr_temp);
            corr_temp(corr_temp==1) = 0;
            corr_temp(corr_temp==0) = "";
            t = num2cell(corr_temp); % extact values into cells
            t(cellfun(@isnan,t)) = {""};
            t = cellfun(@num2str, t, 'UniformOutput', false); % convert to string
            % Draw Image and Label Pixels
            text(x(:), y(:), t, 'HorizontalAlignment', 'Center', 'Color', 'black','FontSize', 15)
    
            title(sprintf("%s", fband_labels(band)), 'FontSize', 17);

        end
    
    end
end


%% plot mantel test correlations between sensor and source space

clc; clear;

datapath = "../../../../results/mantel_test/mantel_test_space/connectivity/";

method_labels = ["cAECs"; "cAECp"; "iCoh"; "iPLV"; "PLI"; "wPLI"; "cPLM"; "AEC"; "Coh"; "PLV"]; 
methods = ["aec_ortho_sym"; "aec_ortho_pair"; "icoh"; "iplv"; "pli"; "wpli"; "plm"; "aec"; "coh"; "plv"];
nmethods = numel(methods);

fband_labels = ["Delta (1-4 Hz)", "Theta (4-8 Hz)", "Alpha (8-13 Hz)", "Beta (13-30 Hz)", "Gamma (30-50 Hz)"];
fbands = ["delta", "theta", "alpha", "beta", "gamma"];
nbands = numel(fbands);

restin = 3;

K = 20;         

corr = zeros(nmethods, nbands);
for method = 1:nmethods
    for band = 1:nbands 
        corr(method, band) = dlmread(fullfile(datapath, sprintf("corr_K%d_%s_%s_%d.txt", K, methods(method), fbands(band), restin)));
     end
end

f = figure;
f.Position = [200 100 1200 600];

width = 0.15;
xpos = 1:nmethods;

c_edge = [0 0 0];
c_theta = [0 0.4470 0.7410];
c_delta = [0.8500 0.3250 0.0980];
c_alpha = [0.9290 0.6940 0.1250];
c_beta = [0.4940 0.1840 0.5560];
c_gamma = [0.4660 0.6740 0.1880];
c_h_gamma = [0.3010 0.7450 0.9330];

bar(xpos-width*2, corr(:, 1), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c_theta);
hold on;
bar(xpos-width, corr(:, 2), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c_delta);
hold on;
bar(xpos, corr(:, 3), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c_alpha);
hold on;
bar(xpos+width, corr(:, 4), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c_beta);
hold on;
bar(xpos+width*2, corr(:, 5), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c_gamma);
hold on


xticks(xpos);
xticklabels(method_labels);
xlim([0.4 10.6]);
h = gca; 
h.XAxis.TickLength = [0 0];

yticks([0, 0.2, 0.4, 0.6, 0.8, 1.0]);
ylim([0 1]);
ylabel('Correlation', 'FontSize', 24);

a = get(gca, 'XTickLabel');  
set(gca, 'XTickLabel', a, 'fontsize', 24)
b = get(gca, 'YTickLabel');  
set(gca,'YTickLabel', b, 'fontsize', 24)

lgd = legend(fband_labels, 'Position', [0.35 0.7 0.2 0.2], 'FontSize', 22);

set(gca, 'YGrid', 'on', 'XGrid', 'off');

