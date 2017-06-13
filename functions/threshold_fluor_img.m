function [imgbw, conv_hull] = threshold_fluor_img( img, size_thresh )
%THRESHOLD_FLUOR_IMG Takes input fluorescence image img and thresholds
%the image, also eliminating any connected components smaller than
%size_thresh
%   Detailed explanation goes here

threshInt = multithresh(img,2);

% imgbw = imbinarize(img,max(threshInt));
imgbw = ( img > max(threshInt) );
imgbw = medfilt2( imgbw, [10 10] );

if( exist( 'size_thresh', 'var' ) )
    cc = bwconncomp(imgbw);
    bSmall = cellfun(@(x)(length(x) < size_thresh), cc.PixelIdxList);
    imgbw(vertcat(cc.PixelIdxList{bSmall})) = 0;
end

conv_hull = bwconvhull(imgbw, 'objects', 4);

end

