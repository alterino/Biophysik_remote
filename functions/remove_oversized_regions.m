function [cc, keep_idx] = remove_oversized_regions( cc, dims )
%REMOVE_OVERSIZED_REGIONS takes a connected components structure as
%returned from bwconncomp(BW) function and removes any component that does
%not fit in the bounding box defined by dims
%   cc - a connected components structure from bwconncomp(BW)
%   dims - dimensions of the specified bounding box in [width height]
%   format

cc_props = regionprops(cc, 'BoundingBox');

keep_idx = [];
for i = 1:length( cc_props )
    bnd_box = cc_props(i).BoundingBox;
    if( bnd_box(3)<dims(1) && bnd_box(4)<dims(2) )
        keep_idx = [keep_idx; i];
    end
end

cc = cc(keep_idx);
cc.PixelIdxList = cc.PixelIdxList(keep_idx);
cc.NumObjects = length(keep_idx);
end

