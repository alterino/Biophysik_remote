function new_scan = resize_scan( scan, old_dims, new_dims )
%RESIZE_SCAN Summary of this function goes here
%   Detailed explanation goes here

if( length(old_dims) == 1 )
    old_dims = [old_dims, old_dims];
end
if( length(new_dims) == 1 )
    new_dims = [new_dims, new_dims];
end

% data_type = class( scan );

block_dims = size(scan)./old_dims;

old_stack = img_2D_to_img_stack( scan, old_dims );
new_stack = zeros( new_dims(1), new_dims(2), size( old_stack, 3 ) );

for i = 1:size( old_stack, 3 )
    new_stack(:,:,i) = imresize( old_stack(:,:,i), new_dims );
end

new_scan = img_stack_to_img_2D( new_stack, block_dims );
new_scan = cast( new_scan, 'like', scan );

