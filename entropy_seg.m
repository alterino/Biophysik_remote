clearvars -except testIMG

% lab path
imgPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif';
outPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\';

% home path
% imgPATH = 'D:\OS_Biophysik\DIC_images\DIC_160308_2033.tif';
% outPATH = 'D:\OS_Biophysik\Processed\';

if( ~exist( 'testIMG' ) )
    testIMG = imread(imgPATH);
end

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
clear tempIDX
imgCount = size(imgStack, 3);
img_ent = zeros( size( imgStack ) );

for i = 1:imgCount
    
    im = imgStack(:,:,i);
    
    % Search for texture in the image
    img_ent(:,:,i) = entropyfilt(im, ones(9,9));
end

img_ent = img_stack_to_img_2D( img_ent, [15 15] );

se = strel('disk',9);
ent_smooth = imclose(img_ent, se);
figure(3);imagesc(ent_smooth);colormap(gray)

tic();
skip_size = 30;
ent_vector = ent_smooth(:);
options = statset( 'MaxIter', 200 );
gmm = fitgmdist(ent_vector(1:skip_size:end), 3, 'replicates',3, 'Options', options);
idx = reshape(cluster(gmm, ent_smooth(:)), size(ent_smooth));
toc();

% Order the clustering so that the indices are from min to max cluster mean
[~,sorted_idx] = sort(gmm.mu);
new_idx = sorted_idx(idx);

figure(4);imagesc(new_idx)

% eliminate all objects below minimum size threshold, considering connected
% pixels of class ( 2 || 3 ) as objects

bwInterior = (new_idx > 1);
cc = bwconncomp(bwInterior);

sizeThresh = 10000;
bSmall = cellfun(@(x)(length(x) < sizeThresh), cc.PixelIdxList);

new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;

figure(5);imagesc(new_idx)

% without doing anything else, lets see how the segmentation is just using
% the classes 2 and 3 as belonging to cells

img_segged_bw = ( new_idx > 1 );

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
                          
summary_stats = evaluate_seg_results( img_bw_stack, ground_truth_img, ROI_cell );

summary_stats( ignore_list ) = [];

detection_rate = mean( [summary_stats.detection_rate] );
accuracy_rate = mean( [summary_stats.accuracy ] );
detected_cells = sum( [summary_stats.detected_cells] );
missed_cells = sum( [summary_stats.missed_cells] );


cell_detection_rate = detected_cells / ( missed_cells + detected_cells );
                          








