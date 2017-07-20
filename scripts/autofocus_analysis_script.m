% load('T:\Marino\data\autofocustest3.mat')

opt_imgs = zeros( size( imgs{1,1}, 1 ), size( imgs{1,1}, 2)*3, numel(imgs) );
img_cnt = 0;
opt_idx = zeros( numel(imgs), 2);
for i = 1:size( grad_cell, 1 )
    for j = 1:size( grad_cell, 2 )
        
        img_cnt = img_cnt + 1;
        
        img_stack = imgs{i,j};
        if( isempty( img_stack ) )
            continue
        end
        var_vec = var_cell{i,j};
        grad_vec = grad_cell{i,j};
        for k = 1:size( img_stack, 3 )
           figure(3), imshow( img_stack(:,:,k), [] )
           pause(.1)
        end
        
        opt_imgs( :, 1:600, img_cnt ) = img_stack(:,:,11);
        opt_idx(img_cnt, 1) = find( var_vec == max( var_vec ) );
        opt_imgs(:, 601:1200, img_cnt ) = img_stack(:,:,opt_idx(img_cnt, 1));
        opt_idx(img_cnt, 2) = find( grad_vec == max( grad_vec ) );
        opt_imgs(:, 1201:1800, img_cnt ) = img_stack(:,:,opt_idx(img_cnt, 1));
        
        
        figure(1), imshow( opt_imgs(:,:,img_cnt), [] )
        title(sprintf('var idx=%i, grad idx=%i', opt_idx(img_cnt, 1), opt_idx(img_cnt, 2) ) )
        figure(2), subplot(1,2,1)
        title('variance vs z position'),  plot( zPosition_vec, var_vec, 'g-' )
        subplot( 1,2,2)
        title('gradient vs z position'), plot( zPosition_vec, grad_vec, 'r-' );
    end
end