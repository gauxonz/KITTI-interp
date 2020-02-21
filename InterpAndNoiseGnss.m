%% parameters
normal_cov_multipler = 2;
normal_bias = 1;

bad_cov_multipler = 5;
bad_gnss_area =	[	27      52	0	60	20;
                    126     242	0	20	10;
                    167     144	0   50  10;
                    277     358	0   30  5;
                    416     248	0   50  10;
                    240     -73	0   60  5;
                    -13     261	0   50  10];
                
good_cov_multipler = 1;
good_gnss_area = [	110     368	0	50	0;
                    -88     166	0	50	0;
                    287     199	0	50	0;];
%% plot orign data first
[orign_e, orign_n, orign_u] = geodetic2enu(fixed_data(:,2),fixed_data(:,3),fixed_data(:,4),...
    fixed_data(1,2),fixed_data(1,3),fixed_data(1,4),wgs84Ellipsoid);


gnss_fig_h = figure;
    gnss_fig_h.Name = 'gnss interp';
    figure(gnss_fig_h);
    subplot(2,3,1);plot(fixed_data(:,1), fixed_data(:,2), 'r.');title('lat');hold on;
    subplot(2,3,2);plot(fixed_data(:,1), fixed_data(:,3), 'r.');title('lon');hold on;
    subplot(2,3,4);plot(fixed_data(:,1), fixed_data(:,4), 'r.');title('alt');hold on;
    subplot(2,3,5);plot(fixed_data(:,1), fixed_data(:,25), 'r.');title('cov');hold on;
    subplot(2,3,[3,6]);plot3(orign_e,orign_n,orign_u,'r'); axis equal; view(0,90);title('traj');hold on;
    
nodata_index = find(isnan(orign_e));
bp= find((nodata_index(2:end)-nodata_index(1:end-1))>1);
bp_begin_idx = nodata_index([1; bp+1]);
bp_length = [bp(1);bp(2:end)-bp(1:end-1);...
    nodata_index(end)-bp_begin_idx(end)+1];

bar = waitbar(0,'gnss 差值加噪声');
%% gnss数据插值:
%处理断点
gnssdata_col_idx = [2,3,4];
gnsscov_col_idx = 25;
sample_size = 5;

xp = cell(length(bp_begin_idx),1);
yp = cell(length(bp_begin_idx),length(gnssdata_col_idx));
cov_p = cell(length(bp_begin_idx),1);
for j = 1:length(gnssdata_col_idx)
    data_col_idx = gnssdata_col_idx(j);
    for i=1:length(bp_begin_idx) %break points numbers
        data_idx = bp_begin_idx(i);
            if ( data_idx - sample_size < 1 &&...
                    data_idx + sample_size < length(fixed_data))
                y = [ fixed_data( data_idx-1, data_col_idx);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, data_col_idx)];
                x = [ fixed_data( data_idx-1 , 1);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, 1)];
                num = bp_length(i); 
                xp{i} = fixed_data( data_idx: data_idx + bp_length(i) - 1, 1);
                yp{i,j} = interp1(x,y,xp{i},'PCHIP');
            elseif ( data_idx - sample_size > 1 &&...
                     data_idx + sample_size > length(fixed_data))
                y = [ fixed_data( data_idx-1 - sample_size : data_idx-1, data_col_idx );...
                      fixed_data( data_idx + bp_length(i), data_col_idx)];
                x = [ fixed_data( data_idx-1 , 1);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, 1)];
                num = bp_length(i); 
                xp{i}  = fixed_data( data_idx: data_idx + bp_length(i) - 1, 1);
                yp{i,j} = interp1(x,y,xp{i},'PCHIP');
            else
                y = [ fixed_data( data_idx-1 - sample_size : data_idx-1, data_col_idx);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, data_col_idx)];
                x = [ fixed_data( data_idx-1 - sample_size : data_idx-1, 1);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, 1)];
                num = bp_length(i); 
                xp{i}  = fixed_data( data_idx: data_idx + bp_length(i) - 1, 1);
                yp{i,j} = interp1(x,y,xp{i},'PCHIP');
            end
            
    end
