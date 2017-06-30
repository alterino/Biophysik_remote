function [ bw_dic, entropy_img, cc, stats ] = run_full_eval( dic_scan, fluor_scan, img_dims, gmm, wind )
%RUN_FULL_EVAL Summary of this function goes here
%   Detailed explanation goes here

if( length( size(dic_scan) ) > 2 )
    error('dic_scan should be a 2D image')
end

[bw_dic, cc, stats, entropy_img] = ...
    process_and_label_DIC( dic_scan, img_dims, wind, gmm  );

keep_idx = false( length(stats), 1 );
for i = 1:length(stats)
    if( ~(stats(i).BoundingBox(3) > img_dims(2) ||...
                stats(i).BoundingBox(4) > img_dims(1) ) )
        keep_idx(i) = true;
    end
end

not_kept_stats = stats( ~(keep_idx) );
not_kept_cc = cc;
not_kept_cc.PixelIdxList = not_kept_cc.PixelIdxList{~keep_idx};
not_kept_cc.PixelIdxList = length( find( keep_idx == false ) );

stats = stats(keep_idx);
cc.PixelIdxList = cc.PixelIdxList{keep_idx};
cc.NumObjects = length( find( keep_idx == true ) );

dic_imgs = zeros( img_dims(1), img_dims(2), length( stats ) );
fluor_imgs = zeros( img_dims(1), img_dims(2), length( stats ) );

for i = 1:length( stats )
    [rows, cols] = ...
        compute_idx_from_bound_box( stats(i).BoundingBox, img_dims, size(dic_scan)  );
    
    dic_imgs(:,:,i) = extract_sub_img( dic_scan, rows, cols );
    fluor_imgs(:,:,i) = extract_sub_img( fluor_scan, rows, cols );
end








end