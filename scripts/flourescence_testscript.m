clear

%% gathering and organizing data here

[~, result] = dos('getmac');

% home path
if(strcmp(result(160:176), '64-00-6A-43-EF-0A'))
    % lab path
    parent_dirstr = 'T:\Marino\Microscopy\Strip Pattern\from Sara\';
    img_dirs = dir( 'T:\Marino\Microscopy\Strip Pattern\from Sara\2013*' );
else
    parent_dirstr = 'D:\OS_Biophysik\Microscopy\Strip Pattern\from Sara\';
    img_dirs = dir( 'D:\OS_Biophysik\Microscopy\Strip Pattern\from Sara\2013*' );
end

clear result

img_dirstr = cell(length(img_dirs),1);
img_dir_cell = cell(length(img_dirs),1);
img_structs = cell(length(img_dirs),1);
img_stack = [];
freqs_vec = [];
freqs_cell = [];
temp_vec = [];

for i = 1:length(img_dirs)
    img_dirstr{i} = strcat( parent_dirstr, img_dirs(i).name);
    img_dir_cell{i} = dir( strcat(img_dirstr{i}, '\*.tif') );
    % get cell idx for separating data for eval
    temp_dir = img_dir_cell{i};
    for j = 1:length( temp_dir )
        temp_name = temp_dir(j).name;
        key = 'cell';
        idx = strfind(temp_name, key);
        temp_dir(j).cell_idx = sscanf(temp_name(idx(1) + length(key):end), '%g', 1);
        temp_dir(j).freq = num2str( sscanf(temp_name(idx(1) + length(key)+2:end), '%g', 1) );
        if( isempty(temp_dir(j).freq) )
            temp_dir(j).freq = 'dic';
        end
        temp_dir(j).img = imread( strcat(temp_dir(j).folder, '\',...
            temp_dir(j).name) );
    end
    cell_idx_list = sort( unique( [temp_dir(:).cell_idx] ) );
    %     freq_opts = unique( [temp_dir(:).freq] );
    freq_opts = cell(length(temp_dir), 1);
    
    for j = 1:length( temp_dir )
        freq_opts{j} = temp_dir(j).freq;
    end
    freq_opts = sort( unique( freq_opts ) );
    temp_struct = struct('directory', [], 'cell_idx', []);
    for j = 1:length( freq_opts )
        freq_str = strcat( 'im', freq_opts{j} );
        temp_struct.(freq_str) = [];
    end
    temp_struct.directory = temp_dir(1).folder;
    for j = 1:length(cell_idx_list)
        temp_idx = find( [temp_dir(:).cell_idx] == cell_idx_list(j) );
        temp_struct.cell_idx = cell_idx_list(j);
        
        for k = 1:length( temp_idx )
            
            % finds image from the 4x4 grid assuming if more than one
            % region has an image they are duplicates - should be
            % double-checked
            temp_img = temp_dir(temp_idx(k)).img;
            
            new_dims = size( temp_img )/2;
            temp_img = img_2D_to_img_stack( temp_img, new_dims );
            temp_max = 0;
            for ii = 1:size( temp_img, 3 )
                if( max( max( temp_img(:,:,ii) ) ) > temp_max )
                    max_idx = ii;
                    temp_max = max( max( temp_img(:,:,ii) ) );
                end
            end
            temp_img = temp_img(:,:,max_idx);
            % fields allocated dynamically to be generalized for whatever
            % frequency the current image is composed of
            
            temp_field = strcat( 'im', temp_dir(temp_idx(k)).freq );
            temp_struct.(temp_field) = temp_img;
            %             figure(1), imshow( temp_img );
            %             title(strcat(sprintf( 'cell: %i ', cell_idx_list(j)), temp_field));
            if(isempty(img_stack))
                img_stack = temp_img;
            else
                img_stack = cat( 3, img_stack, temp_img );
            end
            freqs_vec = [freqs_vec; {temp_dir(temp_idx(k)).freq}];
            temp_vec = [temp_vec; {temp_dir(temp_idx(k)).freq}];
            if( strcmp( temp_dir(temp_idx(k)).freq, 'dic') )
                freqs_cell = [freqs_cell; {freqs_vec}];
                temp_vec = [];
            end
        end
    end
    img_dir_cell{i} = temp_dir;
    img_structs{i} = temp_struct;
end
clear temp* i j k img_dirstr key idx img_dirs max_idx freq_str ...
    cell_idx_list new_dims ii freq_opts img_dir_cell

%% data processing here
bw_stack = zeros( size(img_stack) );
bw_stripe_stack = zeros( size(img_stack) );
bwconv_stack = zeros( size(img_stack) );

img_dims = [size(img_stack, 1), size(img_stack,2)];
x0 = [1,0,50,0,50,0];
lb = [0,-img_dims/2,0,-img_dims/2,0,-pi/4];
ub = [realmax('double'),img_dims(1)/2,(img_dims(1)/2)^2,img_dims(1)/2,(img_dims(1)/2)^2];
cell_idx = 1;
freq_idx = 0;
img_cell_stacks = cell(length(freqs_cell), 1);
load('gmm.mat');
last_dic = 0;
stripe_width = 25;
flour_idxs = [];
dic_bool =  0;

for i = 1:size( img_stack, 2 )
    
    curr_freq = freqs_vec{i};
    
    switch curr_freq
        case 'dic'
            [clustered_img, bw_img] = ...
                cluster_img_entropy( img_stack(:,:,i), [], gmm, 9, 1000);
%             bw_stack(:,:,i) = bw_img;
            bw_stack(:,:,i) = (clustered_img > 2);
%             bw_stack(:,:,i) = imfill( (clustered_img > 2), 'holes' );
            last_dic_idx = i;
            dic_bool = 1;
        otherwise
            flour_idxs = [flour_idxs; i];
            [bw_stack(:,:,i), bwconv_stack(:,:,i)] =...
                threshold_flour_img( im2double(img_stack(:,:,i)), 250 );
            %             figure(1)
            %             subplot(1,2,1), imshow( img_stack(:,:,i), [] );
            %             subplot(1,2,2), imshow( bw_stack(:,:,i));
            
            [x,resnorm,residual,exitflag] =...
                fit_gaussian_flour(img_stack(:,:,i), bw_stack(:,:,i));
            
            [thetaD, pattern, img_corr] = ...
                est_pattern_orientation(img_stack(:,:,i), bw_stack(:,:,i));
            %             figure(4), mesh(img_corr);
            stripe_centers = find_stripe_locations( thetaD, img_corr, 45 );
            bw_stripe_stack(:,:,i) = ...
                generate_stripe_bw( stripe_centers, thetaD, img_dims, 25 );
    end
    
    
    if( dic_bool )
        for j = 1:length(flours_idxs)
            bw_stack(:,:,flour_idxs(i)) = ...
                and( bw_stack(:,:,flour_idxs(i)), bw_stack(:,:,last_dic_idx) );
            
            temp_img = image_stack(:,:,last_dic_idx);
            cell_perim = bwperim( bw_stack(:,:,last_dic_idx) );
            flour_perim = bwperim( bw_stack(:,:,flour_idxs(i)) );
            temp_img(cell_perim==1) = max(max(temp_img));
            temp_img(flour_perim==1) = max(max(temp_img));
        end
    end
    
    
end





