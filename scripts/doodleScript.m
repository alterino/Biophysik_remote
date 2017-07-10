
if( ~exist( 'img', 'var' ) )
    img = imread('T:\Marino\Microscopy\Raw Images for Michael\higher signal to noise\sample 1\cell 3 after 488 20% LP.tif');
end
img_dims = size(img);
[bw_img, img_stats] = threshold_fluor_img( img, 1000 );


[thetaD, pattern, img_corr, x_guess, width_guess] = est_pattern_orientation( img, bw_img );

[x, x_p, y, theta_update] = find_stripe_locations( thetaD, img, pattern, img_dims );
stripe_bw = ...
    generate_stripe_bw( round(x_p), theta_update, img_dims, round(width_guess), bw_img  );

%%
[bw_img, cc, stats] = ...
    process_and_label_DIC( dic_scan, img_dims, wind );



%%
figure(1), cla
figure(1), imshow( bw_img );
figure(2), imshow( pattern );
figure(3), imshow( img, [] );
figure(6), imshow( stripe_bw, [] )
perim = bwperim( stripe_bw );
temp = img; temp(perim) = max(max(temp));
figure(7), imshow( temp, [] )
y_p = size(img,2)/2*ones(length(x_p),1);
figure(7), hold on, plot( x_p, y_p , 'r*',...
                            x, y, 'b*')

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

% testing radon outputs

% theta = 45;
% idx = 1;
% for i = 400:10:1200  
%     test_dim2(idx) = size( radon( zeros( i, i ), theta ),1 );
%     dim_guess2(idx) = sqrt( (i)^2 + (i^2) );
%     dim_diff2(idx) = test_dim2(idx) - dim_guess2(idx);
%     idx = idx + 1;
% end

