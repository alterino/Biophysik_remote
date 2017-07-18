% img_classes = struct( 'filepath', [], 'class_vec', [] );

% img_classes(1).filepath = img_str;
% img_classes(1).class_vec = img_class;
% 
% dir_path = 'T:\Marino\Microscopy\170706\';
% 
% scan_paths{1} = strcat( dir_path, 'Fluor_405_170706_1510.tif' );
% scan_paths{2} = strcat( dir_path, 'Fluor_405_170706_1724.tif' );
pattern_img_stack = [];
load( 'labeled_fluor2.mat')
% img_idx = 1;\
for i = 1:length(img_classes)
    temp_scan = imread( img_classes(i).filepath );
    
    temp_stack = img_2D_to_img_stack( temp_scan, [1200 1200] );
    temp_labels = zeros( size( temp_stack, 3 ), 1 );
%     h = figure('Position',[1500 20 800 800]);
    
    for j = 1:size( temp_stack, 3 )
        if( img_classes(i).class_vec(j) )
           if( isempty( pattern_img_stack ) )
               pattern_img_stack = temp_stack(:,:,j);
           else
               pattern_img_stack = cat( 3, pattern_img_stack, temp_stack(:,:,j));
           end
        end 
    end 
end


for i = 1:size( pattern_img_stack, 3 )
    figure(1), imshow( pattern_img_stack(:,:,i), [] )
    pause(1)
    
end