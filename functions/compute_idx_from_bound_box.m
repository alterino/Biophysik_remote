function [row, col] = compute_idx_from_bound_box( bounding_box, img_dims, scan_dims )
%COMPUTE_IDX_FROM_BOUND_BOX Takes as input a bounding box of the form
% [x y width height] as well as the dimensions of the desired output
% image, img_dims, and the dimensions of the image used to generate the
% bounding box, scan_dims, and returns the row min and max as well as the
% col min and max as vectors of length two which can be used to extract an
% image centered on the bounding box. Image and scan dims should be in
% [row col] format. Yes this is stupid and inconsistent with the bounding
% box but this is consistent with matlab functions.


if( min( size(bounding_box) ) ~= 1 || max( size(bounding_box) ) ~= 4 )
    error('bounding box must be a vector of length 4');
elseif( ~isnumeric(bounding_box) )
    error('bounding box must be a numeric array')
elseif( min( bounding_box ) < 0.5 ||...
        floor( bounding_box(1) + bounding_box(3) ) > scan_dims(2) ||...
        floor( bounding_box(2) + bounding_box(4) ) > scan_dims(1) )
    error('dimension mismatch')
end


bb_center_x = round( bounding_box(1) + bounding_box(3)/2 );
bb_center_y = round( bounding_box(2) + bounding_box(4)/2 );


subimg_topleft = [ min( [ max( [bb_center_x-floor(img_dims(2)/2), 1] ), scan_dims(2)-(img_dims(2)-1) ] ) ,...
                        min( [ max( [bb_center_y-floor(img_dims(1)/2), 1] ), scan_dims(1)-(img_dims(1)-1) ] )];
                    
row = [ subimg_topleft(2), subimg_topleft(2)+(img_dims(1)-1) ];
col = [ subimg_topleft(1), subimg_topleft(1)+(img_dims(2)-1) ];



end

