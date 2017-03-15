function [summary_stats, missed_pics_idx] = evaluate_seg_results( results_img_stack, ground_truth_stack, ROI_cell )
% results_img should be the binary labeled resulting image from algorithm,
% ground_truth should be the ground truth binary label image, and ROI_cell
% should be a cell variable with one entry for each image consisting of the
% ROIs for that image, ignore_list is a vector of images to ignore in
% evaluating the results. missed_pics_idx returns a vector containing the
% indices of all images where an ROI was missed

summary_stats = struct([]);
missed_pics_idx = [];

for j = 1:size( results_img_stack, 3 )
    
%     if( j == 140 )
%         fprintf('hit 140\n')
%     end
    
    temp_binary = results_img_stack(:,:,j);
    temp_ground_truth = ground_truth_stack(:,:,j);
    temp_roi = ROI_cell{j};
    temp_detected_cells = 0;
    temp_missed_cells = 0;
    
    cnted_flag = 0;
    for k = 1:length( temp_roi )
        cell_mask = temp_roi(k).Mask;
        %         cell_idx = find( cell_mask == 1 );
        if( sum( temp_binary( cell_mask == 1) ) > 0 )
            temp_detected_cells = temp_detected_cells + 1;
        else
            temp_missed_cells = temp_missed_cells + 1;
            if( cnted_flag == 0 )
                missed_pics_idx = [missed_pics_idx; j];
                cnted_flag = 1;
            end
        end
    end
    
%     fprintf( 'detected %i of %i cells in img %i\n', temp_detected_cells,...
%         length( temp_roi), j );
    %     if( ~any( ignore_list == j ) )
    %         detected_cells = detected_cells + temp_detected_cells;
    %         missed_cells = missed_cells + temp_missed_cells;
    %     end
    summary_stats(j).detected_cells = temp_detected_cells;
    summary_stats(j).missed_cells = temp_missed_cells;
    summary_stats(j).accuracy = sum( sum( temp_binary == temp_ground_truth ) ) / (600*600);
    pix_locs = find( temp_ground_truth == 1 );
    summary_stats(j).detection_rate = sum( temp_binary( pix_locs ) == 1 )/length(pix_locs);
    empty_locs = find( temp_ground_truth == 0 );
    summary_stats(j).false_positive_rate = sum( temp_binary( empty_locs ) == 1 )/length(empty_locs);
end


end

