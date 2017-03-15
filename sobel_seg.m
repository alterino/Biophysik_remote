clearvars -except testIMG

% lab path
imgPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif';
% outPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\';

% home path
% imgPATH = 'D:\OS_Biophysik\DIC_images\DIC_160308_2033.tif';
% outPATH = 'D:\OS_Biophysik\Processed\';

if( ~exist( 'testIMG' ) )
    testIMG = imread(imgPATH);
end
clear imgPATH

figure(1);imagesc(testIMG);colormap(gray)

dims = size(testIMG);

numCols = dims(2)/600;
numRows = dims(1)/600;
imgStack = uint16(zeros(600, 600, numCols*numRows));

% segManager = classSegmentationManager;

% breaking up larger image
tempIDX = 0;
for i=1:numCols
    for j=1:numRows
        tempIDX = tempIDX + 1;
        imgStack( :,:, tempIDX ) =...
            uint16( testIMG( 600*(i-1)+1:600*i, 600*(j-1)+1:600*j ) );
    end
end
clear tempIDX numCols numRows
imgCount = size(imgStack, 3);
img_sob = zeros( size( imgStack ) );

tic

for i = 1:imgCount
    
    im = imgStack(:,:,i);
    % Search for texture in the image
    img_sob(:,:,i) = imgradient(im);
end

img_sob = img_stack_to_img_2D( img_sob, [15 15] );

se = strel('disk',9);
sob_smooth = imclose(img_sob, se);
figure(3);imagesc(sob_smooth);colormap(gray)
clear se

% num_clusts = 2;
% % % this one uses gmm model *************************
% % tic();
% skip_size = 40;
% sob_vector = sob_smooth(:);
% options = statset( 'MaxIter', 200 );
% gmm = fitgmdist(sob_vector(1:skip_size:end), num_clusts, 'replicates', 3, 'Options', options);
% idx = reshape(cluster(gmm, sob_smooth(:)), size(sob_smooth));
% % toc();
% clear skip_size options sob_vector
%
% % Order the clustering so that the indices are from min to max cluster mean
% [~,sorted_idx] = sort(gmm.mu);
% temp = zeros(num_clusts,1);
% for j = 1:num_clusts
%     temp(j) = find( sorted_idx == j );
% end
% sorted_idx = temp;
% new_idx = sorted_idx(idx);
clear sorted_idx temp % **********************

% % this one uses otzu thresholding ******************************
new_idx = imquantize( img_sob, multithresh( img_sob, 2 ) );
figure(4);imagesc(new_idx)

% eliminate all objects below minimum size threshold, considering connected
% pixels of class ( 2 || 3 ) as objects

bwInterior = (new_idx > 1);
cc = bwconncomp(bwInterior);

sizeThresh = 10000;
bSmall = cellfun(@(x)(length(x) < sizeThresh), cc.PixelIdxList);

new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;
clear bSmall cc

figure(5);imagesc(new_idx)

% without doing anything else, lets see how the segmentation is just using
% the classes 2 and 3 as belonging to cells

img_segged_bw = ( new_idx > 1 );

tot_time = toc;

img_segged = testIMG;
img_segged( bwperim( ( new_idx > 1 ) ) == 1 ) = max(max(testIMG));

img_segged_stack = img_2D_to_img_stack( img_segged, [600, 600] );
img_bw_stack = img_2D_to_img_stack( ( new_idx > 1 ), [600, 600] );

figure(6), imshow( img_segged, [] )

% for i = 1:size( img_segged_stack, 3 )
%
%     figure(7); subplot(1,2,1), imagesc( img_segged_stack(:,:,i)); colormap(gray);
%     subplot( 1,2,2 ), imagesc( img_bw_stack(:,:,i) ); colormap(gray);
%     pause
%
% end

ground_truth_file = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033_labels.mat';

load( ground_truth_file );

ignore_list = [13, 16, 22, 32, 37, 38, 42, 43, 45, 47, 52, 58, 70, 72,...
    73, 74, 87, 88, 92, 94, 96, 101, 102, 103, 105, 107, 109, 110, 111,...
    124, 125, 126, 134, 139, 140, 150, 152, 155, 161, 162, 165, 169, 170, 176,...
    177, 179, 185, 186, 187, 190, 200, 201, 205, 206, 209, 210, 212, 216,...
    217, 218, 223, 224, 225];

[ ground_truth_img, cell_cnts, cell_pix_cnts] =...
    bw_stack_from_roi_cell(ROI_cell, [600 600], ignore_list );


[summary_stats, missed_pics_idx] = evaluate_seg_results( img_bw_stack, ground_truth_img, ROI_cell );

summary_stats( ignore_list ) = [];

detection_rate = mean( [summary_stats.detection_rate] );
false_rate = mean( [summary_stats.false_positive_rate] );
accuracy_rate = mean( [summary_stats.accuracy ] );
detected_cells = sum( [summary_stats.detected_cells] );
missed_cells = sum( [summary_stats.missed_cells] );


cell_detection_rate = detected_cells / ( missed_cells + detected_cells );

temp_idx = [16, 17, 20, 23, 24, 25, 27, 28];

img_stack_classes = img_2D_to_img_stack( new_idx, [600 600] );
img_stack_sob = img_2D_to_img_stack( img_sob, [600 600] );

out_dir = 'T:\Marino\presentation_files\';

for i = 1:length( temp_idx )
    
    file_str = sprintf( 'image_idx_%i', temp_idx(i) );
    
    temp_bw = img_bw_stack( :,:, temp_idx(i) );
    temp_sob = img_stack_sob( :, :, temp_idx(i) );
    
    sat = 0.05;
    lim = quantile(temp_sob,[sat,1-sat]);
    temp_sob = min(1,max(0,(temp_sob-lim(1))/(lim(2)-lim(1))));
    
    file_str_sob = strcat( out_dir, file_str, '_sob.png' );
    file_str_bw = strcat( out_dir, file_str, '_sob_bw.png' );
    
    temp_sob = (temp_sob - min(min(temp_sob)));
    temp_sob = temp_sob/max(max(temp_sob));
    
    %     imwrite( temp_img, file_str_raw );
    imwrite( temp_sob, file_str_sob );
    imwrite( temp_bw, file_str_bw );
    
end










