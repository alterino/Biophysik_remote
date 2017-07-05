function [thetaD, pattern, img_corr, x_guess] = est_pattern_orientation( img, bw_img )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

cc = bwconncomp(bw_img);

if( cc.NumObjects == 0 )
    warning('binary image is all zeros')
    thetaD = []; pattern = []; img_corr = [];
    return;
end

s = regionprops(cc, 'MajorAxisLength', 'MinorAxisLength', 'Orientation',...
    'Eccentricity', 'Centroid' );

k = find(cell2mat({s.Eccentricity})==max(cell2mat({s.Eccentricity})));
thetaD = s(k).Orientation;
m = -tand( s(k).Orientation );
b = s(k).Centroid(2) - m*s(k).Centroid(1);
y = round( size(bw_img,1)/2 );
x_guess = (y - b) / m;

pattern = floures_pattern_gen(25, 30, size(bw_img), 1);
pattern = imrotate(pattern, -(90-thetaD));
img_corr = conv2( double(img), double(pattern), 'same');

end