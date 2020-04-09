clear;
close all;
clc;

% issue #18 fixed

figure
hold on
yyaxis left
plot(rand(3))
yyaxis right
plot(rand(3))
fig2svg('yyaxis.svg')
