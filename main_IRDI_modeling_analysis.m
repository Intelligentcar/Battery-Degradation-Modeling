%% 
clear
clc

func_path = ''; % file_path
cd(func_path)
load('Data_Traveling_rec.mat')
load('Data_CTC_rec.mat')
load('Data_Dist_rec.mat')
%% Data pre-processing
ana_df_temp = trveling_rec; 

ana_df_temp(:,21) = Rec(:,2);
ana_df_temp(:,22) = Rec(:,3);
ana_df_temp(:,24) = Dist_Rec(:,2);
ana_df_temp(:,25) = Dist_Rec(:,3);

%% AIE
ana_df_temp(52,18) = 0.1251;
ana_df_temp(52,19) = 0.9508;
% abc

ana_df_temp(52,27) = 0.0628;
ana_df_temp(52,28) = 0.0071;
% ana_df_temp(52,28) = 0.1251;
% distance % km
ana_df_temp(12,24) = 112457;ana_df_temp(12,25) = 149296;
ana_df_temp(15,24) = 84923;ana_df_temp(15,25) = 108822;
ana_df_temp(16,24) = 61522;ana_df_temp(16,25) = 71539;
% NCC
ana_df_temp(12,21) = 722.488;ana_df_temp(12,22) = 959.128;
ana_df_temp(15,21) = 416.65;ana_df_temp(15,22) = 599.292;
ana_df_temp(16,21) = 216.612;%530.965;
ana_df_temp(16,22) = 255.579;%660.307;
%%
prev_ana_df = load('A6_EV54_traveling_rec_interval_accum_250716.mat');
ana_df_temp_prev = prev_ana_df.trveling_rec;
ana_idx = 4:4:216;
ana_df_temp_prev_GoF = ana_df_temp_prev(ana_idx,19); 
ana_df_temp_prev_z = ana_df_temp_prev(ana_idx,18); 

ana_df_temp(:,19) = ana_df_temp_prev_GoF;
ana_df_temp(:,18) = ana_df_temp_prev_z;
%%


ana_idx_temp = ana_df_temp(:,18) < 0.5 & ana_df_temp(:,21) < ana_df_temp(:,22) & ...
          (ana_df_temp(:,25) - ana_df_temp(:,24)) > 0 & ...
          ana_df_temp(:,19) > 0.8;

ana_df = ana_df_temp(ana_idx_temp,:);
%%
bar(ana_df_temp(:,19))
%%
len = size(ana_df,1);
temp_BT = zeros(len,1);
idx_BT4 = ana_df(:,5) > 30;
idx_BT3 = ana_df(:,5) <= 30 & ana_df(:,5) > 20;%idx_BT5 = ana_df(:,5) <= 25 & ana_df(:,5) > 20;
idx_BT2 = ana_df(:,5) <= 20 & ana_df(:,5) > 10;%idx_BT3 = ana_df(:,5) <= 15 & ana_df(:,5) > 10;
idx_BT1 = ana_df(:,5) <= 10;%idx_BT1 = ana_df(:,5) <= 5;

temp_BT(idx_BT4) = 4; % btw 10-20 oC
temp_BT(idx_BT3) = 3; % under 10oC
temp_BT(idx_BT2) = 2; % btw 10-20 oC
temp_BT(idx_BT1) = 1; % under 10oC

% SoC
temp_SoC = zeros(len,1);
idx_SoC4 = ana_df(:,4) > 60;
idx_SoC3 = ana_df(:,4) <= 60 & ana_df(:,4) > 40;
idx_SoC2 = ana_df(:,4) <= 40 & ana_df(:,4) > 20;
idx_SoC1 = ana_df(:,4) <= 20;

temp_SoC(idx_SoC4) = 4; % 
temp_SoC(idx_SoC3) = 3; %
temp_SoC(idx_SoC2) = 2; %
temp_SoC(idx_SoC1) = 1; % 

% CTC
temp_CTC = zeros(len,1);
idx_CTC4 = (ana_df(:,21)+ana_df(:,22))/2 > 700;
idx_CTC3 = (ana_df(:,21)+ana_df(:,22))/2 <= 700 & (ana_df(:,21)+ana_df(:,22))/2 > 500;
idx_CTC2 = (ana_df(:,21)+ana_df(:,22))/2 <= 500 & (ana_df(:,21)+ana_df(:,22))/2 > 300;
idx_CTC1 = (ana_df(:,21)+ana_df(:,22))/2 <= 300;

temp_CTC(idx_CTC4) = 4; % over 20 oC
temp_CTC(idx_CTC3) = 3; % over 20 oC
temp_CTC(idx_CTC2) = 2; % over 20 oC
temp_CTC(idx_CTC1) = 1; % under 20oC
%% Traveled distance
temp_dist = ana_df(:,25)-ana_df(:,24);
temp_cycle = (ana_df(:,22)-ana_df(:,21)); 

