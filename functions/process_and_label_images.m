function [bw_stack, bw_dic_stack, bw_fluor_stack, label_dic_stack, corrected_images] = ...
    process_and_label_images( dic_scan, fluor_scan, img_dims )
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

dims_dic_scan = size( dic_scan );
dims_fluor_scan = size( fluor_scan );

if( dims_dic_scan(1) ~= dims_fluor_scan(1) ||...
        dims_dic_scan(2) ~= dims_fluor_scan(2) )
    error('dimensions of fluorescence and DIC image should be equal')
end
if( mod( dims_dic_scan(1), img_dims(1))~= 0 ||...
        mod( dims_dic_scan(2), img_dims(2) ~= 0 ) )
    error('image dimensions do not divide scan dimensions evenly')
end

[dic_stack,~] = img_2D_to_img_stack( dic_scan, img_dims );
[fluor_stack,~] = img_2D_to_img_stack( fluor_scan, img_dims );

bw_fluor_stack = zeros( size( fluor_stack ) );
bw_stack = zeros( size( fluor_stack ) );
corrected_images = zeros( size( fluor_stack ) );

tic
[label_dic_stack, bw_dic_stack] = ...
    cluster_img_entropy( dic_scan, [600 600], gmm, 9, 1000 );
fprintf('entropy clustering took %i seconds/n', toc );
for i = 1:size( fluor_stack )
    [bw_fluor_stack(:,:,i), ~] =...
        threshold_flour_img( im2double(fluor_stack(:,:,i)), 250 );
    [x,~,~,~] =...
        fit_gaussian_flour(fluor_stack(:,:,i), bw_fluor_stack(:,:,i));
    gauss = generate_gaussian_image( x, img_dims );
    [thetaD, ~, img_corr] = ...
        est_pattern_orientation(fluor_stack(:,:,i), bw_fluor_stack(:,:,i));
    stripe_centers = find_stripe_locations( thetaD, img_corr, 45 );
    bw_stripe = ...
        generate_stripe_bw( stripe_centers, thetaD, img_dims, 25 );
    bw_stack(:,:,i) = and( bw_fluor_stack(:,:,i), bw_stripe );
    corrected_images(:,:,i) = ...
        correct_fluorescence( fluor_stack(:,:,i), gauss );
end