end
for i=1:length(bp_begin_idx) %break points numbers
        data_idx = bp_begin_idx(i);
            if ( data_idx - sample_size < 1 &&...
                    data_idx + sample_size < length(fixed_data))
                y = [ fixed_data( data_idx-1, gnsscov_col_idx);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, gnsscov_col_idx)];
                x = [ fixed_data( data_idx-1 , 1);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, 1)];
                num = bp_length(i); 
                xp{i} = fixed_data( data_idx: data_idx + bp_length(i) - 1, 1);
                cov_p{i} = interp1(x,y,xp{i},'nearest');
            elseif ( data_idx - sample_size > 1 &&...
                     data_idx + sample_size > length(fixed_data))
                y = [ fixed_data( data_idx-1 - sample_size : data_idx-1, gnsscov_col_idx );...
                      fixed_data( data_idx + bp_length(i), gnsscov_col_idx)];
                x = [ fixed_data( data_idx-1 , 1);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, 1)];
                num = bp_length(i); 
                xp{i}  = fixed_data( data_idx: data_idx + bp_length(i) - 1, 1);
                cov_p{i} = interp1(x,y,xp{i},'nearest');
            else
                y = [ fixed_data( data_idx-1 - sample_size : data_idx-1, gnsscov_col_idx);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, gnsscov_col_idx)];
                x = [ fixed_data( data_idx-1 - sample_size : data_idx-1, 1);...
                      fixed_data( data_idx + bp_length(i): data_idx + bp_length(i) + sample_size, 1)];
                num = bp_length(i); 
                xp{i}  = fixed_data( data_idx: data_idx + bp_length(i) - 1, 1);
                cov_p{i} = interp1(x,y,xp{i},'nearest');
            end
            
end

%% write to interped-data
interped_data = fixed_data;
for i=1:length(bp_begin_idx) %break points numbers %插入点位置为 brp_index
    data_idx = bp_begin_idx(i);
    [interp_e, interp_n, interp_u] = geodetic2enu(yp{i,1},yp{i,2},yp{i,3},...
    fixed_data(1,2),fixed_data(1,3),fixed_data(1,4),wgs84Ellipsoid);
            figure(gnss_fig_h);
            subplot(231);plot(xp{i}, yp{i,1}, 'b.');hold on;
            subplot(232);plot(xp{i}, yp{i,2}, 'b.');hold on;
            subplot(234);plot(xp{i}, yp{i,3}, 'b.');hold on;
            subplot(235);plot(xp{i}, cov_p{i}, 'b.');hold on;
            subplot(2,3,[3,6]);plot3(interp_e,interp_n,interp_u,'b.'); axis equal; view(0,90);title('wy');hold on;
end
% write back 
for j = 1:length(gnssdata_col_idx)
    data_col_idx = gnssdata_col_idx(j);
    for i=1:length(bp_begin_idx) %break points numbers %插入点位置为 brp_index
        data_idx = bp_begin_idx(i);
        interped_data( data_idx: data_idx + bp_length(i) - 1,...
            data_col_idx) = yp{i,j};
    end
end
for i=1:length(bp_begin_idx) %break points numbers %插入点位置为 brp_index
        data_idx = bp_begin_idx(i);
        interped_data( data_idx: data_idx + bp_length(i) - 1,...
            gnsscov_col_idx) = cov_p{i};
end
%% add noise 
noised_data = interped_data;
[orign_e, orign_n, orign_u] = geodetic2enu(interped_data(:,2),interped_data(:,3),interped_data(:,4),...
    interped_data(1,2),interped_data(1,3),interped_data(1,4),wgs84Ellipsoid);
