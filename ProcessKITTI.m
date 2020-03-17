% interp and adjust KITTI
clearvars;close all;clc;
kitti_set = '2011_10_03';
%     kitti_subset = '0027'; % 00
    kitti_subset = '0034'; % 02


% kitti_set = '2011_09_29';
%     kitti_subset = '0071'; % city
    
kitti_path = '/media/joey/dataset/KITTI';
output_path = '/media/joey/dataset/KITTI';
output_name = 'noised';
% Read data
ReadData;
%save 2011_10_03.mat;

% Interpolate IMU
InterpolateImu;

% Interpolate and Noise GNSS
InterpAndNoiseGnss;

% Write data
WriteData;
