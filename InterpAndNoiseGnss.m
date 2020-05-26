%% parameters and models
switch kitti_set
    case '2011_10_03'
        switch kitti_subset
            case '0027' % sub case 1:begin with bad gnss
                switch kitti_subset_case
                    case '01' % sub case 1: begin with bad gnss
                        regular_std_level = 0.5; % meter
                        regular_bias = 0.5;
                        % WN-L: white noise level, in meter. white noise is
                        % given by :
                        % GWN((WN-L / mean(orignal_std)) * orignal_std(i))
                        % set to 0 to add no addtional noise (in good area)
                        % MP-B: multipath bias level
                        %                   x	y    z  rd  WN-L MP-B      
                        bad_gnss_area =	[	24	46	 0	60	5	15;
                                            126	242	 0	20	3   5;
                                            167	144	 0   50  4   9;
                                            277	358	 0   30  5   8;
                                            416	248	 0   50  4   10;
                                            240	-73	 0   60  3   4;
                                            -13	261	 0   50  5   7];
                                        
                        good_gnss_area = [	110	368	 0	50	0   0;
                                            -88	166	 0	50	0   0;
                                            287	199	 0	50	0	0];
                        
                    case '02' % sub case 2: begin with good gnss
                        regular_std_level = 0.5; % meter
                        regular_bias = 0.5;
                        bad_gnss_area =	[   126	242	 0	20	5   10;
                                            277	358	 0   30  3   5;
                                            110	368	 0	50	4   11;
                                            -88	166	 0	50	2   8;
                                            287	199	 0	50	5   5;
                                            -13	261	 0   50  3   7];

                                        
                        good_gnss_area = [	27	52	 0	60	0   0;
                                            167	144	 0   50  0   0;
                                            416	248	 0   50  0   0;
                                            240	-73	 0   60  0   0];
                   	case '03' % sub case 3: one big bad, begin with bad gnss
                        regular_std_level = 0.5; % meter
                        regular_bias = 0.5;
                        bad_gnss_area =	[	72  143	 0	200	5   5];

                        good_gnss_area = [	0	0	 0	0	0   0];
                        
                    case '04' % sub case 3: one big bad, begin with bad gnss
                        regular_std_level = 0.5; % meter
                        regular_bias = 0.5;
                        
                        bad_gnss_area =	[	248	297	 0	200	5   5];
                        good_gnss_area = [	0	0	 0	0   0   0];
                end
            
             case '0034'
                regular_std_level = 0.5; % meter
                regular_bias = 0.5;
                bad_gnss_area =	[	741	602  0	30	5	12;
                                    290	275	 0	30	5	7;
                                    618	153  0	50  3   8;
                                    222	-137 0	30	4   9];
                                
                good_gnss_area = [	925	341	50	50	0   0;
                                    22	31	0	50	0   0;
                                    516	425 30  60  0   0];
        end
end
% generate Random Vector Field to simulate Multu-path Bias

[orign_e, orign_n, orign_u] = geodetic2enu(fixed_data(:,2),fixed_data(:,3),fixed_data(:,4),...
    fixed_data(1,2),fixed_data(1,3),fixed_data(1,4),wgs84Ellipsoid);

grid_size = 0.2; % [meter]
c1 = 150;
c2 = c1;

time_corr=1; % 1s corralation
MultipathDetectCo = 0.8;

plot_GRF = false;
save_figs = true;

minx = floor(min(orign_e));
maxx = ceil(max(orign_e));

miny = floor(min(orign_n));
maxy = ceil(max(orign_n));

x = minx-grid_size:grid_size:maxx+grid_size;
y = miny-grid_size:grid_size:maxy+grid_size;

rho=@(h)((1-h(1)^2/c1^2-h(1)*h(2)/(c2*c1)-h(2)^2/c2^2)...
 *exp(-(h(1)^2/c1^2+h(2)^2/c2^2))); % define covariance function
rng(3)
[FF1,FF2,tx,ty] = stationary_Gaussian_process(length(y),length(x),rho); % plot when no output wanted  
FF1 = FF1';
FF2 = FF2';


