close all, clear all, clc

allFiles = dir('T:\Marino\Microscopy\Strip Pattern\compiled\*.tif');
filenames = {allFiles.name};

objMMW = classMicroManagerWrapper;

for i = 1:numel(filenames)
   
    img = im2double(imread(filenames{i}));
    img_cnt = 4;
    
    imgs_prsd = parse_images(objMMW, img);
    
    imtool(img)
    
    figure, 
    for j = 1:numel(imgs_prsd)
        
        imgs_prsd{j} = scale_input(objMMW, imgs_prsd{j});
        
        subplot(2,2,j), imshow(imgs_prsd{j});
        
    end
    
    pause
    
    close all
    
    
end