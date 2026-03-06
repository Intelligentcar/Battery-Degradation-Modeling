function [End_R,micro_R,RMSE] = ...
    usr_FFRLS_OIR(df_rec)
% Original ver..
%     [UOC_rec,TV_rec,theta_rec,resist_rec,err_rec,BT_rec] = ...
%     usr_FFRLS_OIR(df_rec) %,UOC_rec,TV_rec,theta_rec) %% Estimation of motor current
    %%
    y = df_rec.Batt_vol;
    BC = df_rec.Batt_current;
    SOC = df_rec.SOC;

    theta_rec = [];
    UOC_rec =[];
    TV_rec = [];
    
    len = size(y,1);

    P_k = 3*eye(6);
    I = eye(6);

    mu = 0.995; % 0.9996; % forgetting factor

    c3 = 0;
    c5 = 0;
    c4 = 0;
    c2 = 0;
    c1 = 0;
    Uoc = y(3);
    Uoc_prev = y(2);
    Uoc_pprev = y(1);
    theta_k = [(1-c1-c2)*Uoc c1 c2 c3 c4 c5]';
%     for i = 3:len
% 
%         I_curr = BC(i);
%         I_prev = BC(i-1);
%         I_pprev = BC(i-2);
% 
%         y_pprev = y(i-2);
%         y_prev = y(i-1);
%         y_curr = y(i);
% 
%         pi_k = [1 y_prev y_pprev I_curr I_prev I_pprev];
%         %% Gain update
%         K_k = P_k*pi_k'*(pi_k*P_k*pi_k' + mu)^-1;
%         %% State estimation measurement update
%         theta_k = theta_k + K_k*(y_curr - pi_k*theta_k);
%         % theta_(k-1) -> theta_(k)
%         %% Error covariance time update
%         P_k = 1/mu*(I - K_k*pi_k)*P_k; % P_(k-1) -> P_(k)
%         
%         Uoc = theta_k(1) + theta_k(2)*Uoc_prev + theta_k(3)*Uoc_pprev;
%         Uoc_prev = Uoc;
%         Uoc_pprev = Uoc_prev;        
% 
%     end
    
    for i = 3:len

        I_curr = BC(i);
        I_prev = BC(i-1);
        I_pprev = BC(i-2);

        y_pprev = y(i-2);
        y_prev = y(i-1);
        y_curr = y(i);

        pi_k = [1 y_prev y_pprev I_curr I_prev I_pprev];
        %% Gain update
        K_k = P_k*pi_k'*(pi_k*P_k*pi_k' + mu)^-1;
        %% State estimation measurement update
        theta_k = theta_k + K_k*(y_curr - pi_k*theta_k);
        % theta_(k-1) -> theta_(k)
        %% Error covariance time update
        P_k = 1/mu*(I - K_k*pi_k)*P_k; % P_(k-1) -> P_(k)

        theta_rec = [theta_rec; theta_k'];

        Uoc = theta_k(1) + theta_k(2)*Uoc_prev + theta_k(3)*Uoc_pprev;
        Uoc_prev = Uoc;
        Uoc_pprev = Uoc_prev;

        UOC_rec = [UOC_rec; Uoc];

        est_vol = pi_k*theta_k;
        TV_rec = [TV_rec;est_vol];
    end
    %%
    BT_rec = (df_rec.Batt_T_mod1+df_rec.Batt_T_mod2+...
              df_rec.Batt_T_mod3+df_rec.Batt_T_mod4)/4;
    
    Ah = round((df_rec.Dis_hist_A + df_rec.Charge_hist_A)/10); % a unit of 10Ah
    range = 500:(len-2);
    OIR_Ah = Ah(range)*10;
    OIR_SOC = SOC(range);
    OIR_BT = BT_rec(range);
    Est_R =-theta_rec(range,4);
    A = y(3:end);
    F = TV_rec;
    err = abs(F-A);
    RMSE = rmse(F,A);
    %%
    unique_Ah = unique(OIR_Ah); % 1Ah 단위
    unique_Ah_R = zeros(size(unique_Ah));
    unique_Ah_SOC = zeros(size(unique_Ah));
    unique_Ah_BT = zeros(size(unique_Ah));
    for i = 1:size(unique_Ah,1)
        idx = OIR_Ah == unique_Ah(i);
        idx1 = Est_R > 0.025 & Est_R < 0.15;
        unique_Ah_R(i) = mean(Est_R(idx & idx1));
        unique_Ah_SOC(i) = mean(OIR_SOC(idx & idx1),'omitnan');
        unique_Ah_BT(i) = mean(OIR_BT(idx & idx1));
    end

    End_R = Est_R(end);
    micro_R = [unique_Ah unique_Ah_SOC unique_Ah_R unique_Ah_BT];
    
    %%
    % figure(2)
    % plot(SOC)
    % ylabel('SOC [%]')
    
%     figure(3)
%     plot(cumsum(df_rec.Batt_current)/3600)
%     ylabel('Current usage [Ah]')
%     
    % if RMSE < 0.8 %max(err) < 0.6
    %     disp(max(err))
    %     figure(4)
    %     % resist_rec = -theta_rec(:,4);
    %     plot(-theta_rec(:,4))
    %     xlim([0 length(theta_rec(:,4))*1.05])
    %     xlabel('Time [second]')
    %     ylabel('Internal Resistance [\Omega]')
    %     set(gca,'FontSize',14,'fontname','Times New Roman')
    %     % title('In case of driving profile') 
    %     figure(5)
    %     plot(y(3:end))
    %     hold on
    %     plot(TV_rec)
    %     hold off
    %     title(['RMSE: ' num2str(RMSE)])
    %     xlabel('Time [second]')
    %     ylabel('Voltage [V]')
    %     legend('Battery Voltage','Estimated Voltage')
    %     set(gca,'FontSize',14,'fontname','Times New Roman')
    % end
%     
%     figure(6)
%     err_rec = y(3:end)-TV_rec;
%     plot(y(3:end)-TV_rec)
%     ylabel('Error [V]')
%     
%     figure(7)
%     BT_rec = BT_rec(3:end);
% 
%     plot(BT_rec)
%     ylabel('Battery Temperature [^oC]')
% % %  
%     figure(8)
%     plot(UOC_rec)
%     % hold on
%     % plot(y)
%     % hold off    
%     legend('OCV','Measured Voltage')
%     xlabel('Time [sec]')
%     ylabel('Open Circuit Voltage [V]')    
%     set(gca,'FontSize',18,'fontname','Times New Roman')
% 
    % figure(9)
    % plot(OIR_SOC,Est_R,'*')
    % % hold on
    % % plot(y)
    % % hold off 
    % xlabel('SOC [%]')
    % % legend('SOC','IR')
    % ylabel('Internal Resistance')    

end