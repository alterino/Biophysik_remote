 close all, clearvars -except objImgReader, clc, warning('off','all')

[~,objImgReader, ~] = image_stack_import('T:\Marino\Microscopy\150814\150814_163227.tif');

headerStrs = {'ImageNum,CentroidX,CentroidY,Area,Perimeter,Eccentricity,ConvexArea,AreaOverConvexArea,AreaOverPerimeter'};

[rowz, cols] = size(headerStrs);

for i=1:numImgs
    
       [img, ~, ~] =...
        image_stack_import('T:\Marino\Microscopy\150814\150814_163227.tif',...
                        'ObjImgReader', objImgReader, 'FrameRange', i);
                    
                    
    
    
end