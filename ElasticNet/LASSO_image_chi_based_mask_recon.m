function [imgRecon,l1Regul] = LASSO_image_chi_based_mask_recon(...
    img,muBckgrnd,stdBckgrnd,psfStd,alpha,facUp,varargin)

objParser = inputParser;
objParser.KeepUnmatched = true;
addRequired(objParser,'img',@ismatrix)
addRequired(objParser,'muBckgrnd',@ismatrix)
addRequired(objParser,'stdBckgrnd',@ismatrix)
addRequired(objParser,'psfStd',@(x)isscalar(x) && x > 0)
addRequired(objParser,'alpha',@(x)isscalar(x) && x > 0)
addRequired(objParser,'facUp',@(x)isscalar(x) && x > 0)
parse(objParser,img,muBckgrnd,stdBckgrnd,psfStd,alpha,facUp,varargin{:});
% input = objParser.Results;

%% generate structuring element for lateral sumation
r = ceil(psfStd);
[i,j] = ndgrid(-r:r);
SE = sqrt(i.^2+j.^2) <= r;

%% z-transformation & p-value based pixel classification
imgZ = (img-muBckgrnd)./stdBckgrnd; % z-trafo
df = sum(SE(:))-1; %deg. freedom of the chi(square)-distribution
% imgChi = chi2cdf(sffilt(@(x)sum(x.^2),imgZ,SE),df);
imgChi = gammainc(sffilt(@(x)sum(x.^2),imgZ,SE)/2,df/2,'upper'); %more stable solution == 1-chi2cdf == p-value
% figure;imagesc(-log10(imgChi));axis image
imgMask = (imgChi <= alpha);
% figure;imagesc(imgMask);axis image

%% filter spurious pixel
SE = [1 1 1; 1 0 1; 1 1 1];
nnLinkage = 5;
imgMask  = sffilt(@(x)sum(x)>=nnLinkage,imgMask,SE);

%% dilation by cross
SE = [0 1 0; 1 1 1; 0 1 0];
imgMask = sffilt('max',imgMask,SE);

%% mask generation
imgMask = double(imgMask);
imgMask(imgMask == 0) = nan;
% imgLabel = label(imgMask,8);
% numLabel = numel(unique(imgLabel(:)))-1;

% LASSO image reconstruction
[imgRecon,l1Regul] = ...
    LASSO_ROI_recon(imgZ,...
    psfStd,'mask',imgMask,'facUpSamp',facUp,varargin{:});

end %fun