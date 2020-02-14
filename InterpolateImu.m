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
    subplot(231);plot(imu_unsync_data(:,1), imu_unsync_data(:,13), 'r.');title('ax');hold on;
    subplot(232);plot(imu_unsync_data(:,1), imu_unsync_data(:,14), 'r.');title('ay');hold on;
    subplot(233);plot(imu_unsync_data(:,1), imu_unsync_data(:,15), 'r.');title('az');hold on;
    subplot(234);plot(imu_unsync_data(:,1), imu_unsync_data(:,19), 'r.');title('wx');hold on;
    subplot(235);plot(imu_unsync_data(:,1), imu_unsync_data(:,20), 'r.');title('wy');hold on;
    subplot(236);plot(imu_unsync_data(:,1), imu_unsync_data(:,21), 'r.');title('wz');hold on;

end

dt = imu_unsync_data(2:end,1) - imu_unsync_data(1:end-1,1);

cyc_time = 1/100;   
brp_index = find(dt>(cyc_time*1.4));%断点位置


uns_index = find(dt<0);%不稳定点位置
[uns_size,~] = size(uns_index);

[total_size,~] = size(imu_unsync_data);

%NOUN = -1;
NOUN = nan;
fixed_data = imu_unsync_data;% 结果矩阵
%% 处理时间戳
for i=1:length(uns_index)
    tem_index = find(brp_index == uns_index(i)-1);
    brp_index(tem_index) = [];
end

for i=1:length(uns_index)
    index = uns_index(i);
    res = imu_unsync_data(index+1:-1:2,1)-imu_unsync_data(index:-1:1,1);
    brp = find(round(res*100) ~= 1);
    num = brp(2,1) - brp(1,1);
    in_time = linspace(imu_unsync_data(index-num,1),imu_unsync_data(index+1,1), num+2);
    imu_unsync_data(index-num+1:index,1) = in_time(2:end-1);
end
%% spline 三次方样条数据插值:
%处理断点
imudata_col_index = [13,14,15,19,20,21];

sample_size = 10;
[brp_size,~] = size(brp_index);
timestamp_brp = cell(brp_size,1);
output_brp = cell(brp_size,length(imudata_col_index));

for j=1:length(imudata_col_index)
    for i=1:brp_size %brp_size
        insert = imudata_col_index(j);
        index = brp_index(i);
        if (j==length(imudata_col_index))
            if (index-sample_size<1 && index+sample_size<total_size)
                y = imu_unsync_data(index:index+2*sample_size,insert);
                x = imu_unsync_data(index:index+2*sample_size,1);
                num = dt(index)/cyc_time+1; 
                xp = linspace(imu_unsync_data(index,1),imu_unsync_data(index+1,1),floor(num));
                yp = interp1(x,y,xp,'PCHIP');
            elseif (index-sample_size>1 && index+sample_size>total_size)
                y = imu_unsync_data(index-2*sample_size:index,insert);
                x = imu_unsync_data(index-2*sample_size:index,1);
                num = dt(index)/cyc_time+1; 
                xp = linspace(imu_unsync_data(index,1),imu_unsync_data(index+1,1),floor(num));
                yp = interp1(x,y,xp,'PCHIP');
            else
                y = imu_unsync_data(index-sample_size/2:index+sample_size/2,insert);
                x = imu_unsync_data(index-sample_size/2:index+sample_size/2,1);
                num = dt(index)/cyc_time+1; 
                xp = linspace(imu_unsync_data(index,1),imu_unsync_data(index+1,1),floor(num));
                yp = interp1(x,y,xp,'spline');
            end
            timestamp_brp{i,1} = xp(2:end-1);
            output_brp{i,j} = yp(2:end-1);
            
        else
            if (index-sample_size<1 && index+sample_size<total_size)
                y = imu_unsync_data(index:index+2*sample_size,insert);
                x = imu_unsync_data(index:index+2*sample_size,1);
                num = dt(index)/cyc_time+1; 
                xp = linspace(imu_unsync_data(index,1),imu_unsync_data(index+1,1),floor(num));
                yp = interp1(x,y,xp,'PCHIP');
            elseif (index-sample_size>1 && index+sample_size>total_size)
                y = imu_unsync_data(index-2*sample_size:index,insert);
                x = imu_unsync_data(index-2*sample_size:index,1);
                num = dt(index)/cyc_time+1; 
                xp = linspace(imu_unsync_data(index,1),imu_unsync_data(index+1,1),floor(num));
                yp = interp1(x,y,xp,'PCHIP');
            else
                y = imu_unsync_data(index-sample_size:index+sample_size,insert);
                x = imu_unsync_data(index-sample_size:index+sample_size,1);
                num = dt(index)/cyc_time+1; 
                xp = linspace(imu_unsync_data(index,1),imu_unsync_data(index+1,1),floor(num));
                yp = interp1(x,y,xp,'PCHIP');
            end

            timestamp_brp{i,1} = xp(2:end-1);
            output_brp{i,j} = yp(2:end-1);
        end
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
            subplot(231);plot(ins_matrix(:,1), ins_matrix(:,13), 'b.');hold on;
            subplot(232);plot(ins_matrix(:,1), ins_matrix(:,14), 'b.');hold on;
            subplot(233);plot(ins_matrix(:,1), ins_matrix(:,15), 'b.');hold on;
            subplot(234);plot(ins_matrix(:,1), ins_matrix(:,19), 'b.');hold on;
            subplot(235);plot(ins_matrix(:,1), ins_matrix(:,20), 'b.');hold on;
            subplot(236);plot(ins_matrix(:,1), ins_matrix(:,21), 'b.');hold on;
        end
end
imu_time_const_bias = mean(img_unsync_timestamp(1:length(img_sync_timestamp)) - img_sync_timestamp)...
    + img_unsync_timestamp_sec_init - img_sync_timestamp_sec_init...
    + img_unsync_timestamp_nsec_init - img_sync_timestamp_nsec_init;
fixed_data(:,1) = fixed_data(:,1) + imu_time_const_bias;

% vis-check time good:
if(plot_result)
    imu_time_fig_h = figure;
    imu_time_fig_h.Name = 'imu time interp';
    figure(imu_time_fig_h);
    subplot(121);
        plot(imu_unsync_data(:,1), imu_unsync_data(:,21), 'r.',...
            imu_sync_data(:,1), imu_sync_data(:,21), 'g.',...
            fixed_data(:,1), fixed_data(:,21), 'b.');
        legend('imu data','imu sync data','fixed data');
        title('wz: should not see green point');
    subplot(122);
        plot(imu_unsync_data(1:end-1,1),imu_unsync_data(2:end,1)-imu_unsync_data(1:end-1,1),'r.',...
             imu_sync_data(1:end-1,1),imu_sync_data(2:end,1)-imu_sync_data(1:end-1,1),'g.',...
             fixed_data(1:end-1,1),fixed_data(2:end,1)-fixed_data(1:end-1,1),'b.');
        legend('imu data','imu sync data','fixed data');
        title('timestamp: should not see blue outliers');
end