%% HIC 240321
AIE = (ana_df(:,18));
a = ana_df(:,26);
b = ana_df(:,27);
c = ana_df(:,28);
HIC5 = -a.*b.*exp(-b*5);
HIC10 = -a.*b.*exp(-b*10);
HIC15 = -a.*b.*exp(-b*15);
HIC20 = -a.*b.*exp(-b*20);
HIC25 = -a.*b.*exp(-b*25);
HIC30 = -a.*b.*exp(-b*30);
HIC35 = -a.*b.*exp(-b*35);

mean_HIC = (HIC5+HIC10+HIC15+HIC20+HIC25+HIC30+HIC35)/7;

R5 = a.*exp(-b*5)+c;
R10 = a.*exp(-b*10)+c;
R15 = a.*exp(-b*15)+c;
R20 = a.*exp(-b*20)+c;
R25 = a.*exp(-b*25)+c;
R30 = a.*exp(-b*30)+c;
R35 = a.*exp(-b*35)+c;

mean_R = (R5+R10+R15+R20+R25+R30+R35)/7;

IR5 = a.*exp(-b*5)+c;
IR10 = a.*exp(-b*10)+c;
IR15 = a.*exp(-b*15)+c;
IR20 = a.*exp(-b*20)+c;
IR25 = a.*exp(-b*25)+c;
IR30 = a.*exp(-b*30)+c;
IR35 = a.*exp(-b*35)+c;

temp_IR = [IR5 IR10 IR15 IR20 IR25 IR30 IR35];
mean_IR = (IR5+IR10+IR15+IR20+IR25+IR30+IR35)/7;
%%
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
cd 'C:\Users\user\Downloads\박사과정연구\졸업논문_발표자료\졸업논문_Fig'
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

figure(6)
hold on
plot(tbl.mean_ch(Ioniq_idx),(AIE(Ioniq_idx)),'square',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)
plot(tbl.mean_ch(Niro_idx),(AIE(Niro_idx)),'o',...
    'MarkerEdgeColor',[0 0 0],'MarkerSize',10, 'LineWidth',2)
hold off
% xlim([-0.5 0])
legend('Ioniq EV','Niro & Kona EV','Location','southwest')
title(['PCC: ' num2str(round(corr(AIE, tbl.mean_ch),3))])
% legend('5 ^oC','10 ^oC','15 ^oC','20 ^oC',...
%        '25 ^oC', '30 ^oC', '35 ^oC','Location','northeast')
% legend('HIC5','HIC15','HIC25','HIC35','Location','northwest')
% legend('HIC5','HIC10','HIC15','HIC20','HIC25','HIC30','HIC35','Location','northwest')
xlabel('The average of regenerative C-rate')
ylabel('BAI')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
% exportgraphics(f, "Fig_IR_VS_BAI.pdf") ;
%%

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
%%
close all
CTC = (ana_df(:,21)+ana_df(:,22))/2;
figure(5)
hold on
plot(CTC(Ioniq_idx),mean_IR(Ioniq_idx),'*')
plot(CTC(Niro_idx),mean_IR(Niro_idx),'*')

hold off
legend('Ioniq EV','Niro & Kona EV')
% legend('5 ^oC','10 ^oC','15 ^oC','20 ^oC',...
%        '25 ^oC', '30 ^oC', '35 ^oC','Location','northeast')
% legend('HIC5','HIC15','HIC25','HIC35','Location','northwest')
% legend('HIC5','HIC10','HIC15','HIC20','HIC25','HIC30','HIC35','Location','northwest')
ylabel('The average of IR [ohm]')
xlabel('CTC')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)

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
        ana_df(:,7),ana_df(:,8),ana_df(:,9),ana_df(:,10),... % 11
        ana_df(:,11),ana_df(:,12),ana_df(:,13),ana_df(:,14),... % 15
        ana_df(:,15),ana_df(:,16),ana_df(:,17),ana_df(:,20),... % 19
        (temp_cycle)./ana_df(:,23),log((ana_df(:,22)+ana_df(:,21))/2),... % CTC_age
        temp_BT, temp_SoC, temp_CTC,log(temp_cycle./temp_dist),temp_dist,... % 
        temp_dist./temp_cycle,temp_cycle,ana_df(:,23),temp_dist./ana_df(:,23), ...
        log((temp_cycle./temp_dist)./ana_df(:,23)), ...
        R5, R15, R25, R35, mean_R,mean_IR,mean_HIC,...
        'VariableNames',{'AIE','idx','mean_dch','mean_ch', ...
        'mean_SOC','mean_BT','mean_AUX','mean_PKE','mean_NKE',...
        'mean_SP','side_SP','side_PKE','side_NKE','side_prop',...
        'side_regen','side_BT','side_SOC','side_AUX','Cap','CTC_diff', ...
        'CTC_age','BT_level','SoC_level','CTC_level','cyc_km','temp_dist',...
        'km_cyc','temp_cycle','numOftrip','Dist_trip','cyc_km_trip',...
        'R5','R15','R25','R35', 'mean_R','mean_IR','mean_HIC'});
