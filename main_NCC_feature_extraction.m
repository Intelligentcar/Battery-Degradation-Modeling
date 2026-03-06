%% Feature extraction 2
%% Crate distribution search
clc
close all

func_path = 'E:\KAIST_TOPS\Study\5_prj_study_EVbatt\R';
% raw_path = 'C:\Users\I-TOPS\Downloads\NiroTraveling';
raw_path = 'G:\Users\I-TOPS\Downloads\BAM_input';

cd(raw_path)
dirinfo=dir();
folder_len = length(dirinfo);

batt_loss = [];

gof_rec = [];

EV_rec1 = [];
EV_rec2 = [];

exp_param = [];
exp_param_2d = [];
trveling_rec = [];

% code_path 
cd(func_path)
ID_mat = load('EV_id.mat'); %54EV 
ID_info = ID_mat.ID_info;   %54EV

Cap_mat = load('EV_cap.mat');
Cap_info = Cap_mat.Cap_info;
% d = 3
%%
% prev_SOC = 0;
% curr_SOC = 0;d
Ah_vio_rec = []; 
Rec = [];
Dist_Rec = [];
%%
for d = 3:(folder_len)
    if d == 26
        continue
    end
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
    format long
    a1_Thput = [];
    
    file_name_list = {flist.name}';

    temp_list = char(file_name_list);
    target_list = string(temp_list(:,end-13:end-4));
    target_list = str2double(target_list);
    %%
    [sortedA, index] = sort(target_list,'ascend');
    
    ini_idx = index(1);
    end_idx = index(end);

    vi = ID_info == string(veh_ID);
    target_cap = Cap_info(vi);
    %%
    CTC24_ini = 0; 
    CTC24_end = 0;

    DIST_ini = 0;
    DIST_end = 0;
    while(1)
        %% ini 구하기        
        if CTC24_ini == 0
            cd(flist(ini_idx).folder)
            file_name = flist(ini_idx).name;
            df = readtable(file_name);

            sp = split(file_name,')');sp = string(sp(2));sp = split(sp,'.');
            sp = sp(1);

            df = df(df.SOC ~= 0,:);
            df = df(df.Dis_hist_A ~= 0,:);
            df = df(df.Charge_hist_A ~= 0,:);
            df = df(df.Charge_hist_A >0 & df.Dis_hist_A >0,:);
            [nan,TF] = rmoutliers(df.Charge_hist_A);
            df = df(~TF,:);
            [nan,TF] = rmoutliers(df.Dis_hist_A);
            df = df(~TF, :);
            if size(df,1) > 100
                temp_ini = (df.Dis_hist_A + df.Charge_hist_A)/(2*target_cap); % Ah
                CTC24_ini = median(temp_ini);
                DIST_ini = median(df.hist_trip);
            else
                ini_idx = ini_idx + 1;
            end
        end               

        %% end 구하기             
        if CTC24_end == 0 || DIST_end == 0
            cd(flist(end_idx).folder)
            file_name = flist(end_idx).name;
            df = readtable(file_name);

            sp = split(file_name,')');sp = string(sp(2));sp = split(sp,'.');
            sp = sp(1);

            df = df(df.SOC ~= 0,:);
            df = df(df.Dis_hist_A ~= 0,:);
            df = df(df.Charge_hist_A ~= 0,:);
            df = df(df.Charge_hist_A >0 & df.Dis_hist_A >0,:);
            [nan,TF] = rmoutliers(df.Charge_hist_A);
            df = df(~TF,:);
            [nan,TF] = rmoutliers(df.Dis_hist_A);
            df = df(~TF, :);
            if size(df,1) > 100
                temp_end = (df.Dis_hist_A + df.Charge_hist_A)/(2*target_cap); % Ah
                CTC24_end = median(temp_end);
                DIST_end = median(df.hist_trip);
                if DIST_end == 0
                    end_idx = end_idx - 1;
                    continue
                end
            else
                end_idx = end_idx - 1;
            end
        end
        
        %%

        if CTC24_ini ~= 0 && CTC24_end ~= 0

            temp_rec = [d CTC24_ini CTC24_end];
            temp_dist_rec = [d DIST_ini DIST_end];
            Rec = [Rec; temp_rec];
            Dist_Rec = [Dist_Rec; temp_dist_rec];
            break
        end
    end   
end
%% Data save
save('Data_CTC_rec.mat', 'Rec')
save('Data_Dist_rec.mat', 'Dist_rec')
