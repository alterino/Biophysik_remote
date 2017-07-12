function [bw_img, cc] = ...
    process_and_label_DIC( dic_scan, img_dims, wind, scan_dims )
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
if( ~isa( dic_scan, 'double' ) )
    dic_scan = im2double(dic_scan);
%     max_val = max( dic_scan ); min_val = min(dic_scan);
%     while( length( max_val  ) > 1 )
%         max_val = max(max_val); 
%         min_val = min(min_val);
%     end
%     dic_scan = (dic_scan - min_val)/(max_val - min_val);
end
if( length( dims_scan ) == 3 )
    stack_bool = 1;
else
    stack_bool = 0;
end

% if( ~exist('gmm', 'var') || isempty(gmm) )
if( 0 ) % just getting rid of this condition temporarily
    stack_dims = size(dic_scan)./img_dims;
    img_stack = img_2D_to_img_stack(dic_scan, img_dims);
    [gmm, img_ent] = generate_gmm_entropy(img_stack, stack_dims, wind, 3);
    fprintf('entropy filtering and gmm generation for %i images took %i seconds\n',...
        size(img_stack,3), toc );
else
    if( size( dic_scan, 1 ) ~= img_dims(1) || size(dic_scan, 2) ~= img_dims(2) )
        img_stack = img_2D_to_img_stack(dic_scan, img_dims);
    else
        img_stack = dic_scan;
    end
    img_ent = zeros( size(img_stack) );
    for i = 1:size(img_stack,3)
        im = img_stack(:,:,i);
        img_ent(:,:,i) = entropyfilt(im, ones(wind));
    end
    if( ~stack_bool )
        block_dims = dims_scan./img_dims;
        img_ent = img_stack_to_img_2D( img_ent, block_dims );
    end
    fprintf('entropy filtering %i images took %i seconds\n',...
        size(img_stack,3), toc );
end
se = strel('disk',4);
ent_smooth = imclose(img_ent, se);

tic
% gmm clustering being fucked at the moment - clustering zeros of entropy
% image as belonging to highest cluster... wtf
% [label_img, bw_img] = ...

thresh = multithresh(ent_smooth, 1);
bw_img = cluster_img_threshold( ent_smooth, thresh, 10000 );
% se = strel('disk',4);
% bw_img2 = imopen( bw_img, se );
% bw_img = cluster_img_gmm( ent_smooth, 2, 5000 );
fprintf('clustering %i images took %i seconds\n', size(img_stack,3), toc );
if( length( size(bw_img) ) == 2 )
    cc = bwconncomp( bw_img );
    stats = get_cc_regionprops(cc);
    cc.stats = stats;
elseif( length( size(bw_img) ) == 3 )
    cc = struct( 'Connectivity', [], 'ImageSize', [], 'NumObjects', 0,...
                 'PixelIdxList', [], 'stats', [] );
             cc.ImageSize = scan_dims;
    for i = 1:size( bw_img, 3 )
        temp_cc = bwconncomp( bw_img(:,:,i) );
        if( isempty( cc.Connectivity ) )
            cc.Connectivity = temp_cc.Connectivity;
        end
        temp_stats = get_cc_regionprops( bw_img(:,:,i) );
        cc.PixelIdxList = [cc.PixelIdxList, temp_cc.PixelIdxList];
        cc.stats = [cc.stats; temp_stats];
        cc.NumObjects = cc.NumObjects + temp_cc.NumObjects;
    end
else
    cc = [];
    error('dimension error with bw_img')
end

fprintf( 'total time after filtering - %i seconds\n', toc );

