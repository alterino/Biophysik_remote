function [imgbw, conv_hull] = threshold_flour_img( img, size_thresh )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
threshInt = multithresh(img,2);

imgbw = imbinarize(img,max(threshInt));

% linear structure elements used for dilation
se90 = strel('line', 1, 90);
se0 = strel('line', 1, 0);
% diamond shape used for erosion to compensate for original dilation
seD = strel('diamond',1);

imgbw_D = imdilate(imgbw, [se90 se0]);
% imgbw_F = imfill(imgbw_D, 'holes');

bwC_F = imerode(imgbw_F, seD);
bwC_F = imerode(bwC_F, seD);
bwC_F = bwconvhull(bwC_F, 'objects', 4);

cc = bwconncomp(bwC_F);
bSmall = cellfun(@(x)(length(x) < size_thresh), cc.PixelIdxList);

bwC_F(vertcat(cc.PixelIdxList{bSmall})) = 0;

conv_hull = bwconvhull(bwC_F, 'objects', 4);


end

