function img_bw = threshold_fluor_img( img_stack, threshInt, threshSize )
%THRESHOLD_FLUOR_IMG Takes input fluorescence image img and thresholds
%the image, also eliminating any connected components smaller than
%size_thresh

% img_stats = struct('max_var', [], 'max', []);
% img_stats.var = max( double( img(:) ) );
% img_stats.max = max( double( img(:) ) );
% img_stats.mean = mean( double( img(:) ) );

% threshInt = multithresh(img_stack,1);

img_bw = ( img_stack > min(threshInt) );
img_bw = medfilt2( img_bw, [4 4] );

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

img_bw = imerode( img_bw, [se90 se0] );
img_bw = imfill( img_bw, 'holes' );

if( exist( 'size_thresh', 'var' ) )
    cc = bwconncomp(img_bw);
    bSmall = cellfun(@(x)(length(x) < threshSize), cc.PixelIdxList);
    img_bw(vertcat(cc.PixelIdxList{bSmall})) = 0;
end

end

