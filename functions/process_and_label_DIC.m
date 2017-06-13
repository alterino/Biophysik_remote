function [bw_img, label_img, cc, stats] = ...
    process_and_label_DIC( dic_scan, img_dims )
%PROCESS_AND_LABEL_IMAGES takes a full DIC and fluorescence scan (dic_scan
%and fluor_scan) assumed to be a slide scan composed of smaller images of
%dimension specified byu img_dims and returns labeled images as well as
%corrected fluorescence images assuming a gaussian amplitude bias
% outputs - 
%     bw_dic_stack - binary image locating ROIs in DIC channel
%     bw_fluor_stack - binary image from thresholded fluorescence
%     bw_stack - generated stripe pattern 'anded' with the bw_dic image
%     label_dic_stack - labeled DIC image with three clusters instead of
%                       two
%     corrected_images - corrected fluorescence channel images

load('gmm.mat')

dims_scan = size( dic_scan );
% dims_fluor_scan = size( fluor_scan );

if( mod( dims_scan(1), img_dims(1))~= 0 ||...
        mod( dims_scan(2), img_dims(2) ~= 0 ) )
    error('image dimensions do not divide scan dimensions evenly')
end

tic
[label_img, bw_img] = ...
    cluster_img_entropy( dic_scan, [600 600], gmm, 9, 1000 );
fprintf('entropy clustering took %i seconds/n', toc );

cc = bwconncomp( bw_img );
stats = get_cc_regionprops(cc);

keep_idx = [];
for i = 1:length( stats )
    bnd_box = stats(i).BoundingBox;
    if( stats(i).Area>2000 && bnd_box(3)<600 && bnd_box(4)<600  )
        keep_idx = [keep_idx; i];
    end
end

stats = stats(keep_idx);
cc = cc(keep_idx);
cc.PixelIdxList = cc.PixelIdxList(keep_idx);
cc.NumObjects = length(keep_idx);

cc_labels = zeros(length(cc), 1);

% optimal threshold should be updated with further data analysis or set by
% user using varargin
major_axis_thresh = 252;

for i = 1:length( stats )
    if( test_stats(i).MajorAxisLength > major_axis_thresh )
        stats(i).Label = 1;
    else
        stats(i).Label=2;
    end
end

% for i = 1:size( fluor_stack )
%     [bw_fluor_stack(:,:,i), ~] =...
%         threshold_flour_img( im2double(fluor_stack(:,:,i)), 250 );
%     [x,~,~,~] =...
%         fit_gaussian_flour(fluor_stack(:,:,i), bw_fluor_stack(:,:,i));
%     gauss = generate_gaussian_image( x, img_dims );
%     [thetaD, ~, img_corr] = ...
%         est_pattern_orientation(fluor_stack(:,:,i), bw_fluor_stack(:,:,i));
%     stripe_centers = find_stripe_locations( thetaD, img_corr, 45 );
%     bw_stripe = ...
%         generate_stripe_bw( stripe_centers, thetaD, img_dims, 25 );
%     bw_stack(:,:,i) = and( bw_fluor_stack(:,:,i), bw_stripe );
%     corrected_images(:,:,i) = ...
%         correct_fluorescence( fluor_stack(:,:,i), gauss );
% end
