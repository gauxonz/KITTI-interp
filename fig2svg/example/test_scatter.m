clear;
close all;
clc;

dbg = 0;

figure
x = [linspace(0,3*pi,100) nan linspace(0,3*pi,100)];
y = [cos(x) + rand(1,numel(x))];
z = [sin(x) + rand(1,numel(x))];

sz = 80; % [];
c = linspace(1,10,length(x));

% scatter(x,y,sz,c,'o','LineWidth',1.5)
% scatter(x,y,sz,c,'o','filled','LineWidth',1.5)
% scatter(x,y,sz,c,'o','filled','MarkerEdgeColor',[.4 .4 .4],'LineWidth',1.5)
scatter(x,y,sz,c,'o','filled','MarkerFaceAlpha',0.3,'MarkerEdgeColor','flat','MarkerEdgeAlpha',0.7,'LineWidth',1.5)

% scatter(x,y,sz,c,'d','LineWidth',1.5)
% scatter(x,y,sz,c,'d','filled','LineWidth',1.5)
% scatter(x,y,sz,c,'d','filled','MarkerEdgeColor',[.4 .4 .4],'LineWidth',1.5)

% scatter(x,y,sz,c,'^','filled','MarkerFaceAlpha',0.3,'MarkerEdgeColor','flat','MarkerEdgeAlpha',0.7,'LineWidth',1.5)

% scatter3 works too at not extra cost!
% scatter3(x,y,z,sz,c,'o','filled','MarkerEdgeColor',[.4 .4 .4],'LineWidth',1.5)

if dbg
  fig2svg('scatter_example.svg','',1,'',3)
else
  fig2svg('scatter_example.svg','','','',3)
end