%% plot orign data first



gnss_fig_h = figure;
    gnss_fig_h.Name = 'GNSS interpolation and noise';
    figure(gnss_fig_h);
    %title('GNSS interpolation and noise','FontSize',13,...
    %    'FontName','Times New Roman');
    subplot(2,2,1);plot(fixed_data(:,1), fixed_data(:,2), 'k.','MarkerSize',1);title('latitude');hold on;
    subplot(2,2,2);plot(fixed_data(:,1), fixed_data(:,3), 'k.','MarkerSize',1);title('lontitude');hold on;
    subplot(2,2,3);plot(fixed_data(:,1), fixed_data(:,4), 'k.','MarkerSize',1);title('alttitude');hold on;
    subplot(2,2,4);plot(fixed_data(:,1), fixed_data(:,25), 'k.','MarkerSize',1);title('covariance');hold on;
    
gnss_traj_fig_h = figure;
    gnss_traj_fig_h.Name = 'GNSS trajectory';
    gnss_orign_p = plot3(orign_e,orign_n,orign_u,'k'); axis equal; view(0,90);
    %title(strcat('Simulated intermittent GNSS-denied environment case',{' '},num2str(str2num(kitti_subset_case))),'FontSize',13,...
    %    'FontName','Times New Roman');
    hold on;
    if plot_GRF
        g = 50;
        qv_p = quiver(x(1:g:end),y(1:g:end),FF1(1:g:end,1:g:end)',FF2(1:g:end,1:g:end)',...
        'Color',[0.5,0.5,0.5,0.5],'AutoScaleFactor',1.5);
        %title('Simulating GNSS multipath bias with GRF','FontSize',13,...
        %'FontName','Times New Roman');
    end

nodata_index = find(isnan(orign_e));
bp= find((nodata_index(2:end)-nodata_index(1:end-1))>1);
bp_begin_idx = nodata_index([1; bp+1]);
bp_length = [bp(1);bp(2:end)-bp(1:end-1);...
    nodata_index(end)-bp_begin_idx(end)+1];

bar = waitbar(0,'Noising GNSS');
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
            subplot(221);plot(xp{i}, yp{i,1}, 'b.','MarkerSize',1);hold on;
            subplot(222);plot(xp{i}, yp{i,2}, 'b.','MarkerSize',1);hold on;
            subplot(223);plot(xp{i}, yp{i,3}, 'b.','MarkerSize',1);hold on;
            subplot(224);plot(xp{i}, cov_p{i}, 'b.','MarkerSize',1);hold on;
            
            figure(gnss_traj_fig_h);
            gnss_interp_p =plot3(interp_e,interp_n,interp_u,'Color',[153, 153, 153]/255); axis equal; view(0,90);hold on;
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

data_leng = length(noised_data);
gt_mean_std = mean(interped_data(:,25));
gt_mean_dt = mean(interped_data(2:end,1)-interped_data(1:end-1,1));

a = floor(time_corr/gt_mean_dt);
rho=@(h)((1-h(1)^2/a^2-h(1)*h(2)/a-h(2)^2)...
 *exp(-(h(1)^2/a^2+h(2)^2))); % define covariance function
