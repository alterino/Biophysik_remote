function [RCF,r,N] = img_radial_avg_corr(imgCorr)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 22.04.2014
%modified 14.10.2014: vectorization of the radial averaging
%modified 15.10.2014: arbitrary zero peak position

imgMask = (imgCorr == max(max(imgCorr)));
[iMax,jMax] = find(imgMask);
[I,J] = ndgrid(1:size(imgCorr,1),1:size(imgCorr,2));
imgMask = sqrt((I-iMax).^2+(J-jMax).^2); %euclidean distance transform from the center
r = unique(imgMask); % unique set of distances
rPx = ismembc2(imgMask(:),r); % assigns each pixel the corresponding distance from the center
N = accumarray(rPx,1); % # of pixels with distance r
RCF = accumarray(rPx,imgCorr(:),[numel(r),1])./N;
end %fun