last_pt_in_bad_area = false;
last_pt_in_good_area = false;
edge_index = [];
for i = 1:length(noised_data)
    % check if in bad gnss area
    [db, idx_bad] = min(sqrt(sum((bad_gnss_area(:,1:3)-[orign_e(i) orign_n(i) orign_u(i)]).^2,2)));
    in_bad_gnss_area = db < bad_gnss_area(idx_bad,4);
    
    [dg, idx_good] = min(sqrt(sum((good_gnss_area(:,1:3)-[orign_e(i) orign_n(i) orign_u(i)]).^2,2)));
    in_good_gnss_area = dg < good_gnss_area(idx_good,4);
    if in_bad_gnss_area
        % change cov
        extra_cov = interped_data(i,25) * bad_cov_multipler;
        noised_data(i,25) = extra_cov + bad_gnss_area(idx_bad,5) + noised_data(i,25);
        noised_ei = orign_e(i) + BiasGen(interped_data(i,1),bad_gnss_area(idx_bad,5),4) + randn()*extra_cov;
        noised_ni = orign_n(i) + BiasGen(interped_data(i,1),bad_gnss_area(idx_bad,5),1) + randn()*extra_cov;
        noised_ui = orign_u(i) + BiasGen(interped_data(i,1),0.2*bad_gnss_area(idx_bad,5),2) + randn()*extra_cov;
        [noised_data(i,2),noised_data(i,3),noised_data(i,4)] = ...
            enu2geodetic(noised_ei, noised_ni, noised_ui,...
            interped_data(1,2),interped_data(1,3),interped_data(1,4),wgs84Ellipsoid);
    elseif in_good_gnss_area
        extra_cov = interped_data(i,25) * good_cov_multipler;
        noised_data(i,25) = extra_cov + good_gnss_area(idx_good,5) + noised_data(i,25);
        noised_ei = orign_e(i) + BiasGen(interped_data(i,1),good_gnss_area(idx_good,5),1) + randn()*extra_cov;
        noised_ni = orign_n(i) + BiasGen(interped_data(i,1),good_gnss_area(idx_good,5),1) + randn()*extra_cov;
        noised_ui = orign_u(i) + BiasGen(interped_data(i,1),0.2*good_gnss_area(idx_good,5),2) + randn()*extra_cov;
        [noised_data(i,2),noised_data(i,3),noised_data(i,4)] = ...
            enu2geodetic(noised_ei, noised_ni, noised_ui,...
            interped_data(1,2),interped_data(1,3),interped_data(1,4),wgs84Ellipsoid);
    else
        extra_cov = interped_data(i,25) * normal_cov_multipler;
        noised_data(i,25) = extra_cov + normal_bias + noised_data(i,25);
        noised_ei = orign_e(i) + BiasGen(interped_data(i,1),normal_bias,0) + randn()*extra_cov;
        noised_ni = orign_n(i) + BiasGen(interped_data(i,1),normal_bias,1) + randn()*extra_cov;
        noised_ui = orign_u(i) + BiasGen(interped_data(i,1),0.2*normal_bias,2) + randn()*extra_cov;
        [noised_data(i,2),noised_data(i,3),noised_data(i,4)] = ...
            enu2geodetic(noised_ei, noised_ni, noised_ui,...
            interped_data(1,2),interped_data(1,3),interped_data(1,4),wgs84Ellipsoid);
    end
    at_bad_edge = xor(last_pt_in_bad_area,in_bad_gnss_area);
    at_good_edge = xor(last_pt_in_good_area,in_good_gnss_area);
    if at_bad_edge && i~=1 && i~= length(noised_data) % in edge of bad area
        edge_index = [edge_index; i 1];
    elseif at_good_edge && i~=1 && i~= length(noised_data) % in edge of good area
        edge_index = [edge_index; i 2];
    end
    last_pt_in_bad_area = in_bad_gnss_area;
    last_pt_in_good_area = in_good_gnss_area;
    str=['gnss 差值加噪声: ',num2str(100*i/length(noised_data)),'%'];
    waitbar(i/length(noised_data),bar,str);
