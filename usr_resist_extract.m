function [result] = usr_resist_extract(df) %% Estimation of motor current
    %% Setting
    
    V_edge = diff(df.Batt_vol);
    C_edge = diff(df.Batt_current);
    
    R_cand = abs(V_edge./C_edge);
    
    temp_df = [V_edge C_edge R_cand];
    
    temp_df = rmmissing(temp_df);
    temp_df = temp_df(temp_df(:,2) ~= 0,:);
    temp_df = temp_df(temp_df(:,3) ~= 0,:); 
    
%     figure(11)
%     subplot(1,2,1)
%     plot(abs(temp_df(:,1)), temp_df(:,3), '*')
%     xlabel('Voltage edge [V]')
%     ylabel('R [ohm]')
%     
% 
%     subplot(1,2,2)
%     plot(abs(temp_df(:,2)), temp_df(:,3), '*')
%     xlabel('Current edge [A]')
%     ylabel('R [ohm]')
    %%
    temp_df = temp_df(abs(temp_df(:,1)) > 0.5 & abs(temp_df(:,2)) > 5, :);
    
%     len = size(temp_df,1);
%     x = 1:1:len;
    mean_R = mean(temp_df(:,3),'omitnan');
%     LSQ_R = lsqr(x',temp_df(:,3));
    
    result = mean_R;
%     figure(1)
%     plot(abs(temp_df(:,1)), temp_df(:,3),'*')
%     figure(2)
%     plot(abs(temp_df(:,2)), temp_df(:,3),'*')
end