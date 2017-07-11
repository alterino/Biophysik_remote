function [gmm, img_ent] = generate_gmm_entropy(img_stack, block_dims, wind, num_clusts)

img_ent = zeros( size( img_stack ) );

for i = 1:size(img_stack,3)
    im = img_stack(:,:,i);
    img_ent(:,:,i) = entropyfilt(im, ones(wind,wind));
end

img_ent = img_stack_to_img_2D( img_ent, block_dims );

se = strel('disk',9);
ent_smooth = imclose(img_ent, se);

skip_size = 30;
ent_vector = ent_smooth(:);
options = statset( 'MaxIter', 200 );
gmm = fitgmdist(ent_vector(1:skip_size:end), num_clusts, 'replicates',3, 'Options', options);

end