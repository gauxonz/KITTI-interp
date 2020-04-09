%   corr.name = 'exp';
%   corr.c0 = [10 10]; % anisotropic correlation
%   corr.c1 = [10 ]; % anisotropic correlation
% 
%   %x = linspace(-1,1,11);
%   x = -300:5:300;
%   [X,Y] = meshgrid(x,x); mesh = [X(:) Y(:)]; % 2-D mesh
% 
%   % set a spatially varying variance (must be positive!)
%   corr.sigma = cos(pi/100*mesh(:,1)).*(sin(2*pi/100*mesh(:,2)))+10;
% %sin(2*pi/100*input + rand()*50)
% 
%   [F,KL] = randomfield(corr,mesh,...
%               'trunc', 10);
% 
%   % plot the realization
%     figure
%   surf(X,Y,reshape(F,121,121)); view(2); colorbar;
%   
%   FF = reshape(F,121,121);
%   [Fx, Fy] = gradient(FF);
%   figure
%   quiver(X,Y,Fx,Fy)

% [Y,FOGM] = SimulateINSData([1 1 1 1 1],0.01,100000,0);
% figure
% plot([0.01:0.01:1000],Y)
% figure
% plot([0.01:0.01:1000],randn())
% grid_size = 5; %meter
% corr.name = 'exp';
% corr.c0 = [11 11]; % anisotropic correlation, in meter
% minx = floor(min(min(orign_e),min(orign_n)));
% maxx = ceil(max(max(orign_e),max(orign_n)));
% x = minx:grid_size:maxx;
% [X,Y] = meshgrid(x,x); mesh = [X(:) Y(:)]; % 2-D mesh
% mesh_len = length(mesh(:,1));
% % set a spatially varying variance (must be positive!)
% % F1 = -2.0 * mod(mesh(:,2), 2.0) + 1.0;
% % F2 = -2.0 * mod(mesh(:,1), 2.0) + 1.0;
% xx = mesh(:,1);
% yy = mesh(:,2);
% F1 = (1 * sin(2*pi/60*xx + 1*3) + ...
%             1 * sin(2*pi/100*xx + 1*7)).*...
%         (1 * sin(2*pi/60*yy +1*3) + ...
%             1 * sin(2*pi/100*yy + 1*7));
% F2 = (1 * sin(2*pi/80*xx + 1*3) + ...
%             1 * sin(2*pi/200*xx + 1*7)).*...
%         (1 * sin(2*pi/80*yy + 1*3) + ...
%             1 * sin(2*pi/200*yy + 1*7));
% 
% % generate 2d-2d vector field
%       
% FF1= reshape(F1,length(x),length(x));
% figure
% surf(X,Y,FF1); view(2); colorbar;
% 
% FF2 = reshape(F2,length(x),length(x));
% figure
% surf(X,Y,FF2); view(2); colorbar;
% 
% figure
% %quiver(X(1:5:end),Y(1:5:end),FF1(1:5:end),FF2(1:5:end))
% quiver(X,Y,FF1,FF2)
a=1;
b=10;
% 
rho=@(h)((1-h(1)^2/a^2-h(1)*h(2)/(b*a)-h(2)^2/b^2)...
 *exp(-(h(1)^2/a^2+h(2)^2/b^2))); % define covariance function
[field1,field2,tx,ty] = stationary_Gaussian_process(1,1000,rho); % plot when no output wanted  
figure
%quiver(X(1:5:end),Y(1:5:end),FF1(1:5:end),FF2(1:5:end))
quiver(tx(1:5:end),ty(1:5:end),field1(1:5:end,1:5:end),field2(1:5:end,1:5:end))



