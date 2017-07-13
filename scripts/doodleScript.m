%%

if( ~exist( 'this', 'var' ) )
    this = CoverslideScanner;
end
if( ~exist( 'dic_scan', 'var' ) )
    %     temp_img = imread('D:\OS_Biophysik\Microscopy\170706\DIC_170706_1455.tif' );
    dic_scan = imread('T:\Marino\Microscopy\170706\DIC_170706_1455.tif' );
end
if( ~exist( 'fluor_scan', 'var' ) )
    fluor_scan = imread('T:\Marino\Microscopy\170706\Fluor_405_170706_1510.tif' );
end
temp_dic_stack = img_2D_to_img_stack( temp_dic, [1200 1200] );
temp_fluor_stack = img_2D_to_img_stack( temp_fluor, [1200 1200] );
data_type = class( temp_dic );
dic_resize = zeros( 600, 600, 225, data_type );
fluor_resize = zeros( 600, 600, 225, data_type );

for i = 1:size( temp_dic_stack, 3 )
    dic_resize(:,:,i) = imresize( temp_dic_stack(:,:,i), 1/2 );
    fluor_resize(:,:,i) = imresize( temp_fluor_stack(:,:,i), 1/2 );
end

dic_resize = img_stack_to_img_2D( dic_resize, [15 15] );
fluor_resize = img_stack_to_img_2D( fluor_resize, [15 15] );

this.Acq.imgOV = dic_resize;
this.eval_DIC_scan( 9 );

% figure(1), subplot(1,2,1), imshow( im, [] );
% subplot(1,2,2), imshow( img_ent(:,:,i), [] )

test1 = img_2D_to_img_stack( dic_scan, [600 600] );
test2 = img_2D_to_img_stack( bw_img, [600 600] );
test3 = img_2D_to_img_stack( img_ent, [600 600] );
test4 = img_2D_to_img_stack( ent_smooth, [600 600] );
test5 = img_2D_to_img_stack( bw_img2, [600 600] );

figure(2)
for i = 1:size( test1, 3 )
    perim1 = bwperim( test2(:,:,i) );
    perim2 = bwperim( test5(:,:,i) );
    temp1 = test1(:,:,i); temp1( perim1 ) = max(max(temp1));
    temp2 = test1(:,:,i); temp2( perim2 ) = max(max(temp2));
    figure(2), subplot( 1,2,1 ), imshow( temp1, [] )
    subplot( 1,2,2 ), imshow( test4(:,:,i), [] )
    figure(3), subplot( 1,2,1 ), imshow( temp2, [] )
    subplot( 1,2,2 ), imshow( test3(:,:,i), [] )
    pause
end

%%
if( ~exist( 'img', 'var' ) )
    img = imread('T:\Marino\Microscopy\Raw Images for Michael\higher signal to noise\sample 1\cell 3 after 488 20% LP.tif');
end
img_dims = size(img);
[bw_img, img_stats] = threshold_fluor_img( img, 1000 );


[thetaD, pattern, x_guess, width_guess] = est_pattern_orientation( img, bw_img );

[x, x_p, y, theta_update] = find_stripe_locations( thetaD, img, pattern, img_dims );
stripe_bw = ...
    generate_stripe_bw( round(x_p), theta_update, img_dims, round(width_guess), bw_img  );

%%
[bw_img, cc, stats] = ...
    process_and_label_DIC( dic_scan, img_dims, wind );


img_corr = conv2( double(img), double(pattern) );
%%
figure(1), cla
figure(1), imshow( bw_img );
figure(2), imshow( pattern );
figure(3), imshow( img, [] );
figure(6), imshow( stripe_bw, [] )
figure(8), imagesc( img_corr );
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

for j = 1:size( dic_stack, 3 )
    figure(1), imshow( dic_stack(:,:,j) )
    figure(2), imshow( fluor_stack(:,:,j) )
    pause
    
    
    
end
