clear;
close all;
clc;

prevFontName = get(0,'defaultAxesFontName');
set(0,'defaultAxesFontName','Arial');
resolutionScaling = 96/get(0,'ScreenPixelsPerInch');
fontSize = 16*resolutionScaling;
lineWidth = 2*resolutionScaling;
markerSize = 10*resolutionScaling;

figure
hold on
set(gca,'Layer','top')
p = plot(1:10,[1:10;10:-1:1],'s-','LineWidth',lineWidth,'MarkerSize',markerSize);
[lg, lg_icons] = legend(p,{'data1','data2'},'Location','NorthEastOutside','Orientation','Vertical','Fontsize',fontSize,'Box','on','LineWidth',lineWidth);
% l = legend(p,{'data1','data2'},'Location','SouthWestOutside','Orientation','Vertical','Fontsize',fontSize,'Box','on','LineWidth',lineWidth);
xlim([1,10])
ylim([1,10])
% set(gca,'fontSize',fontSize,'lineWidth',lineWidth,'Box','off')
set(gca,'fontSize',fontSize,'lineWidth',lineWidth,'Box','on')
xlabel('X','fontSize',fontSize)
ylabel('Y','fontSize',fontSize)

% fig2svg('legend.svg','','',lg_icons,0) % no clipping
fig2svg('legend.svg','','',lg_icons,1) % box off/on dependent clipping [default]
% fig2svg('legend.svg','','',lg_icons,2) % strict axes dependent clipping
% fig2svg('legend.svg','','',lg_icons,3) % axes + data dependent clipping

saveas(gca,'legend_saveas.svg')

set(0,'defaultAxesFontName',prevFontName);
