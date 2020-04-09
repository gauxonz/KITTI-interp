clear;
close all;
clc;

set(0,'defaultAxesFontName','Arial');
resolutionScaling = 96/get(0,'ScreenPixelsPerInch');
fontSize = 16*resolutionScaling;
lineWidth = 2*resolutionScaling;

% This bars pretty  much match the ones in Matlab:
% b = bar([sort(10*rand(1,2));sort(10*rand(1,2),'descend')],1,'LineWidth',lineWidth');
% b = bar([sort(10*rand(1,3));sort(10*rand(1,3),'descend')],1,'LineWidth',lineWidth');
% b = bar([sort(10*rand(1,5));sort(10*rand(1,5),'descend')],1,'LineWidth',lineWidth');
% b = bar([sort(10*rand(1,10));sort(10*rand(1,10),'descend')],1,'LineWidth',lineWidth');
% b = bar([sort(10*rand(1,10));sort(10*rand(1,10),'descend')],0.5,'LineWidth',lineWidth');
% b = bar([sort(10*rand(1,16));sort(10*rand(1,16),'descend')],1,'LineWidth',lineWidth');
% b = bar([sort(10*rand(1,30));sort(10*rand(1,30),'descend')],1,'LineWidth',lineWidth');
% b = bar([sort(10*rand(1,10));sort(10*rand(1,10),'descend');sort(10*rand(1,10))],0.8,'LineWidth',lineWidth');

% Baseline offset and arbitrary separation
% b = bar(([0:4,8])/100,[0:4,8],0.8,'BaseValue',5,'LineWidth',lineWidth);

% ungrouped bars
figure
hold on
b1 = bar(10*rand(1,5),1,'LineWidth',lineWidth');
b1.UserData = 'ungrouped';
b2 = bar(-10*rand(1,5),1,'LineWidth',lineWidth');
b2.UserData = 'ungrouped';

% Stacked Layout
% b = bar([sort(10*rand(1,10));sort(10*rand(1,10),'descend');sort(10*rand(1,10))]',0.8,'stacked','LineWidth',lineWidth');

% TODO:
% b = bar(1:10,'horizontal','on');
% b = scatter(1:10,10:-1:1);
% b = stairs([1:10;10:-1:1]');

set(gca,'Fontsize',fontSize,'LineWidth',lineWidth)

xlabel('X','Fontsize',fontSize)
ylabel('Y','Fontsize',fontSize)
% zlabel('Z','Fontsize',fontSize)

fig2svg('bar_test.svg')
% saveas(gca,'bar_test_saveas.svg')

% fig2svg('bar_stacked.svg')
% saveas(gca,'bar_stacked_saveas.svg')
