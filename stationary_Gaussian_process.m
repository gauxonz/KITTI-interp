function [field1,field2,tx,ty]=stationary_Gaussian_process(m,n,rho)
% simulating stationary Gaussian field over an 'm' times 'n' grid
% INPUT:   
%          - 'm' and 'n' for evaluating the field over the m*n grid;
%             note that size of covariance matrix is m^2*n^2;
%          - scalar function rho(h), where 'h' is a two dimensional vector  
%            input and cov(X_t,Y_s)=rho(t-s) is the cov. function of a  
%            2-dimensional stationary Gaussian field; see reference below;
% OUTPUT:  
%          - two statistically independent fields 'field1' and 'field2'
%            over the m*n grid;
%          - vectors 'tx' and 'ty' so that the field is plotted via
%                     imagesc(tx,ty,field1)             
% Example:  
% rho=@(h)((1-h(1)^2/50^2-h(1)*h(2)/(15*50)-h(2)^2/15^2)...
%  *exp(-(h(1)^2/50^2+h(2)^2/15^2))); % define covariance function
%  stationary_Gaussian_process(512,384,rho); % plot when no output wanted   

%% Reference:
% Kroese, D. P., & Botev, Z. I. (2015). Spatial Process Simulation.
% In Stochastic Geometry, Spatial Statistics and Random Fields(pp. 369-404)
% Springer International Publishing, DOI: 10.1007/978-3-319-10064-7_12

tx=[0:n-1]; ty=[0:m-1]; % create grid for field
Rows=zeros(m,n); Cols=Rows;
for i=1:n % sample covariance function at grid points;
    for j=1:m
        Rows(j,i)=rho([tx(i)-tx(1),ty(j)-ty(1)]); % rows of blocks of cov matrix
        Cols(j,i)=rho([tx(1)-tx(i),ty(j)-ty(1)]); % columns of blocks of cov matrix
    end
end
% create the first row of the block circulant matrix with circular blocks
% and store it as a matrix suitable for fft2;
BlkCirc_row=[Rows, Cols(:,end:-1:2);
    Cols(end:-1:2,:), Rows(end:-1:2,end:-1:2)];
% compute eigen-values
lam=real(fft2(BlkCirc_row))/(2*m-1)/(2*n-1);
if abs(min(lam(lam(:)<0)))>10^-15
    error('Could not find positive definite embedding!')
else
    lam(lam(:)<0)=0; lam=sqrt(lam);
end
% generate field with covariance given by block circular matrix
F=fft2(lam.*complex(randn(2*m-1,2*n-1),randn(2*m-1,2*n-1)));
F=F(1:m,1:n); % extract subblock with desired covariance
field1=real(F); field2=imag(F); % two independent fields with desired covariance
if nargout==0
    figure
    imagesc(tx,ty,field1), colormap bone
figure
    imagesc(tx,ty,field2), colormap bone
end

