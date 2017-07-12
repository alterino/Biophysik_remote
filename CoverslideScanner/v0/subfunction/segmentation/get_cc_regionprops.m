function props_struct = get_cc_regionprops( cc )
%GET_CC_REGIONPROPS
%   wrapper function for regionprops I'm interested in for image analysis
%   in DIC images
%   cc - connected components structure as returned from bwconncomp

    props_struct = regionprops( cc, 'Area', 'BoundingBox', 'Centroid',...
        'ConvexArea', 'Eccentricity', 'EquivDiameter', 'MajorAxisLength',...
        'MinorAxisLength', 'Perimeter', 'Solidity' );
    
    
    for i = 1:length( props_struct )
        bb = [props_struct(i).BoundingBox];
        props_struct(i).BB_center = [ bb(1) + bb(3)/2, bb(2) + bb(4)/2 ];
    end
    
end

