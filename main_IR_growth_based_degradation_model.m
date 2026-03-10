% 1. IR growth-based degradation model
% 2. Trip feature extraction for battery aging model analysis
clear
clc
close all

func_path = ''; % user function path
raw_path = '';% data path

cd(raw_path)
dirinfo=dir();
folder_len = length(dirinfo);

batt_loss = [];
batt_loss = [];

gof_rec = [];

EV_rec1 = [];
EV_rec2 = [];

exp_param = [];
exp_param_2d = [];
trveling_rec = [];
Quaterly_df = [];

% code_path 
cd(func_path)
ID_mat = load('EV_id.mat'); %54EV 
ID_info = ID_mat.ID_info;   %54EV

Cap_mat = load('EV_cap.mat');
Cap_info = Cap_mat.Cap_info;
%%
Ah_vio_rec = []; 

for d = 3:56(folder_len)
    dch_vol_std = [];
    disp(d)    
    %% Traveling Data
    veh_ID = dirinfo(d).name;    
    r_path = raw_path;
    path = append(r_path,'\',veh_ID);
    cd(path)
    
    format short

    flen = length(dir('**\*.csv'));
    flist = dir('**\*.csv');
    %%
    total_R = [];
    total_index = [];
    
    total_OIR = [];
    total_ERR = [];
  
    a1_mile = [];                
    a1_Thput = [];
    a1_BC = []; % regen과 demand 
    a1_rpm = [];
    a1_vel = []; % speed
    a1_aux = []; % LDC power
    a1_BT = []; % battery temperature
    a1_SOC = []; % SoC
    a1_trq = []; % Torque

    DOD_rec = []; % DoD
        
    % micro level
    total_micro_BT = [];
    total_micro_SOC = [];
    total_micro_R = [];
    total_micro_Ah = [];

    date_rec = 0;
    Ah_vio_chk = 0;
    %%
    prev_SOC = 0;
    curr_SOC = 0;
    % cnt = 1;
    for findex = 1:flen
        %%
        cd(flist(findex).folder)
        file_name = flist(findex).name;
        df = readtable(file_name);
        
        if size(df,1) < 600
            continue
        end
        
        sp = split(file_name,')');sp = string(sp(2));sp = split(sp,'.');
        sp = sp(1);
        temp_sp = char(sp);
        temp_sp = temp_sp(2:10);                 
        %%
        cnt = 1;
        for temp_i = 1:size(df,1)         
            
            if cnt == size(df,1) 
                break
            end
            cmp_time = char(df.Time_2(temp_i));
            if length(cmp_time) < 18
                continue
            end

            if strcmp(cmp_time,'NULL') || strcmp(cmp_time,'NaT')
                
                cnt = cnt + 1;
                
                continue
            end

            temp_date = cmp_time;
            temp_date = erase(temp_date,' ');
            temp_date = erase(temp_date,'-');
            date_date = num2str(2000000000 + str2double(temp_date(3:10)));

            if contains(date_date,temp_sp) ~= 1%strcmp(temp_sp, date_date) ~= 1
                cnt = cnt + 1;                
                continue
            else
                break
            end
        end
        if cnt < temp_i
            cnt = temp_i;
        end
        %%
        temp_date = char(df.Time_2(cnt));
        if strcmp(cmp_time,'NULL') || strcmp(cmp_time,'NaT')               
            continue
        end
        temp_date = erase(temp_date,' ');
        temp_date = erase(temp_date,'-');
        date_date = num2str(2000000000 + str2double(temp_date(3:10)));
        
        num_date = 2000000000 + str2double(temp_date(3:10));

        if contains(date_date,temp_sp) ~= 1%strcmp(temp_sp, date_date) ~= 1
            continue
        end
         %%     
        df = df(df.SOC ~= 0,:); 
        df = df(df.Dis_hist_A ~= 0,:);
        df = df(df.Charge_hist_A ~= 0,:);  
        df = df(df.Charge_hist_A >0 & df.Dis_hist_A >0,:);
        [nan,TF] = rmoutliers(df.Charge_hist_A);
        df = df(~TF,:);
        [nan,TF] = rmoutliers(df.Dis_hist_A);
        df = df(~TF, :);            
                    
        if size(df,1) < 600
            continue
        end
        
        cd(func_path)
        ini_R = usr_resist_extract(df);

        curr_SOC = df.SOC(1);

        if prev_SOC +1 < curr_SOC
            DOD_rec = [DOD_rec; curr_SOC - prev_SOC];
        end

        prev_SOC = df.SOC(end);
                    
       %%
        if isnan(ini_R)
            continue
        end        
        
        %%

        cd(func_path)
        [Est_R,micro_R,err] = usr_FFRLS_OIR_updated(df);
        Bat_T = (df.Batt_T_mod1 + df.Batt_T_mod2 + df.Batt_T_mod3 + df.Batt_T_mod4)/4;
        %%
        if Est_R < 0
            continue
        end 
        %%  
        if mod(findex,1000) == 100
            disp(findex)   
        end
        total_index = [total_index; findex];
        total_R = [total_R; ini_R];
        total_OIR = [total_OIR; Est_R];
        
        
        if max(date_rec) + 200 < num_date
            if max(micro_R(:,1)) < max(total_micro_Ah)
                break
                total_micro_Ah = []; total_micro_BT = [];
                total_micro_R = []; total_micro_SOC = [];

                a1_mile = [];a1_Thput = [];a1_BC = []; a1_rpm = [];
                a1_vel = []; a1_aux = []; a1_BT = []; a1_SOC = []; % 
                a1_trq = []; date_rec = [];
                Ah_vio_chk = Ah_vio_chk + 1;
                disp('Violation!')
                disp(findex)
            end
        end

        date_rec = [date_rec;num_date];
        total_micro_Ah = [total_micro_Ah; micro_R(:,1)];
        total_micro_BT = [total_micro_BT; micro_R(:,4)];
        total_micro_SOC = [total_micro_SOC; micro_R(:,2)];
        total_micro_R = [total_micro_R; micro_R(:,3)];

        total_ERR = [total_ERR; err];
                
        temp_Thput = (df.Dis_hist_A + df.Charge_hist_A); % Ah
        
        a1_mile = [a1_mile;df.hist_trip];                
        a1_Thput = [a1_Thput;temp_Thput];
        a1_BC = [a1_BC; df.Batt_current(1:end)]; % regen & demand 
        a1_trq = [a1_trq;df.M_torque]; % acc/dec
        a1_rpm = [a1_rpm;df.RPM];
        a1_vel = [a1_vel;df.speed]; % sp
        a1_aux = [a1_aux; df.VCULDC_current.*df.VCULDC_vol]; % LDC  W
        a1_BT = [a1_BT; Bat_T]; % Battery temperature
        a1_SOC = [a1_SOC; df.SOC]; % SoC

    end
    temp_chk = [d Ah_vio_chk];
    Ah_vio_rec = [Ah_vio_rec; temp_chk];
    disp('Ah violation checking...')
    disp(Ah_vio_chk)
    %% IR = f(T,Ah) 
    vi = ID_info == string(veh_ID);
    target_cap = Cap_info(vi);
    
    [nan,Ah_idx] = sort(total_micro_Ah);
    total_micro_Ah_temp = total_micro_Ah(Ah_idx);
    total_micro_BT_temp = total_micro_BT(Ah_idx);
    total_micro_R_temp = total_micro_R(Ah_idx);
    total_micro_SOC_temp = total_micro_SOC(Ah_idx);         
   
    Ah_len = size(total_micro_Ah,1);
    %% Whole period
    target_pts = normalize([total_micro_BT_temp total_micro_Ah_temp total_micro_R_temp]);
    dbs_idx = dbscan(target_pts,0.5,10); %% dbscan
    
    tot_idx = total_micro_SOC_temp > 30 & total_micro_SOC_temp <= 85;%

    total_x = total_micro_BT_temp(dbs_idx>0 & tot_idx)+0.01;
    total_y = total_micro_Ah_temp(dbs_idx>0 & tot_idx);
    total_z = total_micro_R_temp(dbs_idx>0 & tot_idx);
    total_w = total_micro_SOC_temp(dbs_idx>0 & tot_idx);   
  
    k0 = [0 0 0];
    k1 = [0 0 0 0];
    k2 = [0 0 0 0 0];

    fitfun0 = fittype( '(0.035*exp(-b*x)+c)*y^d',...
        'dependent',{'z'},'independent',{'x','y'}, ...
        'coefficients',{'b','c','d'});
    fitfun1 = fittype( '(a*x^2+b*x+c)*y^d',...
        'dependent',{'z'},'independent',{'x','y'}, ...
        'coefficients',{'a','b','c','d'});
    fitfun2 = fittype( '(0.035*exp(-a/x)+b*x^2+c*x+d)*y^e',...
        'dependent',{'z'},'independent',{'x','y'}, ...
        'coefficients',{'a','b','c','d','e'});
    [Fit0, gof0] = fit([total_x,total_y],total_z,fitfun0,'StartPoint',k0);
    [Fit1, gof1] = fit([total_x,total_y],total_z,fitfun1,'StartPoint',k1);
    [Fit2, gof2] = fit([total_x,total_y],total_z,fitfun2,'StartPoint',k2);

   
    exp_param = [0.035 Fit0.b Fit0.c];
  
    temp_comp = [d Fit0.d Fit1.d Fit2.d ...
                 gof0.adjrsquare gof1.adjrsquare gof2.adjrsquare];
    % save aging model fitting results
    batt_loss = [batt_loss;temp_comp];
     
    %
    a24_mile = a1_mile;a24_Thput = a1_Thput;a24_BC = a1_BC;a24_trq = a1_trq; 
    a24_rpm = a1_rpm;a24_vel = a1_vel;a24_aux = a1_aux;a24_BT = a1_BT;a24_SOC = a1_SOC; % SoC

    dch24_bc = a24_BC(a24_BC > 0 & a24_BC < 500)/target_cap;ch24_bc = a24_BC(a24_BC < 0 & a24_BC > -500)/target_cap;
    acc24_trq = a24_trq(a24_trq > 0 & a24_trq < 500);dec24_trq = a24_trq(a24_trq < 0 & a24_trq > -500);SP24 = a24_vel(a24_vel >0 & a24_vel < 180);

    temp24 = (SP24 - 36).^3;sdv24 = std(SP24);vel4_met = mean(temp24)/(sdv24^3);
    temp24 = (acc24_trq - 10).^3;sdv24 = std(acc24_trq);acc4_met = mean(temp24)/(sdv24^3);
    temp24 = (dec24_trq + 5).^3;sdv24 = std(dec24_trq);dec4_met = mean(temp24)/(sdv24^3);
    temp24 = (dch24_bc - 0.15).^3;sdv24 = std(dch24_bc);dbc4_met = mean(temp24)/(sdv24^3);
    temp24 = (ch24_bc + 0.2).^3;sdv24 = std(ch24_bc);cbc4_met = mean(temp24)/(sdv24^3);
    temp24 = (a24_BT - 22).^3;sdv24 = std(a24_BT);bt4_met = mean(temp24)/(sdv24^3);
    temp24 = (a24_SOC - 72).^3;sdv24 = std(a24_SOC);soc4_met = mean(temp24)/(sdv24^3);
    temp24 = (a24_aux - 270).^3;sdv24 = std(a24_aux);aux4_met = mean(temp24)/(sdv24^3);
    CTC24_ini = min(a24_Thput)/(2*target_cap);
    CTC24_end = max(a24_Thput)/(2*target_cap);

    temp_rec4 = [d ... %1
                mean(dch24_bc) mean(ch24_bc) mean(a24_SOC) mean(a24_BT) ... %5
                mean(a24_aux) mean(acc24_trq) mean(dec24_trq) mean(SP24) ...%9
                vel4_met acc4_met dec4_met dbc4_met cbc4_met bt4_met ...%15
                soc4_met aux4_met Fit0.d gof0.adjrsquare target_cap ...%20
                CTC24_ini CTC24_end Ah_len a24_mile(1) a24_mile(end) ...%25
                exp_param ...%28
                max(dch24_bc) max(ch24_bc) max(a24_SOC) max(a24_BT) ...%32
                max(a24_aux) max(acc24_trq) max(dec24_trq) max(SP24) ...%36
                min(dch24_bc) min(ch24_bc) min(a24_SOC) min(a24_BT) ...%40
                min(a24_aux) min(acc24_trq) min(dec24_trq) min(SP24) ...%44
                std(dch24_bc) std(ch24_bc) std(a24_SOC) std(a24_BT) ...%48
                std(a24_aux) std(acc24_trq) std(dec24_trq) std(SP24)];%52
    
    trveling_rec = [trveling_rec; temp_rec4];
   
    %% Quarterly analysis
    th1 = round(Ah_len/4);th2 = round(Ah_len/2);th3 = round(3*Ah_len/4);

    one1_idx = zeros(Ah_len,1);        one2_idx = zeros(Ah_len,1);    
    one3_idx = zeros(Ah_len,1);        one4_idx = zeros(Ah_len,1);    
    
    one1_idx(1:th1) = 1;        one2_idx(th1+1:th2) = 1;
    one3_idx(th2+1:th3) = 1;    one4_idx(th3+1:end) = 1;

    tot1_idx = total_micro_SOC_temp > 30 & total_micro_SOC_temp <= 85;
    tot2_idx = total_micro_SOC_temp > 30 & total_micro_SOC_temp <= 85;
    tot3_idx = total_micro_SOC_temp > 30 & total_micro_SOC_temp <= 85;
    tot4_idx = total_micro_SOC_temp > 30 & total_micro_SOC_temp <= 85;
    target_pts = normalize([total_micro_BT_temp total_micro_Ah_temp total_micro_R_temp]);
    dbs_idx = dbscan(target_pts,0.5,10); %% dbscan을 했다는 것 업데이트 확인!@
   
    % DBSCAN 버전
    total_x = total_micro_BT_temp(dbs_idx>0 & tot1_idx)+0.01;total_y = total_micro_Ah_temp(dbs_idx>0 & tot1_idx);
    total_z = total_micro_R_temp(dbs_idx>0 & tot1_idx);total_w = total_micro_SOC_temp(dbs_idx>0 & tot1_idx); 

    total1_x = total_micro_BT_temp(dbs_idx>0 & tot1_idx == 1)+0.01;total1_y = total_micro_Ah_temp(dbs_idx>0 & tot1_idx == 1);
    total1_z = total_micro_R_temp(dbs_idx>0 & tot1_idx == 1);total1_w = total_micro_SOC_temp(dbs_idx>0 & tot1_idx == 1);    

    total2_x = total_micro_BT_temp(dbs_idx>0 & tot2_idx == 1)+0.01;total2_y = total_micro_Ah_temp(dbs_idx>0 & tot2_idx == 1);
    total2_z = total_micro_R_temp(dbs_idx>0 & tot2_idx == 1);total2_w = total_micro_SOC_temp(dbs_idx>0 & tot2_idx == 1);   

    total3_x = total_micro_BT_temp(dbs_idx>0 & tot3_idx == 1)+0.01;total3_y = total_micro_Ah_temp(dbs_idx>0 & tot3_idx == 1);
    total3_z = total_micro_R_temp(dbs_idx>0 & tot3_idx == 1);total3_w = total_micro_SOC_temp(dbs_idx>0 & tot3_idx == 1);   

    total4_x = total_micro_BT_temp(dbs_idx>0 & tot4_idx == 1)+0.01;total4_y = total_micro_Ah_temp(dbs_idx>0 & tot4_idx == 1);
    total4_z = total_micro_R_temp(dbs_idx>0 & tot4_idx == 1);total4_w = total_micro_SOC_temp(dbs_idx>0 & tot4_idx == 1);   
    
    trveling_rec = [trveling_rec; temp_rec4];

    %%
    k0 = [0 0 0];
    fitfun = fittype( '(0.035*exp(-b*x)+c)*y^d',...
        'dependent',{'z'},'independent',{'x','y'}, ...
        'coefficients',{'b','c','d'});
    [Fit, gof] = fit([total_x,total_y],total_z,fitfun,'StartPoint',k0);

    flag1 = 0;
    if size(total1_x,1) > 10
        k0 = [Fit.b Fit.c Fit.d];
        [Fit5, gof5] = fit([total1_x,total1_y],total1_z,fitfun,'StartPoint',k0);
        exp_param5 = [0.035 Fit5.b Fit5.c];
        flag1 = 1;
    end

    flag2 = 0;
    if size(total2_x,1) > 10
        k0 = [Fit5.b Fit5.c Fit5.d];
        temp2_x = [total1_x;total2_x];
        temp2_y = [total1_y;total2_y];
        temp2_z = [total1_z;total2_z];
        [Fit6, gof6] = fit([temp2_x,temp2_y],temp2_z,fitfun,'StartPoint',k0);
        exp_param6 = [0.035 Fit6.b Fit6.c];
        flag2 = 1;
    end

    flag3 = 0;
    if size(total3_x,1) > 10
        k0 = [Fit6.b Fit6.c Fit6.d];
        temp3_x = [temp2_x;total3_x];
        temp3_y = [temp2_y;total3_y];
        temp3_z = [temp2_z;total3_z];
        [Fit7, gof7] = fit([temp3_x,temp3_y],temp3_z,fitfun,'StartPoint',k0);
        exp_param7 = [0.035 Fit7.b Fit7.c];
        flag3 = 1;
    end

    flag4 = 0;
    if size(total4_x,1) > 10
        k0 = [Fit7.b Fit7.c Fit7.d];
        temp4_x = [temp3_x;total4_x];
        temp4_y = [temp3_y;total4_y];
        temp4_z = [temp3_z;total4_z];
        [Fit8, gof8] = fit([temp4_x,temp4_y],temp4_z,fitfun,'StartPoint',k0);
        exp_param8 = [0.035 Fit8.b Fit8.c];
        flag4 = 1;
    end

    if flag1 == 1        
        temp_rec1 = [d gof5.adjrsquare];
        Quaterly_df = [Quaterly_df; temp_rec1];
    end
    
    if flag2 == 1
        temp_rec2 = [d gof6.adjrsquare];
        Quaterly_df = [Quaterly_df; temp_rec2];
    end

    if flag3 == 1    
        temp_rec3 = [d gof7.adjrsquare];
        Quaterly_df = [Quaterly_df; temp_rec3];
    end

    
    if flag4 == 1
        temp_rec4 = [d gof8.adjrsquare]; %50
        Quaterly_df = [Quaterly_df; temp_rec4];
    end      
   
end
%%
save('Data_z_GOF_rec.mat', 'batt_loss')
save('Data_Traveling_rec.mat', 'trveling_rec')
save('Data_Quarterly_rec.mat', 'Quaterly_df')
% writematrix(trveling_rec,'1Data_Traveling_rec.mat')