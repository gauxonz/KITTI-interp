
prevFontName = get(0,'defaultAxesFontName');
set(0,'defaultAxesFontName','Arial');
resolutionScaling = 96/get(0,'ScreenPixelsPerInch');
fontSize = 16*resolutionScaling;
lineWidth = 2*resolutionScaling;
markerSize = 10*resolutionScaling;

figure
plot(0:10000,0:10000,'LineWidth',lineWidth)
% plot(0:100000,0:100000,'LineWidth',lineWidth)

%  % 2-d - no rotation control
   set(gca,'TickDir','out') % OK!
%  % 2-d x axis - top - no rotation
%   set(gca,'TickDir','out','XAxisLocation','top') % OK!
%  % 2-d y axis - right - no rotation
%   set(gca,'TickDir','out','YAxisLocation','right') % OK!


%  % let's rotate one by one, first x
%  % 2-d x axis - positive rotation
%  set(gca,'TickDir','out','XTickLabelRotation',45) % Ok!
%  % 2-d x axis - top - positive rotation
%  set(gca,'TickDir','out','XAxisLocation','top','XTickLabelRotation',45) % Ok!
%  % 2-d x axis - negative rotation
%  set(gca,'TickDir','out','XTickLabelRotation',-45) % Ok!
%  % 2-d x axis - top - negative rotation
%  set(gca,'TickDir','out','XAxisLocation','top','XTickLabelRotation',-45) % Ok!

%  % let's rotate one by one, now y
%  % 2-d y axis - positive rotation
%  set(gca,'TickDir','out','YTickLabelRotation',45) % Ok!
%  % 2-d y axis - right - positive rotation
%  set(gca,'TickDir','out','YAxisLocation','right','YTickLabelRotation',45) % Ok!
%  % 2-d y axis - negative rotation
%  set(gca,'TickDir','out','YTickLabelRotation',-45) % Ok!
%  % 2-d y axis - right - negative rotation
%  set(gca,'TickDir','out','YAxisLocation','right','YTickLabelRotation',-45) % Ok!

set(gca,'Fontsize',fontSize,'LineWidth',lineWidth)

xlabel('X','Fontsize',fontSize)
ylabel('Y','Fontsize',fontSize)

fig2svg('plot2d.svg'); %  ,'',1);

set(0,'defaultAxesFontName',prevFontName);
