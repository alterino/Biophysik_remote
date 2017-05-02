classdef classSegmentationManager
    % this class will be used to organize work inside of the segmentation
    % and classification project that will be used for microscope
    % automation
    
    properties
        
        
        
    end
    
    methods
        function this = classSegmentationManager
        end
        
        % beginning here attempting to put together functions for
        % entropy-based segmentation
        
        function labeled_img = cluster_img_entropy(this, img, gmm, wind, sizeThresh)
            
            img_ent = entropyfilt( img, ones(wind,wind) );
            se = strel('disk',9);
            ent_smooth = imclose(img_ent, se);
            
            idx = reshape(cluster(gmm, ent_smooth(:)), size(ent_smooth));
            % toc();
            
            % Order the clustering so that the indices are from min to max cluster mean
            [~,sorted_idx] = sort(gmm.mu);
            temp = zeros(num_clusts,1);
            for j = 1:num_clusts
                temp(j) = find( sorted_idx == j );
            end
            sorted_idx = temp; clear temp
            % some weird bug is happening here but I think the above fixed it
            new_idx = sorted_idx(idx); %**********************
            
            bwInterior = (new_idx > 1);
            cc = bwconncomp(bwInterior);
            
            bSmall = cellfun(@(x)(length(x) < sizeThresh), cc.PixelIdxList);
            
            new_idx(vertcat(cc.PixelIdxList{bSmall})) = 1;
            labeled_img = new_idx;
        end
        function gmm = genereate_gmm_entropy(this, img_stack, block_dims, wind, num_clusts)
            img_ent = zeros( size( img_stack ) );
            
            for i = 1:size(img_stack, 3)
                im = img_stack(:,:,i);
                img_ent(:,:,i) = entropyfilt(im, ones(wind,wind));
            end
            
            img_ent = img_stack_to_img_2D( img_ent, block_dims );
            
            se = strel('disk',9);
            ent_smooth = imclose(img_ent, se);
            
            skip_size = 30;
            ent_vector = ent_smooth(:);
            options = statset( 'MaxIter', 200 );
            gmm = fitgmdist(ent_vector(1:skip_size:end), num_clusts, 'replicates',3, 'Options', options);
        end
        
        function [summary_stats, missed_pics_idx] =...
                evaluate_seg_results( results_img_stack,...
                ground_truth_stack,...
                ROI_cell )
            % results_img should be the binary labeled resulting image from algorithm,
            % ground_truth should be the ground truth binary label image, and ROI_cell
            % should be a cell variable with one entry for each image consisting of the
            % ROIs for that image, ignore_list is a vector of images to ignore in
            % evaluating the results. missed_pics_idx returns a vector containing the
            % indices of all images where an ROI was missed
            
            summary_stats = struct([]);
            missed_pics_idx = [];
            
            dims = [ size( results_img_stack, 1 ), size( results_img_stack, 2 ) ];
            
            for j = 1:size( results_img_stack, 3 )
                
                temp_binary = results_img_stack(:,:,j);
                temp_ground_truth = ground_truth_stack(:,:,j);
                temp_roi = ROI_cell{j};
                temp_detected_cells = 0;
                temp_missed_cells = 0;
                
                cnted_flag = 0;
                for k = 1:length( temp_roi )
                    cell_mask = temp_roi(k).Mask;
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
                
                summary_stats(j).detected_cells = temp_detected_cells;
                summary_stats(j).missed_cells = temp_missed_cells;
                summary_stats(j).accuracy = sum( sum( temp_binary == temp_ground_truth ) ) / (dims(1)*dims(2) );
                pix_locs = find( temp_ground_truth == 1 );
                summary_stats(j).detection_rate = sum( temp_binary( pix_locs ) == 1 )/length(pix_locs);
                empty_locs = find( temp_ground_truth == 0 );
                summary_stats(j).false_positive_rate = sum( temp_binary( empty_locs ) == 1 )/length(empty_locs);
            end
            
            
        end
        
        function [props_struct, area_vec] = get_cc_regionprops( cc )
            %get_cc_regionprops(cc)
            %   A wrapper function for collecting properties of a connected
            %   component structure
            
            props_struct = struct( 'area_mean', 'area_std' );
            area_vec = zeros( length( cc.PixelIdxList ), 1 );
            pic_idx_cell = cc.PixelIdxList;
            
            for i = 1:length( pic_idx_cell )
                area_vec(i) =  length( pic_idx_cell{i} );
            end
            
            props_struct.area_mean = mean( double( area_vec ) );
            props_struct.area_std = std( double( area_vec ) );
        end
        
        function [img_stack, orig_idx] = img_2D_to_img_stack( img, dims )
            %img_2D_to_img_stack -
            %   dims should be the size of each individual image that will be planes
            %   in the resulting stack in rows x cols format, orig_idx gives a matrix
            %   with one 2D vector for each image in the resulting image stack. This
            %   vector corresponds to the top left point of the image in the original
            %   2D matrix in [row col] format
            
            img2D_dims = size( img );
            data_type = class( img );
            if( length( dims ) ~= 2 )
                error('dims should be a vector of length 2')
            end
            if( mod( img2D_dims(1), dims(1)) ~= 0 || mod( img2D_dims(2), dims(2)) )
                error('img dimensions and desired stack dimensions inconsistent.' )
            end
            if( ~isnumeric( img ) && ~islogical( img )  )
                error('img is limited to numeric or logical array due to programmer laziness.')
            end
            numCols = img2D_dims(1)/dims(1);
            numRows = img2D_dims(2)/dims(2);
            orig_idx = zeros( numCols*numRows, 2 );
            img_stack = zeros(dims(1), dims(2), numCols*numRows, data_type);
            tempIDX = 0;
            for i=1:numRows
                for j=1:numCols
                    tempIDX = tempIDX + 1;
                    img_stack( :,:, tempIDX ) =...
                        img( dims(1)*(i-1)+1:dims(1)*i, dims(2)*(j-1)+1:dims(2)*j );
                    orig_idx( tempIDX, : ) = [dims(1) dims(2)];
                end
            end
        end
        
        function [ img_2D ] = img_stack_to_img_2D( img_stack, dims )
            %UNTITLED Summary of this function goes here
            %   Detailed explanation goes here
            % dims should be a 2D vector in the form of [rows cols] where rows
            % represents the number of images from the stack per row and cols defined
            % similarly. rows*cols should equal the number of images in the stack
            
            numRows = dims(1);
            numCols = dims(2);
            data_type = class( img_stack );
            
            if( length( dims ) ~= 2 )
                error('dims should be a vector of length 2')
            end
            
            if( dims(1)*dims(2) ~= size( img_stack, 3) )
                error('img dimensions and desired stack dimensions inconsistent.' )
            end
            
            if( ~isnumeric( img_stack ) && ~islogical( img_stack ) )
                error('img is limited to numeric array due to programmer laziness.')
            end
            
            img_stack_dims = size( img_stack );
            num_imgs = img_stack_dims(3);
            img_stack_dims = img_stack_dims(1:2);
            
            img2D_dims = [numRows*img_stack_dims(1) numCols*img_stack_dims(2)];
            
            img_2D = zeros( img2D_dims(1), img2D_dims(2), data_type );
            
            tempIDX = 0;
            for i=1:numRows
                for j=1:numCols
                    tempIDX = tempIDX + 1;
                    img_2D( img_stack_dims(1)*(i-1)+1:img_stack_dims(1)*i,...
                        img_stack_dims(2)*(j-1)+1:img_stack_dims(2)*j ) =...
                        img_stack( :,:, tempIDX );
                end
            end
        end
        
        function sub_img = extract_subimage( img, rows, cols )
            % rows and cols should each be a vector of dimension two specifying the
            % column span and the row span of the desired subimage
            
            dims = size(img);
            
            if( max(size(rows)) ~= 2 || min(size(rows)) ~= 1 ||...
                    max(size(cols)) ~= 2 || min(size(cols)) ~= 1  ||...
                    length(size(rows)) ~= 2 || length(size(cols )) ~= 2 )
                error('rows and cols must be vectors of dimension 2')
            end
            if( min(rows) < 0 || min(cols) < 0 ||...
                    max(rows) > dims(1) || max(cols) > dims(2) )
                error('dimensions out of image bounds')
            end
            
            sub_img = img( min(rows):max(rows), min(cols):max(cols) );
            
        end
        
    end
end

