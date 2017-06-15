

% if( ~exist( 'fluor_stack', 'var' ) )
%     dirpath = 'D:\OS_Biophysik\Microscopy\150925\';
%     fluor_scan = imread( strcat( dirpath, '488_Scan_HD.tif' ));
%     fluor_stack = img_2D_to_img_stack(fluor_scan, [600 600]);
%     clear dirpath fluor_scan
% end
% 
% for i = 1:size( fluor_stack )
%    
%     [imgbw, cc, img_stats] = threshold_fluor_img( fluor_stack(:,:,i), 1000 );
%     num_hot = sum( sum( imgbw ) );
%     
%     figure(1)
%     subplot(1,2,1), imshow( fluor_stack(:,:,i), [] );
%     title( sprintf('var = %.2f, max = %.2f, count = %i', img_stats.var, img_stats.max, num_hot ) )
%     subplot(1,2,2), imshow( imgbw, [] );
% 
% end

img_dir = dir('T:\Marino\Microscopy\single molecule stripe pattern\S1\*.tif');

for i = 1:length( img_dir )
    
    
   img = imread( strcat( img_dir(i).folder, '\', img_dir(i).name ) ); 
   
   
    [imgbw, cc, img_stats] = threshold_fluor_img( img, 1000 );
    figure(1), subplot(1,2,1), imshow( img, [] );
    title( sprintf( 'var = %i, max = %i', img_stats.var, img_stats.max ));
    subplot(1,2,2), imshow( imgbw );
   
   
end

img_dir = dir('T:\Marino\Microscopy\single molecule stripe pattern\S2\*.tif');

for i = 1:length( img_dir )
    
    
   img = imread( strcat( img_dir(i).folder, '\', img_dir(i).name ) ); 
   
   
    [imgbw, cc, img_stats] = threshold_fluor_img( img, 1000 );
    figure(1), subplot(1,2,1), imshow( img, [] );
    title( sprintf( 'var = %i, max = %i', img_stats.var, img_stats.max ));
    subplot(1,2,2), imshow( imgbw );
   
   
end




