[e_noise,n_noise,~,~] = stationary_Gaussian_process(1,data_leng,rho); % plot when no output wanted  
[u_noise,~,~,~] = stationary_Gaussian_process(1,data_leng,rho); % plot when no output wanted  
GM_noise_base = [e_noise' n_noise' u_noise'];


for i = 1:floor(data_leng)
    % check if in bad gnss area
    [db, idx_bad] = min(sqrt(sum((bad_gnss_area(:,1:3)-[orign_e(i) orign_n(i) orign_u(i)]).^2,2)));
    in_bad_gnss_area = db < bad_gnss_area(idx_bad,4);
    
    [dg, idx_good] = min(sqrt(sum((good_gnss_area(:,1:3)-[orign_e(i) orign_n(i) orign_u(i)]).^2,2)));
    in_good_gnss_area = dg < good_gnss_area(idx_good,4);
    
    Xidx = floor((orign_e(i)-minx)/grid_size);
    Yidx = floor((orign_n(i)-miny)/grid_size);
    
    if in_bad_gnss_area
        WhiteNoiseLevel = interped_data(i,25) * (bad_gnss_area(idx_bad,5) / gt_mean_std);
        BiasLevel = bad_gnss_area(idx_bad,6);
    elseif in_good_gnss_area
        WhiteNoiseLevel = interped_data(i,25) * (good_gnss_area(idx_good,5) / gt_mean_std);
        BiasLevel = good_gnss_area(idx_good,6);
    else
        WhiteNoiseLevel = interped_data(i,25) * (regular_std_level / gt_mean_std);
        BiasLevel = regular_bias;
    end
    %WhiteNoiseLevel = 0;
    MP_Bias = BiasLevel/1.4142 * [FF1(Xidx,Yidx) FF2(Xidx,Yidx)];
    
    noised_data(i,25) = WhiteNoiseLevel + MultipathDetectCo * BiasLevel + interped_data(i,25);
    noised_ei = orign_e(i) + GM_noise_base(i,1)*WhiteNoiseLevel+ MP_Bias(1);
    noised_ni = orign_n(i) + GM_noise_base(i,2)*WhiteNoiseLevel+ MP_Bias(2);
    noised_ui = orign_u(i) + GM_noise_base(i,3)*WhiteNoiseLevel;
    [noised_data(i,2),noised_data(i,3),noised_data(i,4)] = ...
        enu2geodetic(noised_ei, noised_ni, noised_ui,...
        interped_data(1,2),interped_data(1,3),interped_data(1,4),wgs84Ellipsoid);
        
    at_bad_edge = xor(last_pt_in_bad_area,in_bad_gnss_area);
    at_good_edge = xor(last_pt_in_good_area,in_good_gnss_area);
    if at_bad_edge && i~=1 && i~= length(noised_data) % in edge of bad area
        edge_index = [edge_index; i 1];
    elseif at_good_edge && i~=1 && i~= length(noised_data) % in edge of good area
        edge_index = [edge_index; i 2];
    end
    last_pt_in_bad_area = in_bad_gnss_area;
    last_pt_in_good_area = in_good_gnss_area;
    str=['Noising GNSS: ',num2str(100*i/length(noised_data)),' percent'];
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
                
                y_std = [ noised_data( data_idx-1, 25);...
                      noised_data( data_idx + smooth_len : data_idx +smooth_len +sample_size, 25)];
                noised_data( data_idx :  + smooth_len - 1,25) = interp1(x,y_std,xp,'linear');
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
                
                y_std = [ noised_data( data_idx-1 -smooth_len -sample_size : data_idx -1 -smooth_len, 25);...
                      noised_data( data_idx, 25)];
                noised_data( data_idx -smooth_len : data_idx - 1, 25) = interp1(x,y_std,xp,'linear');
            else
                y = [ noised_data( data_idx-1 -smooth_len -sample_size : data_idx -1 -smooth_len, data_col_idx);...
                      noised_data( data_idx + smooth_len : data_idx +smooth_len +sample_size, data_col_idx)];
                x = [ noised_data( data_idx-1 -smooth_len -sample_size : data_idx -1 -smooth_len, 1);...
                      noised_data( data_idx + smooth_len : data_idx +smooth_len +sample_size, 1)];
                num = 2*smooth_len; 
                xp = noised_data( data_idx -smooth_len : data_idx + smooth_len - 1, 1);
                noised_data( data_idx -smooth_len : data_idx + smooth_len - 1,...
                    data_col_idx) = interp1(x,y,xp,'PCHIP');
                
                y_std = [ noised_data( data_idx-1 -smooth_len -sample_size : data_idx -1 -smooth_len, 25);...
                      noised_data( data_idx + smooth_len : data_idx +smooth_len +sample_size, 25)];
                noised_data( data_idx -smooth_len : data_idx + smooth_len - 1, 25) = interp1(x,y_std,xp,'linear');
            end
    end
end
[noised_e, noised_n, noised_u] = geodetic2enu(noised_data(:,2),noised_data(:,3),noised_data(:,4),...
    interped_data(1,2),interped_data(1,3),interped_data(1,4),wgs84Ellipsoid);

    figure(gnss_fig_h);
    subplot(2,2,1);plot(noised_data(:,1), noised_data(:,2), 'r.','MarkerSize',1);hold on;
    subplot(2,2,2);plot(noised_data(:,1), noised_data(:,3), 'r.','MarkerSize',1);hold on;
    subplot(2,2,3);plot(noised_data(:,1), noised_data(:,4), 'r.','MarkerSize',1);hold on;
    subplot(2,2,4);plot(noised_data(:,1), noised_data(:,25), 'r','MarkerSize',1);hold on;

    figure(gnss_traj_fig_h);
            gnss_noise_p = plot3(noised_e,noised_n,noised_u,'Color',[0, 153, 255]/255); axis equal; view(0,90);hold on;
            for i=1:size(bad_gnss_area,1)
                %viscircles(bad_gnss_area(i,1:2),bad_gnss_area(i,4),'Color','r');hold on;
                bad_circle_p = rectangle('Position',[bad_gnss_area(i,1)-bad_gnss_area(i,4),bad_gnss_area(i,2)-bad_gnss_area(i,4),...
                    2*bad_gnss_area(i,4),2*bad_gnss_area(i,4)],'Curvature',[1 1],'EdgeColor','r','LineWidth',2);hold on;
            end;
            for i=1:size(good_gnss_area,1)
                %good_circle_p = viscircles(good_gnss_area(i,1:2),good_gnss_area(i,4),'Color','g');hold on;
                good_circle_p = rectangle('Position',[good_gnss_area(i,1)-good_gnss_area(i,4),good_gnss_area(i,2)-good_gnss_area(i,4),...
                    2*good_gnss_area(i,4),2*good_gnss_area(i,4)],'Curvature',[1 1],'EdgeColor','g','LineWidth',2);hold on;
            end;
            fake_bad_circle_p = line(NaN,NaN,'Color','w');
            fake_good_circle_p = line(NaN,NaN,'Color','w');
            if ~plot_GRF
                l = legend([gnss_orign_p gnss_noise_p fake_bad_circle_p fake_good_circle_p],...
                    'Original', 'Noised', 'Degraded area','Decent area',...
                    'Location','southeast');
            else
                l = legend([gnss_orign_p gnss_noise_p fake_bad_circle_p fake_good_circle_p, qv_p],...
                'Original', 'Noised', 'Degraded area\newline','Decent area\newline', 'GRF',...
                'Location','southeast');
            end
            l.FontSize = 10;
            l.FontName = 'Times New Roman';
            l.Position = [0.68 0.36 0.21 0.18];
            xlabel('$\mathcal{F}_{\mathcal{L}}$:X (East) [m]','Interpreter','latex',...
                'FontSize',12,'FontName','Times New Roman');
            ylabel('$\mathcal{F}_{\mathcal{L}}$:Y (North) [m]','Interpreter','latex',...
                'FontSize',12,'FontName','Times New Roman');
            set(gca, 'Color', 'w');
            set(gnss_traj_fig_h, 'Color', 'w');
            set(gnss_traj_fig_h,'PaperSize',[13 11]);
            %set(gnss_traj_fig_h,'PaperPositionMode','auto')
            if save_figs
                mkdir(strcat(output_data_path,'/oxts-',output_name));
                %export_fig(strcat(output_path,'/oxts-',output_name,'/',output_name,'.eps'));
                %print('-depsc', strcat(output_data_path,'/oxts-',output_name,'/',output_name,'.eps'));
                %print('-depsc','-tiff', '-r100', '-painters', strcat(output_data_path,'/oxts-',output_name,'/',output_name,'.eps'));
                print('-dpdf','-painters',strcat(output_data_path,'/oxts-',output_name,'/',output_name,'.pdf'));
                %fig2svg
                %export_fig(strcat(output_data_path,'/oxts-',output_name,'/',output_name,'.svg'));
            end
close(bar);






