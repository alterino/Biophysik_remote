function out_struct = run_full_eval( dic_scan, fluor_scan, img_dims, gmm, wind )
%RUN_FULL_EVAL Summary of this function goes here
%   Detailed explanation goes here

if( length( size(dic_scan) ) > 2 )
    error('dic_scan should be a 2D image')
end

out_struct = struct('stats', [], 'cc', [], 'bw_imgs_dic', [],...
    'bw_scan_dic', [], 'bw_imgs_fluor', [], 'entropy_img', []);
stack_dims = size(dic_scan)./img_dims;

[bw_dic, cc, stats, entropy_img] = ...
    process_and_label_DIC( dic_scan, img_dims, wind, gmm  );
% ************************** filtering should be expanded and
% functionalized
keeper_count = 0;
keeper_idx = [];
for i = 1:length(stats)
    if( ~(stats(i).BoundingBox(3) > img_dims(2) ||...
            stats(i).BoundingBox(4) > img_dims(1) ) )
        stats(i).keepBool = true;
        keeper_count = keeper_count + 1;
        keeper_idx = [keeper_idx; i];
    else
        stats(i).keepBool = false;
    end
end
%*******************************************************

dic_stack = zeros(img_dims(1), img_dims(2), keeper_count);
fluor_stack = zeros(img_dims(1), img_dims(2), keeper_count);
dic_stack_bw = zeros(img_dims(1), img_dims(2), keeper_count);
fluor_stack_bw = zeros(img_dims(1), img_dims(2), keeper_count);
img_idx = 0;

for i = 1:length( stats )
    if( stats(i).keepBool )
        img_idx = img_idx + 1;
        [rows, cols] = ...
            compute_idx_from_bound_box( stats(i).BoundingBox, img_dims, size(dic_scan) );
        
        dic_stack(:,:,img_idx) = extract_subimage(dic_scan, rows, cols);
        temp_bw_img = zeros(size(dic_scan));
        temp_bw_img(cc.PixelIdxList{i}) = 1;
        dic_stack_bw(:,:,img_idx) = extract_subimage( temp_bw_img, rows, cols );
        fluor_stack(:,:,img_idx) = extract_subimage(fluor_scan, rows, cols);
    end
end

% separating out fluorescence eval section for better readability
min_dist = 100; % minimum distance between stripe centers - could be
% estimated algorithmically or input as user parameter
stripe_width = 40; % also should be able to estimate from image if unknown

for i = 1:size(fluor_stack, 3)
    [bw_img, fluor_cc, img_stats] = ...
        threshold_fluor_img(fluor_stack(:,:,i), 2000);
    if( isempty( find( bw_img > 0, 1 ) ) )
        figure(4), imshow( dic_stack(:,:,i), [] )
        title('no fluorescence detected');
        figure(5), imshow( fluor_stack(:,:,i), [] );
    else
        [thetaD, pattern, img_corr] = ...
            est_pattern_orientation(fluor_stack(:,:,i), bw_img);
        stripe_centers = find_stripe_locations( thetaD, img_corr, min_dist );
        stripe_bw = ...
            generate_stripe_bw( stripe_centers, thetaD, img_dims, stripe_width, bw_img );
        fluor_stack_bw(:,:,i) = and( stripe_bw, dic_stack_bw(:,:,i) );
%         figure(1), subplot(1,2,1), imshow( fluor_stack(:,:,i), [] );
%         subplot(1,2,2), imshow( bw_img );
%         figure(2), subplot(1,2,1), imshow( dic_stack(:,:,i), [] );
%         subplot(1,2,2), imshow( dic_stack_bw(:,:,i), [] );
%         figure(3), subplot(1,2,1), imshow( fluor_stack_bw(:,:,i), [] )
%         subplot(1,2,2), imshow( stripe_bw );
    end
end

out_struct.stats = stats;
out_struct.cc = cc;
out_struct.bw_imgs_dic = dic_stack_bw;
out_struct.bw_imgs_fluor = fluor_stack_bw;
out_struct.entropy_img = entropy_img;
out_struct.bw_scan_dic = bw_dic;




