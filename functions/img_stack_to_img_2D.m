% function [ img_2D ] = img_stack_to_img_2D( img_stack, dims, orig, labels, map )
% ^^ this one used for some debugging
function [ img_2D ] = img_stack_to_img_2D( img_stack, dims )
%IMG_STACK_TO_IMG_2D converts image stack to rectangular 2D image
% dims - a 2D vector in the form of [rows cols] where rows
% represents the number of images from the stack per row and cols defined
% similarly. rows*cols should equal the number of images in the stack

if( length( dims ) ~= 2 || min(size(img_stack)) > 1 )
    error('dims should be a vector of length 2.')
end
if( dims(1)*dims(2) ~= size( img_stack, 3) )
    error('img dimensions and desired stack dimensions inconsistent.' )
end
if( ~isnumeric( img_stack ) && ~islogical( img_stack ) )
    error('expected img input to be a numeric array.')
end

num_rows = dims(1);
num_cols = dims(2);
data_type = class( img_stack );

img_stack_dims = size( img_stack );
img_stack_dims = img_stack_dims(1:2);

img2D_dims = [num_rows*img_stack_dims(1) num_cols*img_stack_dims(2)];

img_2D = zeros( img2D_dims(1), img2D_dims(2), data_type );

tempIDX = 0;
for i=1:num_rows
    for j=1:num_cols
        tempIDX = tempIDX + 1;
        img_2D( img_stack_dims(1)*(i-1)+1:img_stack_dims(1)*i,...
            img_stack_dims(2)*(j-1)+1:img_stack_dims(2)*j ) =...
            img_stack( :,:, tempIDX );
    end
end

end