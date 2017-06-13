%
% % img_stack = img_2D_to_img_stack( imread( 'D:\OS_Biophysik\Microscopy\DIC_160308_2033.tif' ), [600, 600] );
% % load( 'D:\OS_Biophysik\Microscopy\DIC_160308_2033_labels_edited_latest7.mat' )
% % out_dir = 'D:\OS_Biophysik\training_data\';
%
% for i = 1:length( ROI_cell )
%
%     img = imresize( img_stack(:,:,i), 1/3 );
%     ROI = ROI_cell{i};
%     label_mat = imresize( uint8( ROI_to_label_img(ROI) ), 1/3 );
%     label_mat(label_mat==2) = 1;
%     label_mat = uint8(label_mat == 1);
%
%     img_str = sprintf( 'DIC_160308_2033_%03i_img.png', i );
%     label_str = sprintf('DIC_160308_2033_%03i_lab.png', i );
%
%     imwrite( img, strcat( out_dir, img_str ) );
%     imwrite( label_mat, strcat( out_dir, label_str ) );
%
%     %     figure(1), subplot(1,2,1), imshow( img, [] );
%     %     subplot(1,2,2), imshow( label_mat, [] );
%     %     title( sprintf('i=%i',i) )
%
% end

if( ~exist( 'fluor_stack', 'var' ) )
    dirpath = 'D:\OS_Biophysik\Microscopy\150925\';
    fluor_scan = imread( strcat( dirpath, '488_Scan_HD.tif' ));
    fluor_stack = img_2D_to_img_stack(fluor_scan, [600 600]);
    clear dirpath fluor_scan
end

for i = 1:size( fluor_stack )
   
    [imgbw, cc, img_stats] = threshold_fluor_img( fluor_stack(:,:,i), 1000 );
    num_hot = sum( sum( imgbw ) );
    
    figure(1)
    subplot(1,2,1), imshow( fluor_stack(:,:,i), [] );
    title( sprintf('var = %.2f, max = %.2f, count = %i', img_stats.var, img_stats.max, num_hot ) )
    subplot(1,2,2), imshow( imgbw, [] );

end