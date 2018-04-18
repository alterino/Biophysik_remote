allFilesL = dir( 'T:\Marino\Microscopy\150814\PNGs\TrF*.png' );
allFilesR = dir( 'T:\Marino\Microscopy\150814\PNGs\Lbld*.png' );

cd( 'T:\Marino\Microscopy\150814\PNGs\')

filenamesL = {allFilesL.name};
filenamesR = {allFilesR.name};

for i = 1:numel(filenamesL)
   
    imgL = im2double(rgb2gray(imread(filenamesL{i})));
    imgR = im2double(rgb2gray(imread(filenamesR{i})));
    
    img = [imgL, imgR];   
    
    exprsn = '[0-9]';

    temp = filenamesL{i};    
    inds = regexp(temp, exprsn);
    picInd = temp(inds);
    
    picStr = strcat('T:\Marino\Microscopy\150814\PNGs\comb_IMG_',...
                                                           picInd, '.png');
    
    imwrite(img, picStr);


%      figure, imshow(img)
%      figure, imshow(imgL), figure, imshow(imgR)   
%      
%      pause
%      
%      close all
    
    
end

