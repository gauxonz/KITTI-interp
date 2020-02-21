% interp and adjust KITTI
clearvars;close all;clc;
kitti_set = '2011_10_03';
kitti_subset = '0027';
kitti_path = '/media/joey/dataset/KITTI';
output_path = '/media/joey/dataset/KITTI';
output_name = 'noised-03';
% Read data
ReadData;
%save 2011_10_03.mat;

% Interpolate IMU
InterpolateImu;

% Interpolate and Noise GNSS
InterpAndNoiseGnss;

% Write data
WriteData;
