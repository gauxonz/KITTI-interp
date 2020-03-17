output_data_path = strcat(kitti_path,'/RawDataFixed/',kitti_set,'/',...
    kitti_set,'_drive_',kitti_subset);
mkdir(output_data_path);
save(strcat(output_data_path,'/',output_name,'-matlab_data.mat'));
%% fixed_data矩阵写出
bar = waitbar(0,'fixed data矩阵写出');
[nrows,~] = size(fixed_data);
file_path = strcat(output_data_path,'/oxts-fixed/data/');
mkdir(file_path);

timestamp_file = strcat(...
                    datestr(...
                        datetime(...
                            fix(imu_unsync_timestamp_sec_init + imu_unsync_timestamp_nsec_init+fixed_data(:,1)),...
                                'ConvertFrom','posixtime'),...
                            'yyyy-mm-dd HH:MM:SS.'),...
                     num2str(fix(1e9*abs(mod(imu_unsync_timestamp_nsec_init + fixed_data(:,1), 1))),'%09d'));

timestamp_posix = strcat(num2str(fix(imu_unsync_timestamp_sec_init + imu_unsync_timestamp_nsec_init+fixed_data(:,1))),...
                        '.',...
                         num2str(fix(1e9*abs(mod(imu_unsync_timestamp_nsec_init + fixed_data(:,1), 1))),'%09d'));
fid_allin1 = fopen(strcat(output_data_path,'/oxts-fixed/data.txt'),'w');
for i = 1:nrows
   fid = fopen(strcat(file_path, num2str(i-1,'%010d'), '.txt'),'w');
   fprintf(fid,'%.14g ',fixed_data(i,2:end));
   fclose(fid);
   fprintf(fid_allin1,'%s,',timestamp_posix(i,:));
   fprintf(fid_allin1,'%.14g,',fixed_data(i,2:end-1));
   fprintf(fid_allin1,'%.14g\n',fixed_data(i,end));
   str=['fixed data矩阵写出: ',num2str(100*i/nrows),'%'];
   waitbar(i/nrows,bar,str);
end
fclose(fid_allin1);

fid = fopen(strcat(output_data_path,'/oxts-fixed/timestamps.txt'),'w');
for i = 1:size(timestamp_file,1)
    fprintf(fid,'%s\n',timestamp_file(i,:));
end
fclose(fid);

close(bar);
%% interped_data矩阵写出
bar = waitbar(0,'interp data矩阵写出');
[nrows,~] = size(interped_data);
file_path = strcat(output_data_path,'/oxts-interped/data/');
mkdir(file_path);

timestamp_file = strcat(...
                    datestr(...
                        datetime(...
                            fix(imu_unsync_timestamp_sec_init + imu_unsync_timestamp_nsec_init+interped_data(:,1)),...
                                'ConvertFrom','posixtime'),...
                            'yyyy-mm-dd HH:MM:SS.'),...
                     num2str(fix(1e9*abs(mod(imu_unsync_timestamp_nsec_init + interped_data(:,1), 1))),'%09d'));
timestamp_posix = strcat(num2str(fix(imu_unsync_timestamp_sec_init + imu_unsync_timestamp_nsec_init+interped_data(:,1))),...
                        '.',...
                         num2str(fix(1e9*abs(mod(imu_unsync_timestamp_nsec_init + interped_data(:,1), 1))),'%09d'));
                     
fid_allin1 = fopen(strcat(output_data_path,'/oxts-interped/data.txt'),'w');                     
for i = 1:nrows
   fid = fopen(strcat(file_path, num2str(i-1,'%010d'), '.txt'),'w');
   fprintf(fid,'%.14g ',interped_data(i,2:end));
   fclose(fid);
   fprintf(fid_allin1,'%s,',timestamp_posix(i,:));
   fprintf(fid_allin1,'%.14g,',interped_data(i,2:end-1));
   fprintf(fid_allin1,'%.14g\n',interped_data(i,end));
   str=['interp data矩阵写出: ',num2str(100*i/nrows),'%'];
   waitbar(i/nrows,bar,str);
end
fclose(fid_allin1);

fid = fopen(strcat(output_data_path,'/oxts-interped/timestamps.txt'),'w');
for i = 1:size(timestamp_file,1)
    fprintf(fid,'%s\n',timestamp_file(i,:));
end
fclose(fid);

close(bar);
%% interped_data矩阵写出
bar = waitbar(0,'noised data矩阵写出');
[nrows,~] = size(noised_data);
file_path = strcat(output_data_path,'/oxts-',output_name,'/data/');
mkdir(file_path);

timestamp_file = strcat(...
                    datestr(...
                        datetime(...
                            fix(imu_unsync_timestamp_sec_init + imu_unsync_timestamp_nsec_init+noised_data(:,1)),...
                                'ConvertFrom','posixtime'),...
                            'yyyy-mm-dd HH:MM:SS.'),...
                     num2str(fix(1e9*abs(mod(imu_unsync_timestamp_nsec_init + noised_data(:,1), 1))),'%09d'));
timestamp_posix = strcat(num2str(fix(imu_unsync_timestamp_sec_init + imu_unsync_timestamp_nsec_init+noised_data(:,1))),...
                        '.',...
                         num2str(fix(1e9*abs(mod(imu_unsync_timestamp_nsec_init + noised_data(:,1), 1))),'%09d'));
  
fid_allin1 = fopen(strcat(output_data_path,'/oxts-',output_name,'/data.txt'),'w');
for i = 1:nrows
   fid = fopen(strcat(file_path, num2str(i-1,'%010d'), '.txt'),'w');
   fprintf(fid,'%.14g ',noised_data(i,2:end));
   fclose(fid);
   fprintf(fid_allin1,'%s,',timestamp_posix(i,:));
   fprintf(fid_allin1,'%.14g,',noised_data(i,2:end-1));
   fprintf(fid_allin1,'%.14g\n',noised_data(i,end));
   str=['noised data矩阵写出: ',num2str(100*i/nrows),'%'];
   waitbar(i/nrows,bar,str);
end
fclose(fid_allin1);


fid = fopen(strcat(output_data_path,'/oxts-',output_name,'/timestamps.txt'),'w');
for i = 1:size(timestamp_file,1)
    fprintf(fid,'%s\n',timestamp_file(i,:));
end
fclose(fid);

close(bar);