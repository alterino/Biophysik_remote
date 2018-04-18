filepath = 'T:\Marino\Microscopy\150624\Image_';
imgNums = 1:12;

for i=1:length(imgNums)
    
    if(i<10)
        str = strcat(filepath,'0',num2str(imgNums(i)),'.tif');
    else
        str = strcat(filepath,num2str(imgNums(i)),'.tif');
    end
    imgs{i} = imread(str);
    
    % try MATLAB built-in edge detection
    
    [bwS, threshS] = edge(imgs{i},'sobel');
    [bwP, threshP] = edge(imgs{i},'prewitt');
    [bwR, threshR] = edge(imgs{i},'roberts');
    %[bwL, threshL] = edge(imgs{i},'log');
    %[BW1, thresh1] = edge(imgs{i},'sobel');
    [bwC, threshC] = edge(imgs{i},'canny');
    
    temp = imgs{i};
    
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    
    bwS_D = imdilate(bwS, [se90 se0]);
    bwS_F = imfill(bwS_D, 'holes');
    
    bwP_D = imdilate(bwP, [se90 se0]);
    bwP_F = imfill(bwP_D, 'holes');
    bwR_D = imdilate(bwR, [se90 se0]);
    bwR_F = imfill(bwR_D, 'holes');
    bwC_D = imdilate(bwC, [se90 se0]);
    bwC_F = imfill(bwC_D, 'holes');
    
    seD = strel('diamond',1);
    
    bwS_F = imerode(bwS_F,seD);
    bwS_F = imerode(bwS_F,seD);
    bwP_F = imerode(bwP_F,seD);
    bwP_F = imerode(bwP_F,seD);
    bwR_F = imerode(bwR_F,seD);
    bwR_F = imerode(bwR_F,seD);
    bwC_F = imerode(bwC_F,seD);
    bwC_F = imerode(bwC_F,seD);
    
    edge_S = bwperim(bwS_F);
    edge_P = bwperim(bwP_F);
    edge_R = bwperim(bwR_F);
    edge_C = bwperim(bwC_F);

    
    
    pause
    
    close all
       
    
    
    
end