end
% smooth the edge
smooth_len = 100;
for j = 1:length(gnssdata_col_idx)
    data_col_idx = gnssdata_col_idx(j);
    for i=1:length(edge_index)
            data_idx = edge_index(i,1);
            if (edge_index(i,2) == 1)
                smooth_len = 100;
            elseif (edge_index(i,2) == 2)
                smooth_len = 30;
            end
            if ( data_idx -smooth_len -sample_size < 1 &&...
                    data_idx + smooth_len + sample_size < length(noised_data))
                y = [ noised_data( data_idx-1, data_col_idx);...
                      noised_data( data_idx + smooth_len : data_idx +smooth_len +sample_size, data_col_idx)];
                x = [ noised_data( data_idx-1, 1);...
                      noised_data( data_idx + smooth_len : data_idx +smooth_len +sample_size, 1)];
                num = smooth_len; 
                xp = noised_data( data_idx : data_idx + smooth_len - 1, 1);
                noised_data( data_idx :  + smooth_len - 1,...
                    data_col_idx) = interp1(x,y,xp,'PCHIP');
            elseif ( data_idx -smooth_len -sample_size > 1 &&...
                     data_idx + smooth_len +sample_size > length(noised_data))
                y = [ noised_data( data_idx-1 -smooth_len -sample_size : data_idx -1 -smooth_len, data_col_idx);...
                      noised_data( data_idx, data_col_idx)];
                x = [ noised_data( data_idx-1 -smooth_len -sample_size : data_idx -1 -smooth_len, 1);...
                      noised_data( data_idx, 1)];
                num = smooth_len; 
                xp = noised_data( data_idx -smooth_len : data_idx - 1, 1);
                noised_data( data_idx -smooth_len : data_idx - 1,...
                    data_col_idx) = interp1(x,y,xp,'PCHIP');
            else
                y = [ noised_data( data_idx-1 -smooth_len -sample_size : data_idx -1 -smooth_len, data_col_idx);...
                      noised_data( data_idx + smooth_len : data_idx +smooth_len +sample_size, data_col_idx)];
                x = [ noised_data( data_idx-1 -smooth_len -sample_size : data_idx -1 -smooth_len, 1);...
                      noised_data( data_idx + smooth_len : data_idx +smooth_len +sample_size, 1)];
                num = 2*smooth_len; 
                xp = noised_data( data_idx -smooth_len : data_idx + smooth_len - 1, 1);
                noised_data( data_idx -smooth_len : data_idx + smooth_len - 1,...
                    data_col_idx) = interp1(x,y,xp,'PCHIP');
            end
    end
end
[noised_e, noised_n, noised_u] = geodetic2enu(noised_data(:,2),noised_data(:,3),noised_data(:,4),...
    interped_data(1,2),interped_data(1,3),interped_data(1,4),wgs84Ellipsoid);

    figure(gnss_fig_h);
    subplot(2,3,1);plot(noised_data(:,1), noised_data(:,2), 'k.');title('lat');hold on;
    subplot(2,3,2);plot(noised_data(:,1), noised_data(:,3), 'k.');title('lon');hold on;
    subplot(2,3,4);plot(noised_data(:,1), noised_data(:,4), 'k.');title('alt');hold on;
    subplot(2,3,5);plot(noised_data(:,1), noised_data(:,25), 'k.');title('cov');hold on;
    subplot(2,3,[3,6]);
        plot3(noised_e,noised_n,noised_u,'k'); axis equal; view(0,90);title('traj');hold on;
        for i=1:length(bad_gnss_area)
            viscircles(bad_gnss_area(i,1:2),bad_gnss_area(i,4),'Color','r');hold on;
        end;
        for i=1:length(good_gnss_area)
            viscircles(good_gnss_area(i,1:2),good_gnss_area(i,4),'Color','g');hold on;
        end;
close(bar);







