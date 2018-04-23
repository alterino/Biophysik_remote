scan_path = '/home/mmarino/pile/OS_Biophysics/Microscopy/170706/Fluor_405_170706_1619.tif';
flour_scan = imread(scan_path);
figure(1), imshow( flour_scan, [] )
img_dims = [1200, 1200];
flour_stack = img_2D_to_img_stack(flour_scan, img_dims);

img_vec = flour_stack(:);
img_vec(img_vec == 0) = [];
intensity_thresh = multithresh( img_vec, 1 );
size_thresh = 2000;

for j = 1:size(flour_stack, 3)
    img = flour_stack(:,:,j);
    img_var = var( var( double( img ) ) );
    
    if( img_var < 1e5 )
        continue
    end
    
    bw_fluor = threshold_fluor_img( img, intensity_thresh, size_thresh );
    [thetaD, pattern, x_guess, width_guess] = est_pattern_orientation( img, bw_fluor );
    
    if( ~isempty( thetaD ) )
        
        bw_dic = ones( size( img ), 'logical' );
        [x, x_p, y, x_dists] = find_stripe_locations( thetaD, img, pattern, img_dims );

    end
    
end