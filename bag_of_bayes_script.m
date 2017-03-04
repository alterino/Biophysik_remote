% implements algorithm from Yin et al paper "cell segmentation in
% microscopy imagery using a bag of local bayesian classifiers"

clearvars -except class_labels_img img_2D img_3D

if( ~exist( 'img_2D', 'var' ) )
    img_2D = imread( 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif' );
end

% nonsense just looking for good training images
% img_3D = img_2D_to_img_stack( img_2D, [600, 600] );


% for i = 24:size( img_3D, 3 )
%     
%     figure(1); imshow( img_3D(:,:,i) );
%     title( sprintf( 'showing img %i', i ) );
%     
%     pause
%     
% end

% need to create img_mask before getting to this point - classifying pixels
% and also likely eliminating pixels that we dont want to affect the
% results (like the stupid goddamn black dots in the images)
if( ~exist( 'class_labels_img', 'var' ) )
    load( ' T:\Marino\data\bags_train_1.mat' )
end

wind_size = [5, 15, 25, 45];
samp_pt_cnt = 2000;

% used to collect histograms to eventually calculate mean histogram
data_cell = cell( length(wind_size), 1 );
data_noncell= cell( length(wind_size), 1 );
for i = 1:length(wind_size)
   data_cell{i} = zeros( wind_size(i)^2*samp_pt_cnt, 1 );
   data_noncell{i} = zeros( wind_size(i)^2*samp_pt_cnt, 1 );  
end

% remove image edge pixels from being considered since histogram window
% would extend beyond edge
dims = size( class_labels_img );
class_labels_img( 1:max(wind_size),:) = 2;
class_labels_img( dims(1)-(max(wind_size)-1):dims(1), : ) = 2;
class_labels_img( :, 1:max(wind_size)) = 2;
class_labels_img( :, dims(2)-(max(wind_size)-1):dims(2) ) = 2;

idx_cell = find( class_labels_img == 1 );
idx_noncell = find( class_labels_img == 0 );

[y_cell, x_cell] =  ind2sub( [600,600], idx_cell( randperm( length( idx_cell ), samp_pt_cnt ) ) );
[y_noncell, x_noncell] = ind2sub( [600,600], idx_noncell( randperm( length( idx_noncell ), samp_pt_cnt ) ) );

% figure(1), imshow( img_3D(:,:,24), [] );
% hold on, plot( x_cell, y_cell, 'g*', x_noncell, y_noncell, 'r*' );

% figure(2), title('histograms for cell pixels')
% figure(3), title('histograms for noncell pixels')
% figure(4), title('mean and variance for cell vs noncell pixels')

% current training image
train_img = double( img_3D( :,:,24 ) );

samp_means_cell = zeros( samp_pt_cnt, length( wind_size ) );
samp_stds_cell = zeros( samp_pt_cnt, length( wind_size ) );
samp_means_noncell = zeros( samp_pt_cnt, length( wind_size ) );
samp_stds_noncell = zeros( samp_pt_cnt, length( wind_size ) );

test_means_cell = zeros( samp_pt_cnt, length( wind_size ) );
test_stds_cell = zeros( samp_pt_cnt, length( wind_size ) );
test_means_noncell = zeros( samp_pt_cnt, length( wind_size ) );
test_stds_noncell = zeros( samp_pt_cnt, length( wind_size ) );



for i = 1:samp_pt_cnt
    
    % loop through window sizes for cell point
    x = x_cell(i);
    y = y_cell(i);
    
    for j = 1:length( wind_size )
        inc = floor(wind_size(j)/2);
        temp_wind = train_img( x-inc:x+inc, y-inc:y+inc );
        temp_data = data_cell{j};
        temp_data( (i-1)*wind_size(j)^2+1:i*wind_size(j)^2 ) = temp_wind(:);
        data_cell{j} = temp_data;
        
        temp = mle( temp_wind(:) );
        test_means_cell(i,j) = temp(1);
        test_stds_cell(i,j) = temp(2);
        
        samp_means_cell(i,j) = mean( temp_wind(:) );
        samp_stds_cell(i,j) = std( temp_wind(:) );
    end
    
    % loop through window sizes for noncell point
    x = x_noncell(i);
    y = y_noncell(i);
    
    for j = 1:length( wind_size )
        inc = floor( wind_size(j)/2 );
        temp_wind = train_img( x-inc:x+inc, y-inc:y+inc );
        temp_data = data_noncell{j};
        temp_data( (i-1)*wind_size(j)^2+1:i*wind_size(j)^2 ) = temp_wind(:);
        data_noncell{j} = temp_data;
        
        temp = mle( temp_wind(:) );
        test_means_noncell(i,j) = temp(1);
        test_stds_noncell(i,j) = temp(2);
        
        samp_means_noncell(i,j) = mean( temp_wind(:) );
        samp_stds_noncell(i,j) = std( temp_wind(:) );
    end
    
end

mle_cell = zeros( length( wind_size ), 2 );
mle_noncell = zeros( length( wind_size ), 2 );
for i = 1:length( wind_size )
    temp = mle( data_cell{i} );
    mle_cell( i, : ) = temp;
    temp = mle( data_noncell{i} );
    mle_noncell( i,: ) = temp;
    
    figure, hist( data_cell{i}, 100 ), title( sprintf( 'cell hist for n=%i', wind_size(i) ) )
    xlim( [0 2*10^4] )
    figure, hist( data_noncell{i}, 100 ), title( sprintf( 'noncell hist for n=%i', wind_size(i) ) )
    xlim( [0 2*10^4] )
end

% figure(1), ylim( [0 9*10^3] );
% figure(2), ylim( [0 9*10^3] );
% figure(3), ylim( [0 10*10^4] );
% figure(4), ylim( [0 10*10^4] );
% figure(5), ylim( [0 3*10^5] );
% figure(6), ylim( [0 3*10^5] );
% figure(7), ylim( [0 9*10^5] );
% figure(8), ylim( [0 9*10^5] );





