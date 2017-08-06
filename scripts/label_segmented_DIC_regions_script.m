top_dir = dir('D:\OS_Biophysik\Microscopy\170706\DIC*.tif');
img_dims = [1200 1200];
wind = 9;

for i = 1:length( top_dir )
    
    dic_scan = imread( strcat( top_dir(i).folder, '\', top_dir(i).name ) );
    
    [bw_img, cc, parameters, ent_smooth] = ...
                         process_and_label_DIC( dic_scan, img_dims, wind );
          
    for j = 1:length( cc )
        
        
        
        
        
    end
    

end

