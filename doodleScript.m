% 
% img = imread('T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif');
% 
% img_stack = img_2D_to_img_stack( img, [600, 600] );
% 
% bullshit_img_idx = [13, 16, 22, 32, 37, 38, 42, 43, 45, 47, 52, 58, 70, 72,...
%     73, 74, 87, 88, 92, 94, 96, 101, 102, 103, 105, 107, 109, 110, 111,...
%     124, 125, 126, 134, 139, 150, 152, 155, 161, 162, 165, 169, 170, 176,...
%     177, 179, 185, 186, 187, 190, 200, 201, 205, 206, 209, 210, 212, 216,...
%     217, 218, 223, 224, 225];
% 
% % bullshit_imgs = img_stack( bullshit_img_idx );
% % img_stack(:,:,bullshit_img_idx) = [];
% 
% for i = 1:size( img_stack, 3 )
%     
%     temp_img = im2double( img_stack(:,:,i) );
%     total_entropy = entropy( temp_img );
%     total_std = std( temp_img(:) );
%     
%     sx_3x3 = [1, 0, -1; 2, 0, -2; 1, 0 -1];
%     sy_3x3 = fliplr( sx_3x3 )';
%     sx_5x5 = [1 2 0 -2 -1; 4 8 0 -8 -4; 6 12 0 -12 -6; 4 8 0 -8 -4; 1 2 0 -2 -1];
%     sy_5x5 = fliplr( sx_5x5 )';
%     
%     img_grad3_mag = sqrt( imfilter(temp_img, sx_3x3, 'replicate' ).^2 +...
%                             imfilter( temp_img, sy_3x3, 'replicate' ).^2 );
%     img_grad5_mag = sqrt( imfilter(temp_img, sx_5x5, 'replicate' ).^2 +...
%                             imfilter( temp_img, sy_5x5, 'replicate' ).^2 );
%     
%     img_grad3_dir = atan( imfilter( temp_img, sy_3x3, 'replicate' )./...
%                                 imfilter(temp_img, sx_3x3, 'replicate' ) );
%     img_grad5_dir = atan( imfilter( temp_img, sy_5x5, 'replicate' )./...
%                                 imfilter(temp_img, sx_5x5, 'replicate' ) );
%     
%     edge_bw = edge( temp_img );
%     
%     nhood = strel( 'disk', 5 );
%     local_std = stdfilt( temp_img, nhood.Neighborhood );
%     local_entropy = entropyfilt( temp_img, nhood.Neighborhood );
%     
% %     img_compound_1 = [ temp_img, edge_bw];
%     %     img_compound_2 = [ img_grad3_mag, img_grad5_mag ];
%     %     img_compound_3 = [local_std, local_entropy];
%     
%     img_grad3_bw = imbinarize( img_grad3_mag, graythresh( img_grad3_mag ) );
%     img_grad5_bw = imbinarize( img_grad5_mag, graythresh( img_grad5_mag ) );
%     local_std_bw = imbinarize( local_std, graythresh( local_std ) );
%     local_entropy_bw = imbinarize( local_entropy, graythresh( local_entropy ) );
%     
%     % linear structure elements used for dilation
%     se90 = strel('line', 5, 90);
%     se0 = strel('line', 5, 0);
%     seD = strel('diamond',3);
%     
%     grad5_std_bw = or( img_grad5_bw, local_std_bw );
%     img_out_bw = imfill( imdilate( grad5_std_bw, [se90 se0] ), 'holes' );
%     img_out_bw = imerode( img_out_bw, seD );
%     
%     img_out_edgemap = bwperim( img_out_bw );
%     img_out_segged = temp_img;
%     img_out_segged( img_out_edgemap == 1 ) = 1;
%     img_compound_1 = [img_out_segged, edge_bw];
%     
%     figure(1), imshow( img_compound_1, [] )
%     title( sprintf( 'DIC image and edge map, entropy = %.2d, std = %.3d\n', total_entropy, total_std ) );
%     
%     figure(2), subplot( 2,2,1 ), imshow( img_grad3_mag, [] )
%     subplot(2,2,2), imshow( img_grad5_mag, [] )
%     subplot(2,2,3), imshow( local_std, [] )
%     subplot(2,2,4), imshow( local_entropy, [] )
%     
%     figure(3), subplot( 2,2,1 ), imshow( img_grad3_bw, [] )
%     subplot(2,2,2), imshow( img_grad5_bw, [] )
%     subplot(2,2,3), imshow( local_std_bw, [] )
%     subplot(2,2,4), imshow( local_entropy_bw, [] )
% end
% 
% for i = 1:size( imgStack, 3 )
%     
%    figure(1), subplot(1,2,1), imshow(  imgStack(:,:, i), [] ) 
%    subplot(1,2,2), imshow( img_segged_stack( :,:, i ), [] )
%    title( sprintf( 'image number %i', i ) )
%    pause
%     
%     
% end
% 
% for i = 20:size( f_stack, 2 )
%    temp_vec = f_stack( :, i );
%    temp_img = reshape( temp_vec, dims(2), dims(1) );
%    
%    figure(1), imshow( temp_img, [] );
%    title( sprintf( 'iteration: %i', i ) );
%    pause(.5)
%     
% end


% for i = 1:length( temp_idx )
%     
%     file_str = sprintf( 'image_idx_%i', temp_idx(i) );
%     
%     temp_img =  double( imgStack( :,:, temp_idx(i) ) );
%     temp_img = im2uint8( (temp_img - min(min(temp_img)))/(max(max(temp_img)) - min(min(temp_img))) );
% %     temp_bw = img_bw_stack( :,:, temp_idx(i) );
% %     temp_ent = img_stack_ent( :, :, temp_idx(i) );
% %     
%     file_str_raw = strcat( out_dir, file_str, '_raw.tif' );
% %     file_str_ent = strcat( out_dir, file_str, '_ent.png' );
% %     file_str_bw = strcat( out_dir, file_str, '_ent_bw.png' );
% %     
% %     temp_ent = (temp_ent - min(min(temp_ent)));
% %     temp_ent = temp_ent/max(max(temp_ent));
% %     
%     imwrite( temp_img, file_str_raw );
% %     imwrite( temp_ent, file_str_ent );
% %     imwrite( temp_bw, file_str_bw );
%     
% end

new_idx = imquantize( f_img, multithresh( img_ent,  ) );
figure(4);imagesc(new_idx)

