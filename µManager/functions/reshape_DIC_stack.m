function [ bandpassIMG, segIMG ] = reshape_DIC_stack( stack )
%RESHAPE_DIC_STACK Summary of this function goes here
%   Detailed explanation goes here

bandpassIMG = zeros( 9000, 9000, 'uint16' );
segIMG = zeros( 9000, 9000, 'uint16' );

for j = 1:size(stack, 3)
    tempIMG = uint16( stack(:,:,j) );
    %                 figure(1), imshow( tempIMG, [] )
    col_idx = mod(j, 15);
    row_idx = ceil( j/15 );
    
    if(row_idx == 0), row_idx = 15; end
    if(col_idx == 0), col_idx = 15; end
    
    bandpassIMG( 1+(row_idx-1)*600:600+(row_idx-1)*600,...
        1+(col_idx-1)*600:600+(col_idx-1)*600 ) = tempIMG( :, 1:600 );
    segIMG( 1+(row_idx-1)*600:600+(row_idx-1)*600,...
        1+(col_idx-1)*600:600+(col_idx-1)*600 ) = tempIMG( :, 601:1200 );
end


end

