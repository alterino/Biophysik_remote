function [ output_args ] = classify_ROIs( cc, stat, threshold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

region_props = regionprops(cc, stat);

for i = 1:length( region_props )
    
    if( region_props(i) < threshold )
        keep_idx(i) = 0;
    else
        keep_idx(i) = 1;
    end
end
