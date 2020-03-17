%timestamp: 
% lat:   latitude of the oxts-unit (deg)
% lon:   longitude of the oxts-unit (deg)
% alt:   altitude of the oxts-unit (m)
% roll:  roll angle (rad),    0 = level, positive = left side up,      range: -pi   .. +pi
% pitch: pitch angle (rad),   0 = level, positive = front down,        range: -pi/2 .. +pi/2
% yaw:   heading (rad),       0 = east,  positive = counter clockwise, range: -pi   .. +pi
% vn:    velocity towards north (m/s)
% ve:    velocity towards east (m/s)
% vf:    forward velocity, i.e. parallel to earth-surface (m/s)
% vl:    leftward velocity, i.e. parallel to earth-surface (m/s)
% vu:    upward velocity, i.e. perpendicular to earth-surface (m/s)
% ax:    acceleration in x, i.e. in direction of vehicle front (m/s^2)
% ay:    acceleration in y, i.e. in direction of vehicle left (m/s^2)
% ay:    acceleration in z, i.e. in direction of vehicle top (m/s^2)
% af:    forward acceleration (m/s^2)
% al:    leftward acceleration (m/s^2)
% au:    upward acceleration (m/s^2)
% wx:    angular rate around x (rad/s)
% wy:    angular rate around y (rad/s)
% wz:    angular rate around z (rad/s)
% wf:    angular rate around forward axis (rad/s)
% wl:    angular rate around leftward axis (rad/s)
% wu:    angular rate around upward axis (rad/s)
% pos_accuracy:  velocity accuracy (north/east in m)
% vel_accuracy:  velocity accuracy (north/east in m/s)
% navstat:       navigation status (see navstat_to_string)
% numsats:       number of satellites tracked by primary GPS receiver
% posmode:       position mode of primary GPS receiver (see gps_mode_to_string)
% velmode:       velocity mode of primary GPS receiver (see gps_mode_to_string)
% orimode:       orientation mode of primary GPS receiver (see gps_mode_to_string)
%%
plot_result = true;
if(plot_result)
    imu_fig_h = figure;
    imu_fig_h.Name = 'imu interp';
    figure(imu_fig_h);
    title('IMU interpolation and noise');
    subplot(231);plot(imu_unsync_data(:,1), imu_unsync_data(:,13), 'r.','MarkerSize',1);title('ax');hold on;
    subplot(232);plot(imu_unsync_data(:,1), imu_unsync_data(:,14), 'r.','MarkerSize',1);title('ay');hold on;
    subplot(233);plot(imu_unsync_data(:,1), imu_unsync_data(:,15), 'r.','MarkerSize',1);title('az');hold on;
    subplot(234);plot(imu_unsync_data(:,1), imu_unsync_data(:,19), 'r.','MarkerSize',1);title('wx');hold on;
    subplot(235);plot(imu_unsync_data(:,1), imu_unsync_data(:,20), 'r.','MarkerSize',1);title('wy');hold on;
    subplot(236);plot(imu_unsync_data(:,1), imu_unsync_data(:,21), 'r.','MarkerSize',1);title('wz');hold on;
    
    imu_fig_wz_h = figure;
    figure(imu_fig_wz_h);
    orign_p = plot(imu_unsync_data(:,1), imu_unsync_data(:,21), 'r.','MarkerSize',1);hold on;
    title('IMU interpolation on $\omega_z$','Interpreter','latex','FontName','Times New Roman');
    xlabel('time (s)','FontSize',12,'FontName','Times New Roman');
    ylabel('angular speed (rad/s)','FontSize',12,'FontName','Times New Roman');
end
%imu_unsync_data = imu_unsync_data2;
dt = imu_unsync_data(2:end,1) - imu_unsync_data(1:end-1,1);

cyc_time = 1/100;   
brp_index = find(dt>(cyc_time*1.4));%断点位置


uns_index = find(dt<0);%不稳定点位置
uns_size = size(uns_index,1);

total_size = size(imu_unsync_data,1);

%NOUN = -1;
NOUN = nan;
%imu_unsync_data2 = imu_unsync_data;

%% 处理时间戳
% for i=1:length(uns_index)
%     tem_index = find(brp_index == uns_index(i)-1);
%     brp_index(tem_index) = [];
% end
% 
% for i=1:length(uns_index)
%     index = uns_index(i);
%     res = imu_unsync_data(index+1:-1:2,1)-imu_unsync_data(index:-1:1,1);
%     brp = find(round(res*100) ~= 1);
%     num = brp(2,1) - brp(1,1);
%     in_time = linspace(imu_unsync_data(index-num,1),imu_unsync_data(index+1,1), num+2);
%     imu_unsync_data2(index-num+1:index,1) = in_time(2:end-1);
% end

