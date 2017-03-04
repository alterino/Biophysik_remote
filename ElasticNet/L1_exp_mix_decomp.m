function [xhat,bhat,offset,residual,A] = L1_exp_mix_decomp(b,t,k,alpha,beta,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 26.05.2015


%input validation
ip = inputParser;
addRequired(ip,'b')
addRequired(ip,'t')
addRequired(ip,'k')
addRequired(ip,'alpha')
addRequired(ip,'beta')
addParamValue(ip,'k0',[])
addParamValue(ip,'hasOffset',false)
addParamValue(ip,'verbose',false)
parse(ip,b,t,k,alpha,beta,varargin{:});

k0 = ip.Results.k0;
hasOffset = ip.Results.hasOffset;
verbose = ip.Results.verbose;

%% generate decomposition matrix
%continuous kernel
[T,K] = ndgrid(t,k);
A = K.*exp(-K.*T);
% A = A./(exp(-K*min(t))-exp(-K*max(t))); %renormalize to support (left-right-tuncation)

if hasOffset
    A = [A ones(numel(t),1)]; %augmented matrix
end %if

if isempty(k0)
    k0 = zeros(numel(k),1);
end %if

%% pseudo-spectral decomposition
for idxAlpha = numel(alpha):-1:1
    xhat(:,idxAlpha) = rfss(A, b(:), ...
        ones(size(A,2),1)*alpha(idxAlpha), ...
        ones(size(A,2),1)*beta,...
        'init', k0,...
        'verbose',false);
end %for

if hasOffset
    offset = xhat(end,:);
    xhat(end,:) = [];
    A(:,end) = [];
else
    offset = [];
end %if

bhat = A*xhat;
residual = bhat - repmat(b(:),1,numel(alpha));

xhat = transpose(bsxfun(@times,transpose(xhat),k));

if verbose
    figure('Color','w'); hold on
    imagesc(log10(alpha),log10(k),xhat)
    xlabel('lg \alpha','Fontsize',20)
    set(gca,'Fontsize',20)
    ylabel('lg \offrate','Fontsize',20)
    title('Elastic Net Response')
    grid on
    axis tight
    colormap gray
    
    figure('Color','w'); hold on
    plot(log10(k),sum(xhat,2))
    xlabel('lg \offrate','Fontsize',20)
    set(gca,'Fontsize',20)
    ylabel('amplitude','Fontsize',20)
    title('Sum Elastic Net Response')
    grid on
    axis tight
    
    figure('Color','w'); hold on
    imagesc(log10(alpha),log10(k),xhat>0)
    xlabel('lg \alpha','Fontsize',20)
    set(gca,'Fontsize',20)
    ylabel('lg \offrate','Fontsize',20)
    title('Pos. Coefficients')
    grid on
    axis tight
    colormap gray
    
    figure('Color','w'); hold on
    imagesc(log10(alpha),log10(k),xhat<0)
    xlabel('lg \alpha','Fontsize',20)
    set(gca,'Fontsize',20)
    ylabel('lg \offrate','Fontsize',20)
    title('Neg. Coefficients')
    grid on
    axis tight
    colormap gray
    
    %     figure('Color','w'); hold on
    %     imagesc(alpha,log10(t),bhat)
    %     xlabel('lg \alpha','Fontsize',20)
    %     set(gca,'Fontsize',20)
    %     ylabel('lg Time','Fontsize',20)
    %     title('Model')
    %     grid on
    %     axis tight
    
    figure('Color','w'); hold on
    plot(t,b,'ko')
    set(gca,'Fontsize',20,'xscale','log','colororder',jet(numel(alpha)))
    plot(t,bhat)
    xlabel('Time','Fontsize',20)
    ylabel('PDF','Fontsize',20)
    title('Model')
    grid on
    axis tight
    
    %     figure('Color','w'); hold on
    %     imagesc(alpha,log10(t),residual)
    %     xlabel('lg \alpha','Fontsize',20)
    %     set(gca,'Fontsize',20)
    %     ylabel('lg Time','Fontsize',20)
    %     title('Residual')
    %     grid on
    %     axis tight
    
    figure('Color','w'); hold on
    set(gca,'Fontsize',20,'xscale','log','colororder',jet(numel(alpha)))
    plot(t,residual)
    xlabel('Time','Fontsize',20)
    ylabel('Error','Fontsize',20)
    title('Residual')
    grid on
    axis tight
    
    figure('Color','w'); hold on
    set(gca,'Fontsize',20,'xscale','log','colororder',jet(numel(alpha)))
    plot(t,abs(1-bhat./repmat(transpose(b),1,numel(alpha))))
    xlabel('Time','Fontsize',20)
    ylabel('Rel. Error','Fontsize',20)
    title('Residual')
    grid on
    axis tight
    
    figure('Color','w'); hold on
    stem(log10(alpha),sum(xhat ~= 0)/numel(k)*100,'k.')
    set(gca,'Fontsize',20)
    xlabel('lg \alpha','Fontsize',20)
    ylabel('Fraction Non-Zero [%]','Fontsize',20)
    title('Sparsity')
    grid on
    axis tight
end %if
end %fun