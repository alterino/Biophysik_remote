clear

%% gathering and organizing data here

% lab path
% parent_dirstr = 'T:\Marino\Microscopy\Strip Pattern\from Sara\';
% img_dirs = dir( 'T:\Marino\Microscopy\Strip Pattern\from Sara\2013*' );
% home path
parent_dirstr = 'D:\OS_Biophysik\Microscopy\Strip Pattern\from Sara\';
img_dirs = dir( 'D:\OS_Biophysik\Microscopy\Strip Pattern\from Sara\2013*' );

img_dirstr = cell(length(img_dirs),1);
img_dir_cell = cell(length(img_dirs),1);
img_structs = cell(length(img_dirs),1);
img_stack = [];
freq_vec = [];

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
            title(strcat(sprintf( 'cell: %i ', cell_idx_list(j)), temp_field));
            if(isempty(img_stack))
                img_stack = temp_img;
            else
                img_stack = cat( 3, img_stack, temp_img );
            end
            freq_vec = [freq_vec; temp_dir(temp_idx(k)).freq];
        end
    end
    img_dir_cell{i} = temp_dir;
    img_structs{i} = temp_struct;
end
clear temp* i j k img_dirstr key idx img_dirs max_idx freq_str ...
    cell_idx_list new_dims ii freq_opts img_dir_cell

%% data processing here
bw_stack = zeros( size(img_stack) );
bwconv_stack = zeros( size(img_stack) );

dim = size(img_stack, 1);
x0 = [1,0,50,0,50,0];
lb = [0,-dim/2,0,-dim/2,0,-pi/4];
ub = [realmax('double'),dim/2,(dim/2)^2,dim/2,(dim/2)^2];

for i = 2:size( img_stack, 2 )
    
    [bw_stack(:,:,i), bwconv_stack(:,:,i)] =...
        threshold_flour_img( im2double(img_stack(:,:,i)), 250 );
    
    figure(1)
    subplot(1,2,1), imshow( img_stack(:,:,i), [] );
    subplot(1,2,2), imshow( bw_stack(:,:,i));
    
%     temp_bw = bw_stack(:,:,i); temp_img = img_stack(:,:,i);
%     
%     [X,Y] = meshgrid(-dim/2+.5:dim/2-.5);
%     
%     X = X(:); Y = Y(:); temp_bw = temp_bw(:); Z = im2double(temp_img(:));
%     
%     X(temp_bw==0) = [];
%     Y(temp_bw==0) = [];
%     Z(temp_bw==0) = [];
%     xdata(:,1) = X;
%     xdata(:,2) = Y;
    
    % can be used to correct image
%     [x,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunction,x0,xdata,Z,lb,ub);
    [x,resnorm,residual,exitflag] =...
                     fit_gaussian_flour(img_stack(:,:,i), bw_stack(:,:,i));
    
    cc = bwconncomp(bwconv_stack(:,:,i));
    
    s = regionprops(cc, 'Area', 'Orientation', 'MajorAxisLength',...
            'MinorAxisLength', 'Eccentricity', 'Centroid');
    k = find(cell2mat({s.MajorAxisLength})==max(cell2mat({s.MajorAxisLength})));
    
    phi = linspace(0, 2*pi, 50);
    cosphi = cos(phi);
    sinphi = sin(phi);
    
    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength/2;
    b = s(k).MinorAxisLength/2;
    
    thetaD = s(k).Orientation;
    
    pattern_temp = floures_pattern_gen(25, 30, size(img_stack(:,:,i)), 1);
    pattern_rotd = imrotate(pattern_temp, -(90-thetaD));
   
    figure(2), imshow(pattern_rotd);
    
    img_corr = conv2(img_stack(:,:,i), pattern_rotd, 'same');
    
    figure(4), mesh(img_corr);
   
    clear X Y xdata a b cc xbar ybar phi cosphi sinphi thetaD
end
