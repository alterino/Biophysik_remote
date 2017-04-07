function [props_struct, area_vec] = get_cc_regionprops( cc )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


    props_struct = struct( 'area_mean', 'area_std' );
    area_vec = zeros( length( cc.PixelIdxList ), 1 );
    pic_idx_cell = cc.PixelIdxList;
        
    for i = 1:length( pic_idx_cell )
        area_vec(i) =  length( pic_idx_cell{i} );  
    end
    
    props_struct.area_mean = mean( double( area_vec ) );
    props_struct.area_std = std( double( area_vec ) );
end

