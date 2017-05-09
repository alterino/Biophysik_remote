% seagate filepath 
img = imread( 'F:\osna_backups\160308\Sample3\DIC_160308_2033.tif' );
% lab filepath
% img = imread( 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif' );
dims = [600 600];
img_stack = img_2D_to_img_stack( img, dims );

% ROI_cell = cell( size( img_stack, 3 ), 1 );
% seagate filepath
filepath_out = 'F:\osna_backups\160308\Sample3\DIC_160308_2033_labels.mat';
% lab filepath
% filepath_out = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033_labels.mat';

load( filepath_out );



for i = 1:size( img_stack, 3 )
    if( ~isempty( ROI_cell{i} ) )
        fprintf( 'img %i of %i already complete, moving on...\n',...
                                                   i, size( img_stack, 3) )
        continue
    end
    
    ROI_cell{i} = IMG_ROI( img_stack(:,:,i ) ); 
    fprintf( 'img %i of %i binarized\n', i, size( img_stack, 3) )
    save( filepath_out, 'ROI_cell' );
end
