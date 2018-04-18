close all, clear all, clc

allFiles = dir( 'T:\Marino\Microscopy\Raw Images for Michael\compiled\*.tif' );
filenames = {allFiles.name};

objMMW = classMicroManagerWrapper;

for i=1:numel(filenames)
    
    img = im2double(imread(filenames{i}));
    
    img_sc = img-min(min(img));
    img_sc = img_sc./max(max(img_sc));
        
    [thetaD, centroyd] = seek_pattern_orientation(objMMW, img);
    
    shft = 114;
    shftFac = 0;
    q = 1;
    shft = 114;
    
    allesKlar = false;
    
    figure, imshow(img_sc);
    
    data_coll = [];
    int_coll = [];
    
    while(~allesKlar)
    
        datapts = create_line(objMMW, img, thetaD, centroyd, shft*(shftFac));        
        allesKlar = isempty(datapts);
        
        if (~isempty(datapts))
            linez{q} = datapts;
            q = q+1;
            shftFac = shftFac + 1;
        end
        
        hold on, plot(datapts(:,1), datapts(:,2), 'b.');  
    end
    
    shftFac = -1;
    allesKlar = false;
    
    while(~allesKlar)
    
        datapts = create_line(objMMW, img, thetaD, centroyd, shft*(shftFac));       
        allesKlar = isempty(datapts);
        
        if (~isempty(datapts))
            linez{q} = datapts;
            q = q+1;
            shftFac = shftFac - 1;
        end
        
    end
    
    H = fspecial('gaussian', 50, 50/6);
    
    img_sm = medfilt2(img, [2 2]);
    img_sm = imfilter(img_sm, H, 'replicate');
     
    [thresh, intVals_cell] = global_thresh_cal(objMMW, img_sm, linez);
    [abvThresh, belThresh] = classify_pts(this, img_sm, thresh, intVals_cell, linez);
    
    
      
    pause
    
    
end