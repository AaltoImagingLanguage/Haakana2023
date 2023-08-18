%% plot accuracies of different FC metrics in correlation-based identification as bar plot

clc; clear;

datapath = "../../../results/correlations/correlation_acc/HCP/Restin/source/connectivity/";

method_labels = ["cAECp", "PLI", "PLM", "AEC", "PLV"];
methods = ["aec_ortho_pair", "pli", "plm", "aec", "plv"];
nmethods = numel(methods);

fband_labels = ["Delta (1-4 Hz)", "Theta (4-8 Hz)", "Alpha (8-13 Hz)", "Beta (13-30 Hz)", "Gamma (30-50 Hz)"];
fbands = ["delta", "theta", "alpha", "beta", "gamma"];
nbands = numel(fbands);

% measurement sessions that are compared
s1 = [3,3];
s2 = [4,5];
n_s = numel(s1);

acc = zeros(nmethods, nbands, n_s);
for sessions = 1:n_s
    for method = 1:nmethods
        for band = 1:nbands
            acc(method, band, sessions) = dlmread(fullfile(datapath, methods(method), fbands(band), sprintf("acc_%d_%d.txt", s1(sessions), s2(sessions))));
         end
    end
end
acc_mean = mean(acc,3);
acc = acc_mean;


width = 0.15;
xpos = 1:nmethods;

c_edge = [0 0 0];
c1 = [0 0.4470 0.7410];
c2 = [0.8500 0.3250 0.0980];
c3 = [0.9290 0.6940 0.1250];
c4 = [0.4940 0.1840 0.5560];
c5 = [0.4660 0.6740 0.1880];
c6 = [0.6350 0.0780 0.1840];

f = figure;
f.Position = [200 100 1200 600];

bar(xpos-width*2, acc(:, 1), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c1);
hold on;
bar(xpos-width, acc(:, 2), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c2);
hold on;
bar(xpos, acc(:, 3), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c3);
hold on;
bar(xpos+width, acc(:, 4), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c4);
hold on;
bar(xpos+width*2, acc(:, 5), 'BarWidth', width, 'EdgeColor', c_edge, 'FaceColor', c5);
hold on


xticks(xpos);
xticklabels(method_labels);
xlim([0.4 5.6]);
h = gca; 
h.XAxis.TickLength = [0 0];

yticks([0, 20, 40, 60, 80, 100]);
ylim([0 101]);
ylabel('Accuracy (%)', 'FontSize', 24);

a = get(gca, 'XTickLabel');  
set(gca, 'XTickLabel', a, 'fontsize', 24)
b = get(gca, 'YTickLabel');  
set(gca,'YTickLabel', b, 'fontsize', 24)
   
legend(fband_labels, 'Location', 'SouthEast', 'FontSize', 22);

set(gca, 'YGrid', 'on', 'XGrid', 'off');

title('Correlation-based identification')
