clear
% lab path
% parent_dirstr = 'T:\Marino\Microscopy\Strip Pattern\from Sara\';
% img_dirs = dir( 'T:\Marino\Microscopy\Strip Pattern\from Sara\2013*' );
% home path
parent_dirstr = 'D:\OS_Biophysik\Microscopy\Strip Pattern\from Sara\';
img_dirs = dir( 'D:\OS_Biophysik\Microscopy\Strip Pattern\from Sara\2013*' );

img_dirstr = cell(length(img_dirs),1);
img_dir_cell = cell(length(img_dirs),1);
% % could use to separate images by5 frequency of stimulation
% freq_opts = {'405', '488', '561', 'dic'};
% img_paths_cell = cell(length(freq_opts), 1);


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
        temp_dir(j).freq = sscanf(temp_name(idx(1) + length(key)+2:end), '%g', 1);
        temp_dir(j).img = imread( strcat(temp_dir(j).folder, '\',...
            temp_dir(j).name) );
    end
    
    cell_idx_list = sort( unique( [temp_dir(:).cell_idx] ) );
    freq_opts = unique( )
    
    
    temp_struct = struct('directory', [], 'cell_idx', [], 'imDIC', [],...
    'im405', [], 'im488', [], 'im561', []);
    temp_struct.directory = temp_dir(1).folder;
    for j = 1:length(cell_idx_list)
        temp_idx = find( [temp_dir(:).cell_idx] == cell_idx_list(j) );
        temp_struct.cell_idx = cell_idx_list(j);
        for k = 1:length(freq_opts)
            temp_cands = strfind( [temp_dir(:).freq], freq_opts{k} );
            temp_cands = (temp_cands-1)/3+1;
            temp_cands = intersect( temp_cands, temp_idx );
            switch freq_opts{k}
                case '405'
                    temp_struct.im405 = temp_dir(temp_cands).img;
                case '488'
                    temp_struct.im488 = temp_dir(temp_cands).img;
                case '561'
                    temp_struct.im561 = temp_dir(temp_cands).img;
                case 'dic'
                    temp_struct.imDIC = temp_dir(temp_cands).img;
                otherwise
                    error('unknown frequency parameter')
            end
        end
    end
    img_dir_cell{i} = temp_dir;
    img_structs(i) = temp_struct;
end
clear temp* i j k img_dirstr key idx img_dirs






