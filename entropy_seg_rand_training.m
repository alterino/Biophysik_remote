clearvars -except testIMG

% lab path
imgPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif';
outPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\';

% home path
% imgPATH = 'D:\OS_Biophysik\DIC_images\DIC_160308_2033.tif';
% outPATH = 'D:\OS_Biophysik\Processed\';

if( ~exist( 'testIMG', 'var' ) )
    testIMG = imread(imgPATH);
end

% figure(1);imagesc(testIMG);colormap(gray)

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
img_ent_stack = zeros( size( imgStack ) );

tic

for i = 1:imgCount
    im = imgStack(:,:,i);
    
    % Search for texture in the image
    img_ent_stack(:,:,i) = entropyfilt(im, ones(9,9));
end

add_time_base =  toc;

img_ent = img_stack_to_img_2D( img_ent_stack, [15 15] );



se = strel( 'disk',9 );
ent_smooth = imclose( img_ent, se );
% figure(3);imagesc(ent_smooth);colormap(gray)

summary_stats = struct([]);

% load( 'entropy_rand_samp_data.mat', 'summary_stats' )
stat_idx = 1;

for i = 5:10:size( imgStack, 3 )
    
    rand_idx = randsample( size( imgStack, 3 ), i );
    
    tic
    
    train_ent = zeros( 600, 600, length( rand_idx ) );
    
    for j = 1:length( rand_idx )
        train_ent(:,:,j) = img_ent_stack(:,:,rand_idx(j) );
    end
    
    train_ent = imclose( train_ent, se );
    train_ent_vector = train_ent(:);
    
    add_time = add_time_base - toc;
    
    % tic();
    skip_size = 30;
    ent_vector = ent_smooth(:);
    options = statset( 'MaxIter', 200 );
    gmm = fitgmdist(train_ent_vector(1:skip_size:end), 3, 'replicates',3, 'Options', options);
    idx = reshape(cluster(gmm, ent_smooth(:)), size(ent_smooth));
    % toc();
    
    % Order the clustering so that the indices are from min to max cluster mean
    [~,sorted_idx] = sort(gmm.mu);
    temp = zeros(3,1);
    for j = 1:3
       temp(j) = find( sorted_idx == j ); 
    end
    sorted_idx = temp; clear temp
    % some weird bug is happening here but I think the above fixed it
    new_idx = sorted_idx(idx);
    
    % bug line was just using new_idx = sorted_idx(idx) without loop
    % before it. why didnt that work before?? check documentation
    
    % figure;imagesc(new_idx); colormap(gray)
    
    % eliminate all objects below minimum size threshold, considering connected
    % pixels of class ( 2 || 3 ) as objects
    
    bwInterior = (new_idx > 1);
    cc = bwconncomp(bwInterior);
    
    sizeThresh = 10000;
    bSmall = cellfun(@(x)(length(x) < sizeThresh), cc.PixelIdxList);
    
    new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;
    
    % figure(5);imagesc(new_idx)
    
    % without doing anything else, lets see how the segmentation is just using
    % the classes 2 and 3 as belonging to cells
    
    img_segged_bw = ( new_idx > 1 );
    
    tot_time = toc + add_time;
    
    img_segged = testIMG;
    img_segged( bwperim( ( new_idx > 1 ) ) == 1 ) = max(max(testIMG));
    
    img_segged_stack = img_2D_to_img_stack( img_segged, [600, 600] );
    img_bw_stack = img_2D_to_img_stack( ( new_idx > 1 ), [600, 600] );
    
    % figure(6), imshow( img_segged, [] )
    
    % for i = 1:size( img_segged_stack, 3 )
    %
    %     % figure(7); subplot(1,2,1), imagesc( img_segged_stack(:,:,i)); colormap(gray);
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
    
    
    [ ground_truth_img, cell_cnts, cell_pix_cnts ] =...
        bw_stack_from_roi_cell(ROI_cell, [600 600], ignore_list );
    
    summary_stats_individual = evaluate_seg_results( img_bw_stack, ground_truth_img, ROI_cell );
    
    summary_stats_individual( ignore_list ) = [];
    
    
    summary_stats( stat_idx ).detection_rate = mean( [summary_stats_individual.detection_rate] );
    summary_stats( stat_idx ).false_rate = mean( [summary_stats_individual.false_positive_rate] );
    summary_stats( stat_idx ).accuracy_rate = mean( [summary_stats_individual.accuracy ] );
    detected_cells = sum( [summary_stats_individual.detected_cells] );
    missed_cells = sum( [summary_stats_individual.missed_cells] );
    summary_stats( stat_idx ).cell_detection_rate = detected_cells/(missed_cells + detected_cells);
    summary_stats( stat_idx ).time = tot_time;
    summary_stats( stat_idx ).rand_idx = rand_idx;
    summary_stats( stat_idx ).gmm = gmm;
    
    
    fprintf( '%i training samples, accuracy rate: %.3f, detected_cells: %.3f, t = %i \n',...
        i, summary_stats( stat_idx ).accuracy_rate,...
        summary_stats( stat_idx ).cell_detection_rate, tot_time );
    stat_idx = stat_idx + 1;
    
end

save( 'entropy_rand_samp_data_updated.mat', 'summary_stats' )





