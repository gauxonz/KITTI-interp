%%%%
clear;
close all;
% clc;
%%%%

% ToDo: playing with elevation values is a mess, also 2-d projection errors at 0, 90, etc.  giving up for now.

prevFontName = get(0,'defaultAxesFontName');
set(0,'defaultAxesFontName','Arial');
resolutionScaling = 96/get(0,'ScreenPixelsPerInch');
fontSize = 16*resolutionScaling;
lineWidth = 0.5*resolutionScaling;
markerSize = 10*resolutionScaling;

figure
[x y z] = sphere(20);
s = surface(x,y,z,'facecolor','flat','cdata',z);
set(s,'edgecolor','black','facealpha','flat','alphadata',x.*z,'LineWidth',lineWidth);
axis equal
box on
grid on

% view(3) % default 3-D view(-37.5, 30)
% view(-30, 30)
% view(30, 30)

%%% x-tick labels %%%
% x_az = -15.64; % left
% x_az = -15.63; % center
% x_az = -1; % center
% x_az = 0; % center
% x_az = 1; % center
% x_az = 15.63; % center
% x_az = 15.64; % right
% x_az = 82.87; % top
% x_az = 82.88; % middle
% x_az = 89; % right
% x_az = 90; % left
% x_az = 91; % left
% x_az = 97.12; % middle
% x_az = 97.13; % top
% x_az = 164.36; % left
% x_az = 164.37; % center
% x_az = 179; % center
% x_az = 180; % center
% x_az = 181; % center
% x_az = 195.63; % center
% x_az = 195.64; % right
% x_az = 262.87; % top
% x_az = 262.88; % middle
% x_az = 269; % right
% x_az = 270; % left
% x_az = 271; % left
% x_az = 277.12; % middle
% x_az = 277.13; % top

% view(x_az, 30);

%%% y-tick labels %%%
% x_az = -13.53; % left
% x_az = -13.52; % center
% x_az = -1; % center
% x_az = 0; % center
% x_az = 1; % center
% x_az = 13.52; % center
% x_az = 13.53; % right
% x_az = 82.87; % top
% x_az = 82.88; % middle
% x_az = 89; % right
x_az = 90; % left
% x_az = 91; % left
% x_az = 97.12; % middle
% x_az = 97.13; % top
% x_az = 166.47; % left
% x_az = 166.48; % center
% x_az = 179; % center
% x_az = 180; % center
% x_az = 181; % center
% x_az = 193.52; % center
% x_az = 193.53; % right
% x_az = 262.87; % top
% x_az = 262.88; % middle
% x_az = 277.12; % middle
% x_az = 277.13; % top
% x_az = 269; % right
% x_az = 270; % left
% x_az = 271; % left

% view(x_az - 90, 30);

%%% z-tick labels %%%

% x_az = 45; % ticks direction now ok
% x_az = 135; % ticks direction ok
% x_az = 225; % ticks direction now ok
% x_az = 315;  % ticks direction ok

x_az = 0; % ticks direction now ok
x_az = 90; % ticks direction ok
x_az = 180; % ticks direction now ok
% x_az = 270; % ticks direction ok

view(x_az, 30);

% ToDo: tick lengths are weird

if ~UIverlessthan('8.4')
  % set(gca,'XTickLabelRotation',45,'YTickLabelRotation',45,'ZTickLabelRotation',45)
end
set(gca,'Fontsize',fontSize,'LineWidth',lineWidth)
xlabel('X','Fontsize',fontSize);
ylabel('Y','Fontsize',fontSize);
zlabel('Z','Fontsize',fontSize);
title('Sphere^2 with Alpha_{Data}','Fontsize',fontSize);
fig2svg('sphere.svg');
% fig2svg('sphere.svg','',1); % debug

set(0,'defaultAxesFontName',prevFontName);
