close all, clear all, clc, warning('off','all')

allFiles = dir( 'T:\Marino\Microscopy\150718\*.tif' );
filenames = {allFiles.name};

threshMat = [];

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
      Have = fspecial('average',5);
    
      temp_imgSM = imfilter(temp_img,Have, 'replicate');
      
      mexHat = [0 -1 0; -1 5 -1; 0 -1 0];
%     temp_imgSM = temp_img;

    temp_img_hat = imfilter(temp_img, mexHat);
    
    figure, imshow(temp_img_hat);

    

    derX = conv2(double(temp_imgSM), maskX);
    derY = conv2(double(temp_imgSM), maskY);
    gradMag = sqrt(derX.^2 + derY.^2);
    gradMag = gradMag/max(max(gradMag));
    
    gradMag_sm = imfilter(gradMag,Hgauss);    
    
    % try MATLAB built-in edge detection   
    [~, threshC] = edge(temp_imgSM,'sobel');
    scld = .4;
    
    bwC = edge(temp_imgSM, 'sobel', threshC * scld);
    
    
    
%     threshMat = [threshMat;threshC];
    
    
    % perform correlation - this was originally intended to be used in
    % order to determine a value for area threshold for noise extraction,
    % however, another approach was preferred
%     bwC_corr = autocorr2d(bwC);
    
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
      
    % shows BW image after noise removal with original image
%     figure, imshow(bwC_F), title('bwC\_F');
%     figure, imshow(edgmp_C), title('edgemap');
% %     viscircles(centers, radii, 'EdgeColor', 'b');
%     figure, imshow(bwC), title('bwC');
%     figure, imshow(gradMag),title('gradient magnitude')
%     figure, imshow(gradMag_sm); title('smoother gradient magnitude');
%     figure, imshow(temp_imgSM), title('smoothed image')
    figure, imshow(temp_img);, title('original image')
%     imtool(gradMag/max(max(gradMag)))

%     seD = strel('disk', 5);
%     bwC_op = imopen(bwC_F,seD);
   
%     figure, imshow(bwC_op); 

    % lets fit some ellipses to these guyz
    % first we need the individual perimeters for each connected components   
    cc = bwconncomp(bwC_F);
    labeled = labelmatrix(cc);
    
    edge_ft = cell(1,max(max(labeled)));
    ellps_ft = cell(1,max(max(labeled)));
    
    for j=1:max(max(labeled));
        edge_ft{j} = bwperim(labeled==j);
        [indsy, indsx] = find(edge_ft{j}==1);
        ellps_ft{j} = fit_ellipse(indsx, indsy);
               
    end


    
    


    pause
    
    close all
    
    end
       
