close all, clear all, clc, warning('off','all')

allFiles = dir( 'T:\Marino\Microscopy\150718\*.tif' );
filenames = {allFiles.name};

threshMat = [];
dataMat = [];

headerStrs = {'ImageNum,CentroidX,CentroidY,Area,Perimeter,Eccentricity,ConvexArea,AreaOverConvexArea,AreaOverPerimeter'};

[rowz, cols] = size(headerStrs);

% xlswrite('T:\Marino\Microscopy\150718\PNGs\data.csv', headerStrs);

cd('T:\Marino\Microscopy\150718');

for i=1:length(filenames)
    
    
    % cell array of images; this could also be implemented as a 3d array of
    % images for increased flexibility 
    imgs{i} = imread(filenames{i});

    % extract single image
    temp_img = imgs{i};
    
    % sobel gradient determined
    maskX = [-1 0 1; -2 0 2; -1 0 1];
    maskY = [-1 -2 -1; 0 0 0 ; 1 2 1];
    
    % median filter the image for noise removal
%     temp_img = medfilt2(temp_img,[3 3]);
%     
      Hgauss = fspecial('gaussian', 15, 15/6);
      Have = fspecial('average',3);
    
      temp_imgSM = imfilter(temp_img,Have, 'replicate');
%     temp_imgSM = temp_img;

    derX = conv2(double(temp_imgSM), maskX);
    derY = conv2(double(temp_imgSM), maskY);
    gradMag = sqrt(derX.^2 + derY.^2);
    gradMag = gradMag/max(max(gradMag));
    
    gradMag_sm = imfilter(gradMag,Hgauss);    
    
    % try MATLAB built-in edge detection   
    [~, threshC] = edge(temp_imgSM,'sobel');
    scld = .4;
    
    bwC = edge(temp_imgSM, 'sobel', threshC * scld);
    
    % save threshold JIC
    threshMat = [threshMat;threshC];
    
    % linear structure elements used for dilation
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    seDsk = strel('disk',5);
    
    % dilate black and white gradient image and fill holes
    bwC_D = imdilate(bwC, [se90 se0]);
    bwC_F = imfill(bwC_D, 'holes');
   
    % diamond shape used for erosion to compensate for original dilation
    seD = strel('diamond',1);
    
    % erode to compensate for dilation
    bwC_F = imerode(bwC_F,seD);
    bwC_F = imerode(bwC_F,seD);
    bwC_F = imclearborder(bwC_F, 8);
    
%    % generates figure to compare edgemapped image with original
%     figure,
%     subplot(1,2,2),imshow(edgmp_C), title('Canny');
%     subplot(1,2,1), imshow(temp)
%     threshMat = [threshMat; threshC];
    
    % uses label matrix to calculate area of each region
    cc = bwconncomp(bwC_F);
    labeled = labelmatrix(cc);


    
    pixArea = zeros(max(max(labeled)),1);
    
    for j=1:max(max(labeled))
       pixArea(j) = length(find(labeled==j));        
    end
%     
%     hist(pixArea,100);
        
    % fits Gaussian model, chi-2 or exponential may be more appropriate but
    % this worked well enough
    modl = fitdist(pixArea,'Normal');
%     thresh = modl.mu+modl.sigma/2;
    thresh = 1000;
    
    % obtains label for objects below area threshold
    tolow = find(pixArea<thresh);
    inds_2low = [];
    for j=1:length(tolow)
       find(labeled==tolow(j));
       inds_2low = [inds_2low; find(labeled==tolow(j))];
    end
    
%     % shows original image
%     figure, imshow(bwC_F)
    
    % eliminates noise objects as defined above
    bwC_F(inds_2low) = 0;

    % extract perimeter
    edge_C = bwperim(bwC_F);
    
    % overlays edge map onto image
    edgmp_C = temp_img;
    edgmp_C(edge_C) = 65535;

    % lets fit some ellipses to these guyz
    % first we need the individual perimeters for each connected components   
    cc = bwconncomp(bwC_F);
    labeled = labelmatrix(cc);
    
    %********************************************************************
    % save this for later after checking out region props
    edge_ft = cell(1,max(max(labeled)));
    ellps_ft = cell(1,max(max(labeled)));
    
    for j=1:max(max(labeled));
        edge_ft{j} = bwperim(labeled==j);
        [indsy, indsx] = find(edge_ft{j}==1);
        ellps_ft{j} = fit_ellipse(indsx, indsy);
               
    end

    %********************************************************************
    
    % here we will determine a way to observe the labels and regionprops
    % for each region, as well as save the data for convenient analysis,
    % the purpose of this is to determine modalities for the classification
    % scheme
    
    s = regionprops(cc, 'centroid', 'area', 'eccentricity',...
                'perimeter', 'convexarea');
    
    classMat = zeros(length(s))+999;
            
    centroyds = cat(1, s.Centroid);
%      edgmp_data = insertText(edgmp_C,uint16(centroyds),...
%              cc(uint16(centroyds)));
    
    
    %********************************************************************
    
        
    figure, imshow(temp_img), title('original image')
    figure, imshow(bwC), title('bwC');
    ax = figure; imshow(edgmp_C)
    hold on
    for j=1:numel(s)
        text(centroyds(j,1), centroyds(j,2), sprintf('%d', j), ...
                'HorizontalAlignment', 'center',...
                    'VerticalAlignment', 'middle', 'color', [.2 .2 .2]);
        inds = round(s(j).Centroid);  
                
        if s(j).Area/s(j).ConvexArea > 0.8
            classMat(j) = 0;
        elseif s(j).Area < 2000
            classMat(j) = 0;
        elseif (s(j).Area > 15000 || labeled(inds(2), inds(1)) == 0)
            classMat(j) = 2;
        else
            classMat(j) = 1;
        end
        
    end
    
    indsDX = centroyds(classMat == 0,1); 
    indsDY = centroyds(classMat == 0,2);
    indsAX = centroyds(classMat == 1,1); 
    indsAY = centroyds(classMat == 1,2);
    indsMX = centroyds(classMat == 2,1); 
    indsMY = centroyds(classMat == 2,2);
    
    hold on
    plot(indsDX, indsDY, 'r*', indsAX, indsAY, 'g*', indsMX, indsMY, 'b*');
    
    cdata = print(ax, '-RGBImage');
    
    [path, nme, ext] = fileparts(filenames{i});
    
    filestr = strcat('T:\Marino\Microscopy\150718\PNGs\Lbld_',nme,'.png');
    imwrite(cdata, filestr);
    
    dlmwrite('T:\Marino\Microscopy\150718\PNGs\data.csv', i, '-append');
    
    for j=1:length(s)     
    
        dataVec = [j, s(j).Centroid(1), s(j).Centroid(2), s(j).Area,s(j).Perimeter,...
                    s(j).Eccentricity, s(j).ConvexArea, s(j).Area/s(j).ConvexArea,...
                                s(j).Area/s(j).Perimeter];

        dlmwrite('T:\Marino\Microscopy\150718\PNGs\data.csv', dataVec, '-append'); 
        
        dataMat = [dataMat; dataVec(4:9)];

    end
    
    
    
    close all
    
end
    
hist_handle1 = figure; hist(dataMat(:,1),50), title('Area Histogram');
hist_handle2 = figure; hist(dataMat(:,3),50), title('Eccentricity Histogram');
hist_handle3 = figure; hist(dataMat(:,5),50), title('Area/ConvexArea Histogram');
hist_handle4 = figure; hist(dataMat(:,6),50), title('Area/Perimeter Histogram');

       