%% unit_dist : distance/cycle
% lme =fitlme(tbl,['AIE~mean_IR+cyc_km_trip+CTC_age']); %+(1|idx:BT_level) candidate 97.42%
% lme =fitlme(tbl,['AIE~mean_IR+cyc_km+CTC_age']); %+(1|idx:BT_level) candidate 97.42%
% lme =fitlme(tbl,['AIE~mean_IR+cyc_km+CTC_age+mean_BT+mean_SOC']); %+(1|idx:BT_level) candidate 97.42%
% lme =fitlme(tbl,['AIE~cyc_km+mean_IR+CTC_age+mean_ch']); %+(1|idx:BT_level) candidate 97.42%

tbl_niro = tbl;%(Niro_idx,:);
% 250817
% lme =fitlme(tbl,['AIE~cyc_km']);
% lme =fitlme(tbl,['AIE~mean_IR']);
lme =fitlme(tbl_niro,['AIE~mean_IR+cyc_km+mean_SP']);

lme
lme.Rsquared
%% PCA
pca([tbl.mean_IR, tbl.cyc_km, ...
     tbl.CTC_age, tbl.mean_SP])
%% stepwise
y = tbl_niro.AIE; 
% X = [corr_target(:,8:9), corr_target(:,2:5)]; %[tbl(:,3:6) tbl(:,8:10) tbl(:,20:31) tbl(:,37)]; % [corr_target(:,2:4) corr_target(:,6:9)];%
% mdl_niro = stepwiselm(X(idx_niro), y(idx_niro), 'PEnter', 0.09);
% mdl_ionq = stepwiselm(X(idx_ionq), y(idx_ionq), 'PEnter', 0.09);

mdl = stepwiselm(X, y, 'Upper','poly111111', 'PEnter', 0.05);

% mdl_niro = stepwiselm(X(idx_niro), y(idx_niro), 'PEnter', 0.05);
% mdl_ionq = stepwiselm(X(idx_ionq), y(idx_ionq), 'PEnter', 0.05);

%% correlation
corr_target = [tbl_niro.AIE, tbl_niro.mean_IR, ...
               tbl_niro.cyc_km, tbl_niro.CTC_age, ...
               tbl_niro.mean_SP, tbl_niro.mean_dch, ...
               tbl_niro.mean_ch, ...
               tbl_niro.mean_BT, tbl_niro.mean_SOC, ...
               tbl_niro.temp_dist, tbl_niro.temp_cycle];

% corr_target = [tbl.AIE, tbl.mean_IR, tbl.cyc_km, ...
%                tbl.CTC_age, ...   
%                tbl.mean_dch, tbl.mean_ch, ...
%                tbl.mean_BT, tbl.mean_SOC];

corr_result = corr(corr_target);
%%
% X = corr_target(:,2:end);
% X = [corr_target(:,7:9), corr_target(:,2) corr_target(:,5)]; % corr_target(:,5)
X = [corr_target(:,8:9), corr_target(:,2:5)]; % corr_target(:,5)
% X = [corr_target(:,5),corr_target(:,7)];
%[corr_target(:,8:9), corr_target(:,2:4)];
R0 = corrcoef(X); % correlation matrix
V=diag(inv(R0))'

corr_result = corr([tbl_niro.AIE X]);
%%
figure(1)
histogram(normalize(tbl.AIE),'FaceColor',[0.1 0 1])
xlabel('BAI')
ylabel('Frequency')
title(['Skewness: ' num2str(round(skewness(tbl.AIE),3))])
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
figure(2)
histogram(normalize(tbl.mean_IR),'FaceColor',[1 0 .1])
xlabel('The average of internal resistance')
ylabel('Frequency')
title(['Skewness: ' num2str(round(skewness(tbl.mean_IR),3))])
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
figure(3)
histogram(normalize(tbl.cyc_km_trip),'FaceColor',[.1 0 .1])
xlabel('Throughput intensity')
ylabel('Frequency')
title(['Skewness: ' num2str(round(skewness(tbl.cyc_km_trip),3))])
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
figure(4)
histogram(normalize(tbl.CTC_age),'FaceColor',[.1 .1 .1])
xlabel('Throughput level')
ylabel('Frequency')
title(['Skewness: ' num2str(round(skewness(tbl.CTC_age),3))])
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
skewness(tbl.AIE)
skewness(tbl.mean_IR)
skewness(tbl.cyc_km_trip)
skewness(tbl.CTC_age)

