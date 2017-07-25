% function bw_img = cluster_img_gmm(img, gmm, size_thresh )
function bw_img = cluster_img_threshold(img, int_thresh, size_thresh, minor_axis_thresh )
% if stack_dims is [] that means that the image should be assumed to be a
% single 2D image rather than an array of 2D images composing a larger
% image

% if( length( size(img) ) ~= 2 || min( size(img) ) == 1 )
%     error('expected 2D image input');
% end

% % shit is being weird and clustering completely wrong so eliminating the
% % gmm for now
% num_clusts = length(gmm.mu);
% img_vec = img(:);
% idx = cluster(gmm, img_vec);
% % dealing with strange bug where zeros are classified as highest class
% min_class = find( [gmm.mu] == min([gmm.mu]) );
% idx(img_vec==0) = min_class;
% idx = reshape( idx, size(img) );
% % Order the clustering so that the indices are from min to max cluster mean
% [~,sorted_idx] = sort(gmm.mu);
% temp = zeros(num_clusts,1);
% for j = 1:num_clusts
%     temp(j) = find( sorted_idx == j );
% end
% sorted_idx = temp; clear temp

% new_idx = sorted_idx(idx);
% bwInterior = (new_idx > 2);
% cc = bwconncomp(bwInterior);
% if( exist('sizeThresh', 'var') && ~isempty(size_thresh) )
%     bSmall = cellfun(@(x)(length(x) < size_thresh), cc.PixelIdxList);
%     new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;
% end
% labeled_img = new_idx;
% bw_img = (labeled_img > 2);
if( length( size(img ) ) < 3 )
    bw_img = imbinarize(img, int_thresh);
    bw_img = imopen( bw_img, strel( 'disk', 4 ) );
    cc = bwconncomp(bw_img);
    
    if( exist('size_thresh', 'var') && ~isempty(size_thresh) )
        bSmall = cellfun(@(x)(length(x) < size_thresh), cc.PixelIdxList);
        bw_img(vertcat(cc.PixelIdxList{bSmall})) = 0;
    end
else
    bw_img = zeros( size( img ), 'logical' );
    for i = 1:size(img,3)
        temp = imbinarize( img(:,:,i), int_thresh );
        cc = bwconncomp(temp);
        
        if( exist('size_thresh', 'var') && ~isempty(size_thresh) )
            bSmall = cellfun(@(x)(length(x) < size_thresh), cc.PixelIdxList);
            temp(vertcat(cc.PixelIdxList{bSmall})) = 0;
        end
        cc = bwconncomp(temp);
        props = regionprops(cc, 'MinorAxisLength', 'Centroid' );
        centerPt = size( temp )/2;
        centerPt = centerPt([2, 1]);
        center_dist = zeros( length( props ), 1 );
        for j = 1:length( props )
           center_dist(j) = norm(props(j).Centroid - centerPt);
        end
        
        temp = zeros( size( temp ) );
        temp( cc.PixelIdxList{ center_dist == min(center_dist) } ) = 1;
        
        bw_img(:,:,i) = temp;
    end
end


end