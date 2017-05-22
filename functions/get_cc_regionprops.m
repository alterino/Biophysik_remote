function props_struct = get_cc_regionprops( cc )
%GET_CC_REGIONPROPS
%   wrapper function for regionprops I'm interested in for image analysis
%   in DIC images
%   cc - connected components structure as returned from bwconncomp

    props_struct = regionprops( cc, 'Area', 'BoundingBox', 'Centroid',...
        'ConvexArea', 'Eccentricity', 'EquivDiameter', 'MajorAxisLength',...
        'MinorAxisLength', 'Perimeter', 'Solidity' );
end

