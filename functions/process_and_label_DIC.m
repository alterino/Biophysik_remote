function [bw_img, cc, stats, img_ent] = ...
    process_and_label_DIC( dic_scan, img_dims, wind, gmm )
%PROCESS_AND_LABEL_DIC takes a full DIC scan (dic_scan)
% assumed to be a slide scan composed of smaller images of
% dimension specified by img_dims and returns labeled images as well as
% a connected components structure (cc) and some statistics used for data
% evaluation of the connected components

% load('gmm.mat')

dims_scan = size( dic_scan );
if( mod( dims_scan(1), img_dims(1))~= 0 ||...
        mod( dims_scan(2), img_dims(2) ~= 0 ) )
    error('image dimensions do not divide scan dimensions evenly')
end
tic
if( ~exist('gmm', 'var') || isempty(gmm) )
    stack_dims = size(dic_scan)./img_dims;
    img_stack = img_2D_to_img_stack(dic_scan, img_dims);
    [gmm, img_ent] = generate_gmm_entropy(img_stack, stack_dims, wind, 3);
    fprintf('entropy filtering and gmm generation for %i images took %i seconds\n',...
        size(img_stack,3), toc );
else
    img_stack = img_2D_to_img_stack(dic_scan, img_dims);
    img_ent = zeros( size(img_stack) );
    for i = 1:size(img_stack,3)
        im = img_stack(:,:,i);
        img_ent(:,:,i) = entropyfilt(im, ones(wind));
    end
    block_dims = dims_scan./img_dims;
    img_ent = img_stack_to_img_2D( img_ent, block_dims );
    fprintf('entropy filtering %i images took %i seconds\n',...
        size(img_stack,3), toc );
end
se = strel('disk',9);
ent_smooth = imclose(img_ent, se);

tic
[label_img, bw_img] = ...
    cluster_img_gmm( ent_smooth, gmm, 10000 );
fprintf('clustering %i images took %i seconds\n', size(img_stack,3), toc );

cc = bwconncomp( bw_img );
stats = get_cc_regionprops(cc);

fprintf('total time after filtering - %i seconds\n', toc );

