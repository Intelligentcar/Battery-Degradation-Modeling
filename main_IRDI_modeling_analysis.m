%% 
clear
clc

% func_path = ''; % file_path
% cd(func_path)
load('Data_Traveling_rec.mat')
load('Data_CTC_rec.mat')
load('Data_Dist_rec.mat')
%% Data pre-processing
ana_df_temp = trveling_rec; 

ana_df_temp(:,21) = Rec(:,2);
ana_df_temp(:,22) = Rec(:,3);
ana_df_temp(:,24) = Dist_Rec(:,2);
ana_df_temp(:,25) = Dist_Rec(:,3);

%%
ana_idx_temp = ana_df_temp(:,18) < 0.5 & ana_df_temp(:,21) < ana_df_temp(:,22) & ...
          (ana_df_temp(:,25) - ana_df_temp(:,24)) > 0 & ...
          ana_df_temp(:,19) > 0.8;

ana_df = ana_df_temp(ana_idx_temp,:);
%% Data input variable organization
% Traveled distance
temp_dist = ana_df(:,25)-ana_df(:,24);
temp_cycle = (ana_df(:,22)-ana_df(:,21)); 

% Internal Resistance
AIE = (ana_df(:,18));
a = ana_df(:,26);b = ana_df(:,27);c = ana_df(:,28);

IR5 = a.*exp(-b*5)+c;IR10 = a.*exp(-b*10)+c;
IR15 = a.*exp(-b*15)+c;IR20 = a.*exp(-b*20)+c;
IR25 = a.*exp(-b*25)+c;IR30 = a.*exp(-b*30)+c;
IR35 = a.*exp(-b*35)+c;

mean_IR = (IR5+IR10+IR15+IR20+IR25+IR30+IR35)/7;
%% lme 
% mean(dch_bc) mean(ch_bc) ... %3
% mean(a2_SOC) mean(a2_BT) ... %5
% mean(a2_aux) mean(acc_trq) ... %7
% mean(dec_trq) mean(SP) ... %9
% vel_met acc_met dec_met ... %12
% dbc_met cbc_met bt_met ... %15
% soc_met aux_met Fit5.d ... %18
% gof5.adjrsquare target_cap CTC %21


tbl = table((ana_df(:,18)), ana_df(:,1), ana_df(:,2),... % .*ana_df(:,20)
        ana_df(:,3),ana_df(:,4),ana_df(:,5),ana_df(:,6),... %7
        ana_df(:,7),ana_df(:,8),ana_df(:,9),... % 11
        log((ana_df(:,22)+ana_df(:,21))/2),... % CTC_age
        log(temp_cycle./temp_dist),temp_dist,... % 
        temp_dist./temp_cycle,temp_cycle, mean_IR,...
        'VariableNames',{'AIE','idx','mean_dch','mean_ch', ...
        'mean_SOC','mean_BT','mean_AUX','mean_PKE','mean_NKE',...
        'mean_SP', 'CTC_age', 'cyc_km','temp_dist',...
        'km_cyc','temp_cycle','mean_IR'});

%% unit_dist : distance/cycle
tbl_target = tbl;%(Niro_idx,:);

%% PCC & VIF test Table 1
% PCC test
corr_target = [tbl_target.AIE, tbl_target.mean_dch, ...
               tbl_target.mean_ch, tbl_target.mean_BT,...
               tbl_target.mean_SOC, tbl_target.mean_IR, ...
               tbl_target.cyc_km, tbl_target.CTC_age, ...
               tbl_target.mean_SP];

corr_result = corr(corr_target);
% VIF test
% X = corr_target(:,2:end); % VIF 1st
% X = corr_target(:,3:end); % VIF 2nd
X = corr_target(:,4:end); % VIF 3rd 
R0 = corrcoef(X); % correlation matrix
V=diag(inv(R0))'

%% Table 2 stepwise regression-based modeling result

