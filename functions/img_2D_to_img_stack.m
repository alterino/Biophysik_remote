function img_stack = img_2D_to_img_stack( img, dims )
%img_2D_to_img_stack -  
%   dims should be the size of each individual image that will be planes
%   in the resulting stack in rows x cols format

img2D_dims = size( img );
data_type = class( img );

if( length( dims ) ~= 2 )
   error('dims should be a vector of length 2') 
end

if( mod( img2D_dims(1), dims(1)) ~= 0 || mod( img2D_dims(2), dims(2)) )
   error('img dimensions and desired stack dimensions inconsistent.' ) 
end

if( ~isnumeric( img ) )
    error('img is limited to numeric array due to programmer laziness.')
end

numCols = img2D_dims(1)/dims(1);
numRows = img2D_dims(2)/dims(2);

img_stack = zeros(dims(1), dims(2), numCols*numRows, data_type);

tempIDX = 0;
for i=1:numRows
    for j=1:numCols
        tempIDX = tempIDX + 1;
        img_stack( :,:, tempIDX ) =...
            img( dims(1)*(i-1)+1:dims(1)*i, dims(2)*(j-1)+1:dims(2)*j );
    end
end


end

