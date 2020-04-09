clc;
clear;
close all;

prevFontName = get(0,'defaultAxesFontName');
set(0,'defaultAxesFontName','Arial');
resolutionScaling = 96/get(0,'ScreenPixelsPerInch');
fontSize = 16*resolutionScaling;
lineWidth = 2*resolutionScaling;
markerSize = 10*resolutionScaling;

figure
x = 1:10;
y = sin(x);
e = std(y)*ones(size(x));
errorbar(x,y,e,e,e/4,e/4,'.','LineWidth',lineWidth)
xlim([0,11])

set(gca,'TickDir','out','Fontsize',fontSize,'LineWidth',lineWidth)

xlabel('X','Fontsize',fontSize)
ylabel('Y','Fontsize',fontSize)

fig2svg('errorbar.svg');

set(0,'defaultAxesFontName',prevFontName);
