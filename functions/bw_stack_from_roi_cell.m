function [bw_stack, roi_cnts, roi_pix_cnts] = bw_stack_from_roi_cell( roi_cell, dims, ignore_list )
% function takes a cell variable - roi_cell - and generates a binary 3D
% image stack with one 2D image for each entry in roi_cell, dims should be
% the dimensions of the resulting bw 2D images in [row col] form. roi_cnts
% is a vector giving the number of separate ROIs in 2D image and
% roi_pix_cnts is a vector giving the number of 'true' pixels in each image

bw_stack = zeros( dims(1), dims(2), length(roi_cell) );
roi_cnts = zeros( length( roi_cell ) );
roi_pix_cnts = zeros( length( roi_cell ) );

for i = 1:length( roi_cell )
    if( any( ignore_list == i ) )
        continue
    end
    temp_roi = roi_cell{i};
    roi_cnts(i) = length( temp_roi );
    for j = 1:length( temp_roi )
        bw_stack(:,:,i) = or( bw_stack(:,:,i), temp_roi(j).Mask );
    end
    
    roi_pix_cnts(i) = sum( sum( bw_stack(:,:,i ) ) );
    
end


end

