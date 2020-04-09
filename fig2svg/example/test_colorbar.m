clear;
close all;
clc;

dbg = 0;
test3D = 0;
top = 0;
out = 1;

figure
if test3D
  surf(peaks)
else
  C = [0 2 4 6; 8 10 12 14; 16 18 20 22];
  imagesc(C)
end

h = colorbar;
if top
  set(h,'location','northoutside')
end
if out
  set(h,'tickdir','out')
end

if dbg
  fig2svg('colorbar_example.svg','',1)
else
  fig2svg('colorbar_example.svg')
end
