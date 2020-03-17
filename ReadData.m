%% set path
%imu data path: we use the raw, unsynced data, which have high-rate but
%biased imu data
unsynced_data_path = strcat(kitti_path,'/RawDataUnsync/',kitti_set,'/',...
    kitti_set,'_drive_',kitti_subset,'_extract');
%cam data path: we use the raw, synced data, which have corrected timeline
%and bad frame removed
synced_data_path = strcat(kitti_path,'/RawData/',kitti_set,'/',...
    kitti_set,'_drive_',kitti_subset,'_sync');

bar = waitbar(0,'开始读取数据');
%% unsynced image data
waitbar(0,bar,'1/4: unsynced image');
img0_unsync_path = strcat(unsynced_data_path,'/image_00');

img_unsync_timestamp_raw = importdata(strcat(img0_unsync_path,'/','timestamps.txt'));
waitbar(100,bar,'1/4: unsynced image');
img_unsync_timestamp_sec = posixtime(...
                    datetime(   strcat(img_unsync_timestamp_raw.textdata(:,1),':',...
                                num2str(img_unsync_timestamp_raw.data(:,1)),':',...
                                num2str(fix(img_unsync_timestamp_raw.data(:,2))))...
                            )...
                         );
                     
img_unsync_timestamp_nsec = abs(rem(img_unsync_timestamp_raw.data(:,2), 1));
img_unsync_timestamp_sec_init = img_unsync_timestamp_sec(1);
img_unsync_timestamp_nsec_init = img_unsync_timestamp_nsec(1);
img_unsync_timestamp = (img_unsync_timestamp_sec - img_unsync_timestamp_sec_init)...
                + (img_unsync_timestamp_nsec - img_unsync_timestamp_nsec_init);

%% unsynced imu data
waitbar(0,bar,'2/4: reading unsynced imu');
imu_unsync_data_path_base = strcat(unsynced_data_path,'/oxts');
imu_unsync_data_path = strcat(imu_unsync_data_path_base,'/data');

imu_unsync_data_list = dir([strcat(imu_unsync_data_path,'/'), '*.txt']);
imu_file_len = length(imu_unsync_data_list);
imu_unsync_data= zeros(imu_file_len, 30);

for n=1:imu_file_len
    str = strcat(imu_unsync_data_path, '/', imu_unsync_data_list(n).name);
    validation_data = dlmread(str);
    imu_unsync_data(n,:) = validation_data;
    str=['2/4: reading unsynced imu ',num2str(100*n/imu_file_len),'%'];
    waitbar(n/imu_file_len,bar,str);
end
imu_unsync_timestamp_raw = importdata(strcat(imu_unsync_data_path_base,'/','timestamps.txt'));

imu_unsync_timestamp_sec = posixtime(...
                    datetime(   strcat(imu_unsync_timestamp_raw.textdata(:,1),':',...
                                num2str(imu_unsync_timestamp_raw.data(:,1)),':',...
                                num2str(fix(imu_unsync_timestamp_raw.data(:,2))))...
                            )...
                         );
                     
imu_unsync_timestamp_nsec = abs(rem(imu_unsync_timestamp_raw.data(:,2), 1));
imu_unsync_timestamp_sec_init = imu_unsync_timestamp_sec(1);
imu_unsync_timestamp_nsec_init = imu_unsync_timestamp_nsec(1);

imu_unsync_timestamp = (imu_unsync_timestamp_sec - imu_unsync_timestamp_sec_init)...
                + (imu_unsync_timestamp_nsec - imu_unsync_timestamp_nsec_init);
imu_unsync_data = [imu_unsync_timestamp, imu_unsync_data];


%% synced image data
waitbar(0,bar,'3/4: synced image');
img0_sync_path = strcat(synced_data_path,'/image_00');
img_sync_timestamp_raw = importdata(strcat(img0_sync_path,'/','timestamps.txt'));
waitbar(100,bar,'3/4: synced image');
img_sync_timestamp_sec = posixtime(...
                    datetime(   strcat(img_sync_timestamp_raw.textdata(:,1),':',...
                                num2str(img_sync_timestamp_raw.data(:,1)),':',...
                                num2str(fix(img_sync_timestamp_raw.data(:,2))))...
                            )...
                         );
                     
img_sync_timestamp_nsec = abs(rem(img_sync_timestamp_raw.data(:,2), 1));
img_sync_timestamp_sec_init = img_sync_timestamp_sec(1);
img_sync_timestamp_nsec_init = img_sync_timestamp_nsec(1);

img_sync_timestamp = (img_sync_timestamp_sec - img_sync_timestamp_sec_init)...
                + (img_sync_timestamp_nsec - img_sync_timestamp_nsec_init);
%% synced imu data
waitbar(0,bar,'4/4: synced imu');
imu_sync_data_path_base = strcat(synced_data_path,'/oxts');
imu_sync_data_path = strcat(imu_sync_data_path_base,'/data');

imu_sync_data_list = dir([strcat(imu_sync_data_path,'/'), '*.txt']);
imu_sync_file_len = length(imu_sync_data_list);
imu_sync_data= zeros(imu_sync_file_len, 30);

synced_bar = waitbar(0,'4/4: reading  synced imu');
for n=1:imu_sync_file_len
    str = strcat(imu_sync_data_path, '/', imu_sync_data_list(n).name);
    validation_data = dlmread(str);
    imu_sync_data(n,:) = validation_data;
    str=['4/4: reading  synced imu ',num2str(100*n/imu_sync_file_len),'%'];
    waitbar(n/imu_sync_file_len,bar,str);
end
imu_sync_timestamp_raw = importdata(strcat(imu_sync_data_path_base,'/','timestamps.txt'));

imu_sync_timestamp_sec = posixtime(...
                    datetime(   strcat(imu_sync_timestamp_raw.textdata(:,1),':',...
                                num2str(imu_sync_timestamp_raw.data(:,1)),':',...
                                num2str(fix(imu_sync_timestamp_raw.data(:,2))))...
                            )...
                         );
                     
imu_sync_timestamp_nsec = abs(rem(imu_sync_timestamp_raw.data(:,2), 1));
imu_sync_timestamp_sec_init = imu_sync_timestamp_sec(1);
imu_sync_timestamp_nsec_init = imu_sync_timestamp_nsec(1);

imu_sync_timestamp = (imu_sync_timestamp_sec - imu_sync_timestamp_sec_init)...
                + (imu_sync_timestamp_nsec - imu_sync_timestamp_nsec_init);
imu_sync_data = [imu_sync_timestamp, imu_sync_data];
close(bar);
%%

clearvars -except kitti_set kitti_subset kitti_path output_path output_name...
    imu_unsync_data imu_unsync_timestamp imu_unsync_timestamp_sec_init imu_unsync_timestamp_nsec_init ...
    imu_sync_data imu_sync_timestamp imu_sync_timestamp_sec_init imu_sync_timestamp_nsec_init...
    img_unsync_timestamp_sec_init img_unsync_timestamp_nsec_init img_unsync_timestamp...
    img_sync_timestamp_sec_init img_sync_timestamp_nsec_init img_sync_timestamp
    



