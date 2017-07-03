function [imgbw, cc, img_stats] = threshold_fluor_img( img, size_thresh )
%THRESHOLD_FLUOR_IMG Takes input fluorescence image img and thresholds
%the image, also eliminating any connected components smaller than
%size_thresh

img_stats = struct('max_var', [], 'max', []);
img_stats.var = max( var( double( img ) ) );
img_stats.max = max( max( double( img ) ) );

threshInt = multithresh(img,2);

imgbw = ( img > min(threshInt) );
imgbw = medfilt2( imgbw, [4 4] );

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

imgbw = imerode( imgbw, [se90 se0] );
imgbw = imfill( imgbw, 'holes' );

if( exist( 'size_thresh', 'var' ) )
    cc = bwconncomp(imgbw);
    bSmall = cellfun(@(x)(length(x) < size_thresh), cc.PixelIdxList);
    imgbw(vertcat(cc.PixelIdxList{bSmall})) = 0;
end

cc = bwconncomp( imgbw );

end