y = tbl_target.AIE; 
X = corr_target(:,4:end); %[tbl(:,3:6) tbl(:,8:10) tbl(:,20:31) tbl(:,37)]; % [corr_target(:,2:4) corr_target(:,6:9)];%

mdl = stepwiselm(X, y, 'Upper','poly111111', 'PEnter', 0.05);

%% Correlation Figure 5
% ana_df 
% mean(dch_bc) mean(ch_bc) ... %3
% mean(a2_SOC) mean(a2_BT) ... %5
% mean(a2_aux) mean(acc_trq) ... %7
% mean(dec_trq) mean(SP) ... %9
% vel_met acc_met dec_met ... %12
% dbc_met cbc_met bt_met ... %15
% soc_met aux_met Fit5.d ... %18
% gof5.adjrsquare target_cap CTC %21

NCC_ini = ana_df(:,21);
Used_NCC = ana_df(:,22)-ana_df(:,21);
Used_dist = ana_df(:,25)-ana_df(:,24);
Thput_age = log((ana_df(:,22)+ana_df(:,21))/2); % CTC_age
Thput_intensity = log(Used_NCC./Used_dist); % 

target_param_df = [AIE tbl_target.mean_IR Used_NCC Thput_intensity ...
                   Thput_age ana_df(:,2:5) ...
                   ana_df(:,9) ana_df(:,25)-ana_df(:,24)];

r = corr(target_param_df);

% Replace upper triangle with NaNs
isupper = logical(triu(ones(size(r)),1));
r(isupper) = NaN;

close
% Plot results
f = figure(10);
f.Position(3) = 1200;
f.Position(4) = 400;

h = heatmap(r,'MissingDataColor','w','Colormap',pink);

labels = {"$z$", "$\overline{IR}$", "$NCC_{used}$","$\sigma_{NCC}$",...
          "$\gamma_{NCC}$", '$\overline{C}_{pos}$',...
          '$\overline{C}_{neg}$',...
          '$\overline{SoC}$','$\overline{T}$',...
          '$\overline{v}$', '$d_{used}$'};

h.XDisplayLabels = labels;
h.YDisplayLabels = labels; 


%
s = struct(h);
ax = s.Axes;
ax.XAxis.TickLabelInterpreter = 'latex';
ax.YAxis.TickLabelInterpreter = 'latex';

set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
% cd 'save_path'
% exportgraphics(h, "Fig_corr_plot.pdf") ;

%% Figure 6
close all
Ioniq_idx = ana_df(:,20)==78; 
Niro_idx = ana_df(:,20)==180;
f = figure(4);
hold on
plot(mean_IR(Ioniq_idx),(AIE(Ioniq_idx)),'square',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)
plot(mean_IR(Niro_idx),(AIE(Niro_idx)),'o',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)

hold off
legend('Ioniq EV','Niro & Kona EV')
title(['PCC: ' num2str(round(corr(AIE, mean_IR),3))])
xlabel('$\overline{IR}$', 'Interpreter', 'latex')
ylabel('$z$', 'Interpreter', 'latex')


% f.XDisplayLabels = labels;
% f.YDisplayLabels = labels; 
% s = struct(f);
% ax = s.Axes;
% ax.XAxis.TickLabelInterpreter = 'latex';
% ax.YAxis.TickLabelInterpreter = 'latex';

set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
% cd 'save path'
% exportgraphics(f, "Fig_IR_VS_BAI.pdf") ;