%%
k0 = [0 0];
fitfun = fittype( 'exp(a*x)+b',...
        'dependent',{'y'},'independent',{'x'}, ...
        'coefficients',{'a','b'});
[Fit1, gof1] = fit(tbl.CTC_age,log(AIE),fitfun,'StartPoint',k0);

%%
close all 
figure(4)
plot(tbl.cyc_km_trip,log(AIE),'*')
xlabel('Throughput intensity')
ylabel('AIE')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)

% exportgraphics(f, "SP_VS_HVTEC_niro.pdf") ;
%% PCA

tbl_mat = [tbl.mean_IR, tbl.cyc_km, tbl.CTC_age, tbl.mean_SP];% [tbl.mean_IR, tbl.cyc_km, tbl.CTC_age, tbl.mean_SP];

[coeff,score,latent,tsquared,explained] = pca(normalize(tbl_mat));

%%
figure(1000)
plot3(tbl.mean_IR(Niro_idx), tbl.cyc_km(Niro_idx), tbl.AIE(Niro_idx),'*')
xlabel('Average internal resistance [ohm]')
ylabel('Throughput intensity')
zlabel('IRDI')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)

%%
ana_idx = 4:4:216;
ana_df_temp = trveling_rec(ana_idx,:); 

ana_df_temp(:,21) = trveling_rec(ana_idx-3,21);
%%
f = figure(7);
histogram(ana_df_temp(:,21),9,'FaceColor',[0 0.5 0.4])
xlabel('Initial Cycle Condition [NCC]')
ylabel('# of BEVs')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)

% cd 'save path
%%
idx = ana_df_temp(:,22)-ana_df_temp(:,21);
f = figure(8);
histogram(ana_df_temp(:,22)-ana_df_temp(:,21),16, 'FaceColor', [0.4 0.5 0])
xlabel('Expended Cycle [NCC]')
ylabel('# of BEVs')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)

% cd 'save path'
% exportgraphics(f, "Fig_used_cycle.pdf") ;

%%
X = ana_df_temp(:,21);
Y = ana_df_temp(:,22)-ana_df_temp(:,21);
histogram2(X,Y)

xlabel('Initial Cycle Condition [NCC]')
ylabel('Expended Cycle [NCC]')
zlabel('Frequency')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
%%
% NCC_ini = ana_df_temp(:,21);
NCC_ini = ana_df(:,21);
Used_NCC = ana_df(:,22)-ana_df(:,21);
Used_dist = ana_df(:,25)-ana_df(:,24);
% Thput_intensity = log(ana_df_temp(:,22)-ana_df_temp(:,21))/;
Thput_age = log((ana_df(:,22)+ana_df(:,21))/2); % CTC_age
Thput_intensity = log(Used_NCC./Used_dist); % 

f = figure(9);
plot(Used_NCC, ana_df(:,2),'*')
xlabel('Expended Cycle [NCC]')
ylabel('Average Discharging C-rate [A/Ah]')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)


f = figure(10);
plot(Used_NCC, ana_df_temp(:,3),'*')
xlabel('Expended Cycle [NCC]')
ylabel('Average Regenerative C-rate [A/Ah]')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)

f = figure(11);
plot(Used_NCC, ana_df_temp(:,4),'*')
xlabel('Expended Cycle [NCC]')
ylabel('Average SoC [%]')
set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)


%% Correlation 
% mean(dch_bc) mean(ch_bc) ... %3
% mean(a2_SOC) mean(a2_BT) ... %5
% mean(a2_aux) mean(acc_trq) ... %7
% mean(dec_trq) mean(SP) ... %9
% vel_met acc_met dec_met ... %12
% dbc_met cbc_met bt_met ... %15
% soc_met aux_met Fit5.d ... %18
% gof5.adjrsquare target_cap CTC %21

target_param_df = [AIE tbl_niro.mean_IR Used_NCC Thput_intensity ...
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


% Label을 LaTeX으로 렌더링
s = struct(h);
ax = s.Axes;
ax.XAxis.TickLabelInterpreter = 'latex';
ax.YAxis.TickLabelInterpreter = 'latex';

set(gca, 'fontname', 'Times New Roman', 'fontsize', 14)
% cd 'save_path'
% exportgraphics(h, "Fig_corr_plot.pdf") ;
