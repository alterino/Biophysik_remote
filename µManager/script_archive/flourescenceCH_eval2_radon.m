close all, clear all, clc

allFiles = dir( 'T:\Marino\Microscopy\Raw Images for Michael\compiled\*.tif' );
filenames = {allFiles.name};

for i=1:numel(filenames)
   
    img = im2double(imread(filenames{i}));
    img = img-min(min(img));
    img = img/max(max(img));
%     dims = size(img);
    
%     img_resh = reshape(img, [1 dims(1)*dims(2)]);
%     
%     H = fspecial('gaussian', 30, 30/6);
%     img_sm = medfilt2(img, [3 3]);
%     img_sm = imfilter(img_sm, H, 'replicate');
%     
%     contr_en = [0 -1 0; -1 5 -1; 0 -1 0]; 
%     img_sm_en = imfilter(img_sm, contr_en);
%     
%     img_hp = img-img_sm;
%     
%      BW = edge(img_sm);
%      
%     figure, imshow(img_sm);
%     figure, imshow(img_sm_en);
    
    % lets try some radon shit
    
    
    
    iptsetpref('ImshowAxesVisible', 'on')
    theta = 0:5:180;
    
    tic
    [R, xp] = radon(img, theta);
    sprintf('time = %d', toc)
    figure('units','normalized','outerposition',[0 0 1 1])
    imshow(R, [], 'Xdata', theta, 'Ydata', xp,...
                'InitialMagnification', 'fit'), axis normal
    
    xlabel('\theta (degrees)'), ylabel('x'''), colormap(hot)
     iptsetpref('ImshowAxesVisible', 'off')
     
    
    figure('units', 'normalized', 'outerposition', [0 0 1 1])
    imshow(img)
    
    
    pause
    
    close all
    
    
end