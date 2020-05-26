% interp and adjust KITTI
clearvars;close all;clc;

kitti_set = '2011_10_03';
    kitti_subset = '0027'; % 00
        kitti_subset_case = '04'; % 00
%     kitti_subset = '0034'; % 02

% kitti_set = '2011_09_29';
%     kitti_subset = '0071'; % city
    
kitti_path = '/media/joey/dataset/KITTI';
output_path = '/media/joey/dataset/KITTI';
output_name = strcat('noised-',kitti_subset_case);

output_data_path = strcat(kitti_path,'/RawDataFixed/',kitti_set,'/',...
    kitti_set,'_drive_',kitti_subset);
mkdir(output_data_path);

% Read data
ReadData;
%save 2011_10_03.mat;

% Interpolate IMU
InterpolateImu;

% Interpolate and Noise GNSS
InterpAndNoiseGnss;

% Write data
WriteData;
