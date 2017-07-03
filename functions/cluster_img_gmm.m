function [labeled_img, bw_img] = cluster_img_gmm(img, gmm, size_thresh )
% if stack_dims is [] that means that the image should be assumed to be a
% single 2D image rather than an array of 2D images composing a larger
% image

if( length( size(img) ) ~= 2 || min( size(img) ) == 1 )
    error('expected 2D image input');
end

num_clusts = length(gmm.mu);
idx = reshape(cluster(gmm, img(:)), size(img));
% Order the clustering so that the indices are from min to max cluster mean
[~,sorted_idx] = sort(gmm.mu);
temp = zeros(num_clusts,1);
for j = 1:num_clusts
    temp(j) = find( sorted_idx == j );
end
sorted_idx = temp; clear temp

new_idx = sorted_idx(idx);
% bwInterior = (new_idx > 2);
% cc = bwconncomp(bwInterior);
% if( exist('sizeThresh', 'var') && ~isempty(size_thresh) )
%     bSmall = cellfun(@(x)(length(x) < size_thresh), cc.PixelIdxList);
%     new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;
% end
labeled_img = new_idx;
bw_img = (labeled_img > 2);
bw_img = imerode( bw_img, true(20) );
bw_img = imfill( bw_img, 'holes' );
cc = bwconncomp(bw_img);

if( exist('size_thresh', 'var') && ~isempty(size_thresh) )
    bSmall = cellfun(@(x)(length(x) < size_thresh), cc.PixelIdxList);
    bw_img(vertcat(cc.PixelIdxList{bSmall})) = 0;
end

end