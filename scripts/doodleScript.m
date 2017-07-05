
if( ~exist( 'img', 'var' ) )
    img = imread('D:\OS_Biophysik\Microscopy\Raw Images for Michael\higher signal to noise\sample 1\cell 3 after 488 20% LP.tif');
end
[bw_img, img_stats] = threshold_fluor_img( img, 1000 );

[thetaD, pattern, img_corr, x_guess] = est_pattern_orientation( img, bw_img );

stripe_centers = find_stripe_locations( thetaD, img_corr, 80, x_guess );


%%
figure(1), cla
figure(1), imshow( bw_img );
figure(2), imshow( pattern );
figure(3), imshow( img, [] );

%% 

tic
theta = 0:.1:180;
rad_bw = radon( bw_img, theta );
figure(4), imagesc( rad_bw );
imtool( rad_bw, [] );

surf( theta, (1:size(rad_bw, 2)), rad_bw );
