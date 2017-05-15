function [thetaD, pattern, img_corr] = est_pattern_orientation( img, bw_img )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

cc = bwconncomp(bw_img);

% s = regionprops(cc, 'Area', 'Orientation', 'MajorAxisLength',...
%     'MinorAxisLength', 'Eccentricity', 'Centroid');
s = regionprops(cc, 'Area', 'Orientation', 'MajorAxisLength',...
     'MinorAxisLength', 'Eccentricity', 'Centroid');
k = find(cell2mat({s.MajorAxisLength})==max(cell2mat({s.MajorAxisLength})));

thetaD = s(k).Orientation;

pattern = floures_pattern_gen(25, 30, size(bw_img), 1);
pattern = imrotate(pattern, -(90-thetaD));

img_corr = conv2(img, pattern, 'same');


end