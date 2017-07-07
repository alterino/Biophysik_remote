
if( ~exist( 'img', 'var' ) )
    img = imread('T:\Marino\Microscopy\Raw Images for Michael\higher signal to noise\sample 1\cell 3 after 488 20% LP.tif');
end
img_dims = size(img);
[bw_img, img_stats] = threshold_fluor_img( img, 1000 );

[thetaD, pattern, img_corr, x_guess] = est_pattern_orientation( img, bw_img );

stripe_centers = find_stripe_locations( thetaD, img_corr, img_dims );

%%

[bw_img, cc, stats] = ...
    process_and_label_DIC( dic_scan, img_dims, wind );




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

%%
figure(4), plot( 1:873, sum_normalized );
test = find( zero_crossings == 1 );
hold on, plot( test, sum_normalized(test), 'r*' )

