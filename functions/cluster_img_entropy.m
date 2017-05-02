function labeled_img = cluster_img_entropy(img, stack_dims, gmm, wind, sizeThresh)

img_stack = img_2D_to_img_stack( img, stack_dims );
img_ent = entropyfilt( img_stack, ones(wind,wind) );
img_ent = img_stack_to_img_2D(img_ent, [15 15]);
se = strel('disk',9);
ent_smooth = imclose(img_ent, se);
num_clusts = length(gmm.mu);

idx = reshape(cluster(gmm, ent_smooth(:)), size(ent_smooth));
% toc();

% Order the clustering so that the indices are from min to max cluster mean
[~,sorted_idx] = sort(gmm.mu);
temp = zeros(num_clusts,1);
for j = 1:num_clusts
    temp(j) = find( sorted_idx == j );
end
sorted_idx = temp; clear temp
% some weird bug is happening here but I think the above fixed it
new_idx = sorted_idx(idx); %**********************

bwInterior = (new_idx > 1);
cc = bwconncomp(bwInterior);

bSmall = cellfun(@(x)(length(x) < sizeThresh), cc.PixelIdxList);

new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;
labeled_img = new_idx;
% labeled_img = ( new_idx > 1 );

end