%brp_index_and_type = [brp_index,zeros(length(brp_index),1)]; % 0 for break 1 for unstable
unstable_size = 0;
for i=1:length(brp_index)
    prob_step = 10;
    valid_count = 0;
    is_indeed_break_pt = false; % else this is a unstatble-point.
    %brp_index(i:end) = brp_index(i:end)-unstable_size+1;
    if (brp_index(i) > 5) % this only not happens in kitti 00
        p=polyfit([brp_index(i)-3:brp_index(i)]',imu_unsync_data(brp_index(i)-3:brp_index(i),1),1);
        prob_index = brp_index(i);
        while (prob_index<length(imu_unsync_data) && prob_index < brp_index(i)+1000 )
            prob_index = prob_index + prob_step;
            dist = abs(polyval(p, prob_index) - imu_unsync_data(prob_index,1));
            if dist < 1e-3
                valid_count = valid_count + 1;
                if valid_count > 3
                    break
                end
            end
        end
        if valid_count~=0 % then this point is a unstable point instead of a break point
         
            dist = Inf;
            prob_index = brp_index(i);
            unstable_size = 0;
            while dist > 1e-3
                prob_index = prob_index +1;
                dist = abs(polyval(p, prob_index) - imu_unsync_data(prob_index,1));
                unstable_size = unstable_size+1;
            end
            unstable_size = unstable_size-1;
            unstable_end_index = prob_index-1;
%             re_index_time = linspace(imu_unsync_data(brp_index(i)-1,1),imu_unsync_data(unstable_end_index,1),unstable_size+2);
%             imu_unsync_data(brp_index(i)-1:unstable_end_index,1) = re_index_time';
%             brp_index_and_type(i,2)=unstable_size-1;
%             brp_index(i)=[];
%             re_index_time = linspace(imu_unsync_data(brp_index_copy(i)-1,1),imu_unsync_data(unstable_end_index,1),unstable_size+2);
            imu_unsync_data(brp_index(i)+1:unstable_end_index,:) = [];
            if i+1<=length(brp_index)
                brp_index(i+1:end) = brp_index(i+1:end) - unstable_size;
            end

        end
    end
end
dt = imu_unsync_data(2:end,1) - imu_unsync_data(1:end-1,1);
cyc_time = 1/100;   
brp_index = find(dt>(cyc_time*1.4));%断点位置
uns_index = find(dt<0);%不稳定点位置
uns_size = size(uns_index,1);
%% spline 三次方样条数据插值:
%处理断点

fixed_data = imu_unsync_data;% 结果矩阵
imudata_col_index = [13,14,15,19,20,21];
sample_size = 10;
brp_size = length(brp_index);
timestamp_brp = cell(brp_size,1);
output_brp = cell(brp_size,length(imudata_col_index));

for j=1:length(imudata_col_index)
    for i=1:brp_size %brp_size
        insert = imudata_col_index(j);
        index = brp_index(i);
        num = dt(index)/cyc_time+1; 
        xp = linspace(imu_unsync_data(index,1),imu_unsync_data(index+1,1),floor(num));
        if (index-sample_size<1 && index+sample_size<total_size)
            y = imu_unsync_data(index:index+2*sample_size,insert);
            x = imu_unsync_data(index:index+2*sample_size,1);
            yp = interp1(x,y,xp,'PCHIP');
        elseif (index-sample_size>1 && index+sample_size>total_size)
            y = imu_unsync_data(index-2*sample_size:index,insert);
            x = imu_unsync_data(index-2*sample_size:index,1);
            yp = interp1(x,y,xp,'PCHIP');
        else
            y = imu_unsync_data(index-sample_size/2:index+sample_size/2,insert);
            x = imu_unsync_data(index-sample_size/2:index+sample_size/2,1);
            if (j==length(imudata_col_index))
                yp = interp1(x,y,xp,'spline');
            else
                yp = interp1(x,y,xp,'PCHIP');
            end
        end
        timestamp_brp{i,1} = xp(2:end-1);
        output_brp{i,j} = yp(2:end-1);

    end
end

inserted_matrix_length = 0;
for m=1:brp_size %插入点位置为 brp_index
        brp_length = length(output_brp{m,1});
        ins_matrix = zeros(brp_length,31);
        for k=1:brp_length           
            ins_matrix(k,1) = timestamp_brp{m,1}(k);
            ins_matrix(k,2:12) = NOUN;
            ins_matrix(k,13) = output_brp{m,1}(k);
            ins_matrix(k,14) = output_brp{m,2}(k);
            ins_matrix(k,15) = output_brp{m,3}(k);
            ins_matrix(k,16:18) = NOUN;
            ins_matrix(k,19) = output_brp{m,4}(k);
            ins_matrix(k,20) = output_brp{m,5}(k);
            ins_matrix(k,21) = output_brp{m,6}(k);
            ins_matrix(k,22:end) = NOUN;
        end
        front = brp_index(m) + inserted_matrix_length;
        behind = front+1;
        fixed_data = [fixed_data(1:front,:); ins_matrix; fixed_data(behind:end,:)];
        inserted_matrix_length = inserted_matrix_length + brp_length;
        if(plot_result)
            figure(imu_fig_h);
            subplot(231);plot(ins_matrix(:,1), ins_matrix(:,13), 'b.','MarkerSize',1);hold on;
            subplot(232);plot(ins_matrix(:,1), ins_matrix(:,14), 'b.','MarkerSize',1);hold on;
            subplot(233);plot(ins_matrix(:,1), ins_matrix(:,15), 'b.','MarkerSize',1);hold on;
            subplot(234);plot(ins_matrix(:,1), ins_matrix(:,19), 'b.','MarkerSize',1);hold on;
            subplot(235);plot(ins_matrix(:,1), ins_matrix(:,20), 'b.','MarkerSize',1);hold on;
            subplot(236);plot(ins_matrix(:,1), ins_matrix(:,21), 'b.','MarkerSize',1);hold on;
            
            figure(imu_fig_wz_h);
            plot(ins_matrix(:,1), ins_matrix(:,21), 'b.','MarkerSize',1);hold on;
        end
end
imu_time_const_bias = mean(img_unsync_timestamp(1:length(img_sync_timestamp)) - img_sync_timestamp)...
    + img_unsync_timestamp_sec_init - img_sync_timestamp_sec_init...
    + img_unsync_timestamp_nsec_init - img_sync_timestamp_nsec_init;
% 
% imu_time_const_bias = img_unsync_timestamp_sec_init - img_sync_timestamp_sec_init...
% 	+ img_unsync_timestamp_nsec_init - img_sync_timestamp_nsec_init;
% fixed_data(:,1) = fixed_data(:,1) + imu_time_const_bias;
% 
% valid_idx = find(fixed_data(:,1)>0);
% % up_samp_idx =  valid_idx(1) + round(length(valid_idx)/length(img_sync_timestamp) * [0:length(img_sync_timestamp)-1] );
% % imu_time_const_bias = mean(fixed_data(up_samp_idx,1) - img_sync_timestamp);
% imu_time_const_bias = mean(fixed_data(valid_idx,1)) - mean(img_sync_timestamp);
fixed_data(:,1) = fixed_data(:,1) + imu_time_const_bias;

% vis-check time good:
if(plot_result)
    figure(imu_fig_wz_h);
    fake_orign_p = plot(NaN, NaN, 'r.','MarkerSize',5);
    fake_interp_p = plot(NaN, NaN, 'b.','MarkerSize',5);
    h = legend([fake_orign_p fake_interp_p],'Original unsynced data', 'Interpolated data');
    h.FontSize = 12;
    h.FontName = 'Times New Roman';
    
    imu_time_fig_h = figure;
    imu_time_fig_h.Name = 'imu time interp';
    figure(imu_time_fig_h);
        plot(imu_unsync_data(:,1), imu_unsync_data(:,21), 'r.',...
            imu_sync_data(:,1), imu_sync_data(:,21), 'ms',...
            fixed_data(:,1), fixed_data(:,21), 'b.');
        h=legend('Unsynced IMU data','Synced IMU data','Aligned unsynced IMU data');
        h.FontSize = 12;
        h.FontName = 'Times New Roman';
        title('Unsynchronized data alignment','FontSize',12,'FontName','Times New Roman');
        xlabel('time (s)','FontSize',12,'FontName','Times New Roman');
        ylabel('angular speed (rad/s)','FontSize',12,'FontName','Times New Roman');
        
    imu_dt_fig_h = figure;
    imu_dt_fig_h.Name = 'imu dt interp';
    figure(imu_dt_fig_h);
        plot(imu_unsync_data(1:end-1,1),imu_unsync_data(2:end,1)-imu_unsync_data(1:end-1,1),'r.',...
             imu_sync_data(1:end-1,1),imu_sync_data(2:end,1)-imu_sync_data(1:end-1,1),'g.',...
              fixed_data(1:end-1,1),fixed_data(2:end,1)-fixed_data(1:end-1,1),'b.');
        h=legend('imu data','imu sync data','fixed data');
        h.FontSize = 12;
        title('timestamp: should not see blue outliers');
end
% figure
% hold on
% plot(imu_unsync_data(1:end,1),'r.');
% plot(imu_unsync_data2(1:end,1),'b.');
% hold off