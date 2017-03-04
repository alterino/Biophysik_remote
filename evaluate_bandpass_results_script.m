ground_truth_file = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033_labels.mat';
binary_dir = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\';

dic_img = imread( 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif' );
dic_img_stack = img_2D_to_img_stack( dic_img, [600, 600] );

load( ground_truth_file );
ground_truth_img = false( 600, 600, 225 );
cell_pix_cnts = zeros( 225, 1 );
noncell_pix_cnts = zeros(225, 1 );
pix_cnt = 600*600*225;
cell_cnts = zeros( 225,1 );


for i = 1:length( ROI_cell )
    if( any( bullshit_imgs == i ) )
        continue
    end
    temp_roi = ROI_cell{i};
    cell_cnts(i) = length( temp_roi );
    for j = 1:length( temp_roi )
        ground_truth_img(:,:,i) = or( ground_truth_img(:,:,i), temp_roi(j).Mask );
    end
    
    cell_pix_cnts(i) = sum( sum( ground_truth_img(:,:,i ) ) );
    noncell_pix_cnts(i) = 600*600 - cell_pix_cnts(i);
    
end

temp_dir = dir( strcat( binary_dir, '*binary.mat' ) );
test_files = cell( length(temp_dir), 1 );
analysis_struct = struct( 'bounds', [-inf inf], 'detection_rate', -inf,...
    'false_positive_rate', inf, 'accuracy', -inf, 'detected_cells', inf,...
    'missed_cells', inf, 'stack_details', [] );

for i = 1:length( temp_dir )
    test_files{i} = strcat( binary_dir, temp_dir(i).name );
end

bullshit_imgs = [13, 16, 22, 32, 37, 38, 42, 43, 45, 47, 52, 58, 70, 72,...
    73, 74, 87, 88, 92, 94, 96, 101, 102, 103, 105, 107, 109, 110, 111,...
    124, 125, 126, 134, 139, 150, 152, 155, 161, 162, 165, 169, 170, 176,...
    177, 179, 185, 186, 187, 190, 200, 201, 205, 206, 209, 210, 212, 216,...
    217, 218, 223, 224, 225];



for i = 22:length( test_files )
    
    temp_filename = test_files{i};
    load( temp_filename );
    
    upper_bnd = str2double( temp_filename(end-21:end-19) );
    lower_bnd = str2double( temp_filename(end-34:end-32) );
    analysis_struct(i).bounds = [lower_bnd, upper_bnd];
    
    img_stack_binary = logical( img_stack_seg );
    clear img_stack_seg
    
    diff_img = ground_truth_img - img_stack_binary;
    
    analysis_struct(i).accuracy = 1 - sum( sum( sum( abs( diff_img ) ) ) )/pix_cnt;
    
    pix_locs = find( ground_truth_img == 1 );
    cellpix_detected = sum( img_stack_binary( pix_locs ) == 1 );
    analysis_struct(i).detection_rate = cellpix_detected/sum( cell_pix_cnts );
    analysis_struct(i).false_positive_rate = length( find( diff_img == -1 ) )/sum( noncell_pix_cnts );
    
    temp_stack_dets = struct( 'detection_rate', -inf,'false_positive_rate', inf,...
        'accuracy', -inf, 'detected_cells', inf, 'missed_cells', inf,...
        'edge_distance_map', zeros( 600,600 ) );
    detected_cells = 0;
    missed_cells = 0;
    for j = 1:size( img_stack_binary, 3 )
        
        cell_perim = bwperim( img_stack_binary(:,:,j) );
        temp_img1 = dic_img_stack(:,:,j);
        temp_img1(cell_perim == 1) = max(max(dic_img));
        
        cell_perim = bwperim( ground_truth_img(:,:,j) );
        temp_img2 = dic_img_stack(:,:,j);
        temp_img2(cell_perim == 1) = max(max(dic_img));
        
        figure(1), imshow( temp_img1 , [] );
        figure(2), imshow( temp_img2, [] );
        
        temp_binary = img_stack_binary(:,:,j);
        temp_ground_truth = ground_truth_img(:,:,j);
        temp_roi = ROI_cell{j};
        temp_detected_cells = 0;
        temp_missed_cells = 0;
        
        for k = 1:length( temp_roi )
            cell_mask = temp_roi(k).Mask;
            cell_idx = find( cell_mask == 1 );
            if( sum( temp_binary(cell_idx) ) > 0 )
                temp_detected_cells = temp_detected_cells + 1;
            else
                temp_missed_cells = temp_missed_cells + 1;
            end
            
        end
        
        fprintf( 'detected %i of %i cells in img %i\n', temp_detected_cells,...
            length( temp_roi), j );
        if( ~any( bullshit_imgs == j ) )
            detected_cells = detected_cells + temp_detected_cells;
            missed_cells = missed_cells + temp_missed_cells;
        end
        temp_stack_dets(j).detected_cells = temp_detected_cells;
        temp_stack_dets(j).missed_cells = temp_missed_cells;
        temp_stack_dets(j).accuracy = sum( sum( temp_binary == temp_ground_truth ) ) / (600*600);
        pix_locs = find( temp_ground_truth == 1 );
        temp_stack_dets(j).detection_rate = sum( temp_binary( pix_locs ) == 1 )/length(pix_locs);
        empty_locs = find( temp_ground_truth == 0 );
        temp_stack_dets(j).false_positive_rate = sum( temp_binary( empty_locs ) == 1 )/length(empty_locs);
    end
    
    analysis_struct(i).detected_cells = detected_cells;
    analysis_struct(i).missed_cells = missed_cells;
    
    
    analysis_struct(i).stack_details = temp_stack_dets;
    fprintf( 'filter %.1f-%.1f complete, acc=%f, det_rate=%f, false_rate=%f\n    %i of %i cells detected\n',...
        lower_bnd, upper_bnd, analysis_struct(i).accuracy, analysis_struct(i).detection_rate,...
        analysis_struct(i).false_positive_rate, analysis_struct(i).detected_cells, sum(cell_cnts) );
end

day_str = datestr(now, 'yymmdd');

out_file_str = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\bandpass_analsyis_';
out_file_str = strcat( out_file_str, day_str, '.mat' );

save( out_file_str, 'bullshit_imgs', 'analysis_struct', 'img_stack_binary', 'test_files' );

