
% img_stack = img_2D_to_img_stack( imread( 'D:\OS_Biophysik\Microscopy\DIC_160308_2033.tif' ), [600, 600] );
% load( 'D:\OS_Biophysik\Microscopy\DIC_160308_2033_labels_edited_latest7.mat' )
% out_dir = 'D:\OS_Biophysik\training_data\';

for i = 1:length( ROI_cell )
   
    img = imresize( img_stack(:,:,i), 1/3 );
    ROI = ROI_cell{i};
    label_mat = imresize( uint8( ROI_to_label_img(ROI) ), 1/3 );
    label_mat(label_mat==2) = 1;
    label_mat = uint8(label_mat == 1);
    
    img_str = sprintf( 'DIC_160308_2033_%03i_img.png', i );
    label_str = sprintf('DIC_160308_2033_%03i_lab.png', i );
    
    imwrite( img, strcat( out_dir, img_str ) );
    imwrite( label_mat, strcat( out_dir, label_str ) );
    
%     figure(1), subplot(1,2,1), imshow( img, [] );
%     subplot(1,2,2), imshow( label_mat, [] );
%     title( sprintf('i=%i',i) )
    
end