f = figure(5);
hold on
plot(tbl.cyc_km(Ioniq_idx),(AIE(Ioniq_idx)),'square',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)
plot(tbl.cyc_km(Niro_idx),(AIE(Niro_idx)),'o',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)
hold off
legend('Ioniq EV','Niro & Kona EV','Location','southeast')
title(['PCC: ' num2str(round(corr(AIE, tbl.cyc_km),3))])
% legend('5 ^oC','10 ^oC','15 ^oC','20 ^oC',...
%        '25 ^oC', '30 ^oC', '35 ^oC','Location','northeast')
% legend('HIC5','HIC15','HIC25','HIC35','Location','northwest')
% legend('HIC5','HIC10','HIC15','HIC20','HIC25','HIC30','HIC35','Location','northwest')
xlabel('$\sigma_{NCC}$', 'Interpreter', 'latex')
ylabel('$z$', 'Interpreter', 'latex')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
% exportgraphics(f, "Fig_Thput_VS_BAI.pdf") ;

%% Figure 7
f = figure(7);
hold on
plot(tbl.temp_cycle(Ioniq_idx),tbl.temp_dist(Ioniq_idx),'square',...
    'MarkerEdgeColor',[0.64 0.08 0.18],'MarkerSize',10, 'LineWidth',2)
plot(tbl.temp_cycle(Niro_idx),tbl.temp_dist(Niro_idx),'o',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)
hold off
legend('Ioniq EV','Niro & Kona EV','Location','southeast')
xlabel('$NCC_{used}$', 'Interpreter', 'latex')
ylabel('$d_{used}$', 'Interpreter', 'latex')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
% exportgraphics(f, "Fig_NCC_VS_Dist.pdf") ;

f = figure(8);
hold on
plot(tbl.temp_cycle(Ioniq_idx),tbl.cyc_km(Ioniq_idx),'square',...
    'MarkerEdgeColor',[0.64 0.08 0.18],'MarkerSize',10, 'LineWidth',2)
plot(tbl.temp_cycle(Niro_idx),tbl.cyc_km(Niro_idx),'o',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)
hold off
legend('Ioniq EV','Niro & Kona EV','Location','southeast')
xlabel('$NCC_{used}$', 'Interpreter', 'latex')
ylabel('$\sigma_{NCC}$', 'Interpreter', 'latex')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
% exportgraphics(f, "Fig_NCC_VS_Thput.pdf") ;

f = figure(9);
hold on
plot(tbl.temp_dist(Ioniq_idx),tbl.cyc_km(Ioniq_idx),'square',...
    'MarkerEdgeColor',[0.64 0.08 0.18],'MarkerSize',10, 'LineWidth',2)
plot(tbl.temp_dist(Niro_idx),tbl.cyc_km(Niro_idx),'o',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)
hold off
legend('Ioniq EV','Niro & Kona EV','Location','southeast')
xlabel('$d_{used}$', 'Interpreter', 'latex')
ylabel('$\sigma_{NCC}$', 'Interpreter', 'latex')
% zlabel('$z$', 'Interpreter', 'latex')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
% exportgraphics(f, "Fig_Dist_VS_Thput.pdf") ;
%% PCA Table 3

tbl_mat = [tbl.mean_IR, tbl.cyc_km, tbl.mean_SP, tbl.CTC_age];% [tbl.mean_IR, tbl.cyc_km, tbl.CTC_age, tbl.mean_SP];

[coeff,score,latent,tsquared,explained] = pca(normalize(tbl_mat));

%% stepwise Table 4
lme =fitlme(tbl,['AIE~CTC_age']); % 1
% lme =fitlme(tbl,['AIE~mean_SP']); % 2
% lme =fitlme(tbl,['AIE~cyc_km']); % 3
% lme =fitlme(tbl,['AIE~mean_IR']); % 4
% lme =fitlme(tbl_target,['AIE~mean_IR+CTC_age']); % 5
% lme =fitlme(tbl_target,['AIE~mean_IR+mean_SP']); % 6
% lme =fitlme(tbl_target,['AIE~mean_IR+cyc_km']); % 7
% lme =fitlme(tbl_target,['AIE~mean_IR+cyc_km+mean_SP']); % 8
% lme =fitlme(tbl_target,['AIE~mean_IR+cyc_km+CTC_age']); % 9
% 
lme
lme.Rsquared