% for ROI.Label - 1: living cell, 2: dead cell, 3: bullshit, 4: should not
% exist - temporary label for editing, 5: edge - should also not exist in
% ROIs but if found that would also imply a bug

% home path
load( 'D:\OS_Biophysik\Microscopy\DIC_160308_2033_labels_edited_latest7.mat' )
img_2D = imread( 'D:\OS_Biophysik\DIC_images\DIC_160308_2033.tif' );
[img_stack, ~] = img_2D_to_img_stack( img_2D, [600 600] );
img_grad_stack = zeros( size( img_stack ) );

img_flour = im2double( imread( 'D:\OS_Biophysik\Microscopy\Fluor_TIRF_488_160308_2041.tif' ) );
% threshed_flour = imbinarize( img_flour, graythresh( img_flour ) );
% figure(1), imshow( threshed_flour ), title( 'thresholded flourescence image' )

for i = 1:size( img_stack, 3 )
    [temp_grad, ~] = imgradient( img_stack(:,:,i) );
    img_grad_stack(:,:,i) = temp_grad;
end

img_grad_2D = img_stack_to_img_2D( img_grad_stack, [15, 15] );

img_dims = [ size(img_stack, 1), size(img_stack, 2) ];
label_stack = zeros( img_dims(1), img_dims(2), size(img_stack, 3) );
label_counts = zeros( 3,1 );
% label_2D = zeros( size( img_2D ) );


for i = 1:length( ROI_cell )
    temp_label = zeros( img_dims(1), img_dims(2) );
    temp_roi = ROI_cell{i};
%     temp_row = img_org_idx(i,1);
%     temp_col = img_org_idx(i,2);
    
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

figure(2), imshow( label_rgb ), title( 'manually labeled image' )

living_ROIs = ( label_2D == 1 );
dead_ROIs = ( label_2D == 2 );
bs_ROIs = ( label_2D == 3 );
empty_space = ( label_2D == 0 );

% err_ROIs = or( label_2D == 4, label_2D == 5 );
living_pix = double( img_2D( living_ROIs == 1 ) );
dead_pix = double( img_2D( dead_ROIs == 1 ) );
bs_pix = double( img_2D( bs_ROIs == 1 ) );
% empty_pix = double( img_2D( label_2D == 0 ) );

living_grad = img_grad_2D( living_ROIs == 1 );
dead_grad = img_grad_2D( dead_ROIs == 1 );
bs_grad = img_grad_2D( bs_ROIs == 1 );
% empty_grad = img_grad_2D( label_2D == 0 );

living_flour = img_flour( living_ROIs == 1 );
dead_flour = img_flour( dead_ROIs == 1 );
bs_flour = img_flour( bs_ROIs == 1 );
empty_flour = img_flour( empty_space == 1 );

living_stats = get_pix_stats( living_pix, living_grad, living_flour );
dead_stats = get_pix_stats( dead_pix, dead_grad, dead_flour );
bs_stats = get_pix_stats( bs_pix, bs_grad, bs_flour );
% empty_stats = get_pix_stats( empty_pix, empty_grad, empty_fluor );
empty_stats = [ mean( double( empty_flour ) ), std( double( empty_flour ) ) ];

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

test_label_rgb = label2rgb( test_labels, labels_map, [.5 .5 .5] );

figure, imshow( test_label_rgb );
title( 'area classification results (two-class)' )

load('image_bw_stack.mat')

img_bw_2D = img_stack_to_img_2D( img_bw_stack, [15 15] );
img_bw_cc = bwconncomp( img_bw_2D );

[bw_cc_props, bw_area_vec] = get_cc_regionprops( img_bw_cc );
idx = reshape(cluster(gmm_area, bw_area_vec), size(bw_area_vec));
[~,sorted_idx] = sort(gmm_area.mu);
temp = zeros(num_clusts,1);
for j = 1:num_clusts
    temp(j) = find( sorted_idx == j );
end
sorted_idx = temp; clear temp
% some weird bug is happening here but I think the above fixed it
new_idx = sorted_idx(idx); %**********************
bw_class_idx = (new_idx > 1);

test_class_img = zeros( 9000, 9000 );

for i = 1:length( img_bw_cc.PixelIdxList )
    temp = img_bw_cc.PixelIdxList{i};
    if( bw_class_idx(i) == 1 )
        test_class_img(temp) = 1;
    else
        test_class_img(temp) = 2;
    end
end

test_class_rgb = label2rgb( test_class_img, labels_map, [.5 .5 .5] );

figure, imshow( test_class_rgb );
title( 'area classification test results (two-class)' )








% num_clusts = 2;
% % tic();
% skip_size = 30;
% flour_vector = img_flour(:);
% options = statset( 'MaxIter', 200 );
% gmm_flour = fitgmdist(flour_vector(1:skip_size:end), num_clusts, 'replicates',3, 'Options', options);
% idx = reshape(cluster(gmm_flour, img_flour(:)), size(img_flour));
% % Order the clustering so that the indices are from min to max cluster mean
% [~,sorted_idx] = sort(gmm_flour.mu);
% temp = zeros(num_clusts,1);
% for j = 1:num_clusts
%     temp(j) = find( sorted_idx == j );
% end
% sorted_idx = temp; clear temp
% % some weird bug is happening here but I think the above fixed it
% new_idx = sorted_idx(idx); %**********************
% 
% cc = bwconncomp(bwInterior);
% 
% sizeThresh = 10000;
% bSmall = cellfun(@(x)(length(x) < sizeThresh), cc.PixelIdxList);
% 
% new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;
% 
% figure(5);imagesc(new_idx), title( 'binarized flourescence image' )
%       
% clear num_clusts options idx sorted_idx temp new_idx








    
                






