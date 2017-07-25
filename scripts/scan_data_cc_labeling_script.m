scan_dir = dir('D:\OS_Biophysik\Microscopy\170706\DIC*.tif');
file_paths = [];

for i = 1:length( scan_dir )
        file_paths = cat(1, file_paths,...
            {strcat( scan_dir(i).folder, '\', scan_dir(i).name )} );
end

cell_labels = struct( 'major_axis_length', [], 'area', [], 'label', [] );


for i = 1:length( file_paths )
    
   dic_scan = imread( file_paths );
    
    
    [stats, labels] = label_conntected_components( scanner, dic_scan, [1200, 1200] );
    
       
    
    
end