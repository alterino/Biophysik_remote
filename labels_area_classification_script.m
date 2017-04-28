function sub_img = area_classification( image_path, labels_path, model )
% function takes the area classification scripe
% label_area_classification_script.m and functionalizes it taking the image
% path for the 2D image, a labeled image for accuracy evaluation, and model
% can be either 'gmm' in which case a 3-cluster gmm model is used or
% 'thresh' in which the user can specify a threshold

% home path
load( 'D:\OS_Biophysik\Microscopy\DIC_160308_2033_labels_edited_latest8.mat' )
img_2D = imread( 'D:\OS_Biophysik\DIC_images\DIC_160308_2033.tif' );
[img_stack, ~] = img_2D_to_img_stack( img_2D, [600 600] );

% img_flour = im2double( imread( 'D:\OS_Biophysik\Microscopy\Fluor_TIRF_488_160308_2041.tif' ) );

img_dims = [ size(img_stack, 1), size(img_stack, 2) ];
label_stack = zeros( img_dims(1), img_dims(2), size(img_stack, 3) );
label_counts = zeros( 3,1 );
% label_2D = zeros( size( img_2D ) );


for i = 1:length( ROI_cell )
    temp_label = zeros( img_dims(1), img_dims(2) );
    temp_roi = ROI_cell{i};
    
    for j = 1:length( temp_roi )
        temp_mask = temp_roi(j).Mask;
        temp_label( temp_mask == 1 ) = temp_roi(j).Label; 
        label_counts(temp_roi(j).Label) = label_counts(temp_roi(j).Label) + 1;
    end
    
    label_stack(:,:,i) = temp_label;
end
clear temp*

label_2D = img_stack_to_img_2D( label_stack, [15 15] ); 
labels_map = [0 1 0; 1 0 0; 0 0 0; .8 .8 .8; 0 0 1];
label_rgb = label2rgb( label_2D, labels_map, [.5 .5 .5] );

figure, imshow( label_rgb ), title( 'manually labeled image' )

living_ROIs = ( label_2D == 1 );
dead_ROIs = ( label_2D == 2 );
bs_ROIs = ( label_2D == 3 );
empty_space = ( label_2D == 0 );

living_cc = bwconncomp( living_ROIs );
dead_cc = bwconncomp( dead_ROIs );
bs_cc = bwconncomp( bs_ROIs );

[living_cc_props, living_area_vec] = get_cc_regionprops( living_cc );
[dead_cc_props, dead_area_vec] = get_cc_regionprops( dead_cc );
[bs_cc_props, bs_area_vec] = get_cc_regionprops( bs_cc );

area_vec = [living_area_vec; dead_area_vec; bs_area_vec];



num_clusts = 3;
options = statset( 'MaxIter', 200 );
gmm_area = fitgmdist( area_vec, num_clusts, 'replicates', 2, 'Options', options);
idx = reshape(cluster(gmm_area, area_vec), size(area_vec));
[~,sorted_idx] = sort(gmm_area.mu);
temp = zeros(num_clusts,1);
for j = 1:num_clusts
    temp(j) = find( sorted_idx == j );
end
sorted_idx = temp; clear temp
% some weird bug is happening here but I think the above fixed it
new_idx = sorted_idx(idx); %**********************
area_class_idx = (new_idx > 1);
area_acc = length( find( area_class_idx(1:length(living_area_vec)) == 1 ) )/length(area_vec) +...
            length( find( area_class_idx(length(living_area_vec)+1:end) == 0 ) )/length(area_vec);
        
living_class = area_class_idx( 1:length(living_area_vec) );
dead_class = area_class_idx( length(living_area_vec)+1:length(living_area_vec)+length(dead_area_vec) );
bs_class = area_class_idx( length(living_area_vec)+length(dead_area_vec)+1:end );

test_labels = zeros( 9000, 9000 );

for i = 1:length( living_cc.PixelIdxList )
    temp = living_cc.PixelIdxList{i};
    if( living_class(i) == 1 )
        test_labels(temp) = 1;
    else
        test_labels(temp) = 2;
    end
end
for i = 1:length( dead_cc.PixelIdxList )
    temp = dead_cc.PixelIdxList{i};
    if( dead_class(i) == 1 )
        test_labels(temp) = 1;
    else
        test_labels(temp) = 2;
    end
end
for i = 1:length( bs_cc.PixelIdxList )
    temp = bs_cc.PixelIdxList{i};
    if( bs_class(i) == 1 )
        test_labels(temp) = 1;
    else
        test_labels(temp) = 2;
    end
end
clear temp*
test_label_rgb = label2rgb( test_labels, labels_map, [.5 .5 .5] );

figure, imshow( test_label_rgb );
title( 'area classification results (two-class)' )

load('./img_bw_stack.mat')

img_bw_2D = img_stack_to_img_2D( img_bw_stack, [15 15] );
img_bw_cc = bwconncomp( img_bw_2D );

[bw_cc_props, bw_area_vec] = get_cc_regionprops( img_bw_cc );
idx = reshape(cluster(gmm_area, bw_area_vec), size(bw_area_vec));
[~,sorted_idx] = sort(gmm_area.mu);






    
                






