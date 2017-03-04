function [ img_2D ] = img_stack_to_img_2D( img_stack, dims )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% dims should be a 2D vector in the form of [rows cols] where rows
% represents the number of images from the stack per row and cols defined
% similarly. rows*cols should equal the number of images in the stack

numRows = dims(1);
numCols = dims(2);
data_type = class( img_stack );

if( length( dims ) ~= 2 )
   error('dims should be a vector of length 2') 
end

if( dims(1)*dims(2) ~= size( img_stack, 3) )
   error('img dimensions and desired stack dimensions inconsistent.' ) 
end

if( ~isnumeric( img_stack ) && ~islogical( img_stack ) )
    error('img is limited to numeric array due to programmer laziness.')
end

img_stack_dims = size( img_stack );
num_imgs = img_stack_dims(3);
img_stack_dims = img_stack_dims(1:2);

img2D_dims = [numRows*img_stack_dims(1) numCols*img_stack_dims(2)];

img_2D = zeros( img2D_dims(1), img2D_dims(2), data_type );

tempIDX = 0;
for i=1:numRows
    for j=1:numCols
        tempIDX = tempIDX + 1;
        img_2D( img_stack_dims(1)*(i-1)+1:img_stack_dims(1)*i,...
                        img_stack_dims(2)*(j-1)+1:img_stack_dims(2)*j ) =...
                                                 img_stack( :,:, tempIDX );
    end
end


end

