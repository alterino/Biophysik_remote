 close all, clearvars -except objImgReader, clc, warning('off','all')
 
% allFiles = dir( 'T:\Marino\Microscopy\150718\*.tif' );
% filenames = {allFiles.name};

% [~,objImgReader, ~] = image_stack_import('T:\Marino\Microscopy\150814\150814_163227.tif');
numImgs = objImgReader.getImageCount();

headerStrs = {'ImageNum,CentroidX,CentroidY,Area,Perimeter,Eccentricity,ConvexArea,AreaOverConvexArea,AreaOverPerimeter'};

[rowz, cols] = size(headerStrs);

for i=2445:numImgs
        
    profile on
    % cell array of images; this could also be implemented as a 3d array of
    % images for increased flexibility
    
    
    [temp_img, ~, ~] =...
        image_stack_import('T:\Marino\Microscopy\150814\150814_163227.tif',...
                        'ObjImgReader', objImgReader, 'FrameRange', i);
    
                    
%     temp_img = temp_img(25:end-24, 25:end-24);
    

%     F = fft2(double(temp_img));
%     F_shft = mat2gray(log(abs(fftshift(F))+1));
    
    M = size(temp_img,2);
    N = size(temp_img,1);
    
    tic
    deltax = 1;
    deltay = 1; % for now these, representing the sampling rate in x and y,
                % will be set to 1 pixel, rather than their metric values
   
    % grid goes from 0 to .5 and then from -.5 back to 0 in steps size 1/M,
    % provided that deltax is set to 1 pixel. Otherwise values are scaled
    % by 1/sample rate
    kx1 = mod( 1/2 + (0:(M-1))/M , 1 ) -1/2;
    kx = kx1*(2*pi/deltax);
    ky1 = mod( 1/2 + (0:(N-1))/N , 1 ) -1/2;
    ky = ky1*(2*pi/deltay);
    
    [KX, KY] = meshgrid(kx, ky);
    
    k0 = sqrt(.1^2*(deltax^-2+deltay^-2)); % <<<< filter set to filter out
                            % frequency values above this magnitude
    k1 = sqrt(.5^2*(deltax^-2+deltay^-2)); % <<<< filter set to filter out
                            % frequency values above this magnitude
                            
    th_1 = double(KX.*KX+KY.*KY < k0^2);
    th_2 = double(KX.*KX+KY.*KY > k1^2);
    th_3 = 1 - th_2 - th_1;
    
    H = fspecial('gaussian', 200, 200/6);
    T1 = imfilter(th_1, H, 'symmetric');
    T2 = imfilter(th_2, H, 'symmetric');
    T3 = imfilter(th_3, H, 'symmetric');
    
    
    img_filtd_LP = abs(ifft2(T1.*fft2(temp_img)));
    img_filtd_LP = img_filtd_LP - min(min(img_filtd_LP));
    img_filtd_LP = img_filtd_LP./max(max(img_filtd_LP));
    img_filtd_HP = abs(ifft2(T2.*(fft2(temp_img))));
    img_filtd_HP = img_filtd_HP - min(min(img_filtd_HP));
    img_filtd_HP = img_filtd_HP./max(max(img_filtd_HP));
    img_filtd_BP = abs(ifft2(T3.*(fft2(temp_img))));
    img_filtd_BP = img_filtd_BP - min(min(img_filtd_BP));
    img_filtd_BP = img_filtd_BP./max(max(img_filtd_BP));
    
    
    
    H2 = fspecial('gaussian', 3, .5);
    img_filtd_HP = imfilter(img_filtd_HP, H2);
    
    figure, imagesc(img_filtd_LP), colormap gray
    title('filtered image - LP')
    figure, imagesc(img_filtd_HP), colormap gray
    title('filtered image, HP - scaled')
    figure, imagesc(img_filtd_BP), colormap gray
    title('filtered image, BP - scaled scaled')
    figure, imagesc(temp_img), colormap gray, title('original image')
    
%     a = getimage(handl);
%     figure, imshow(a);
      
%     img_filtd_LP = img_filtd_LP-min(min(img_filtd_LP));
%     img_filtd_LP = img_filtd_LP/max(max(img_filtd_LP));
%     figure, imshow(img_filtd_LP), title('manually scaled')
    
    % lets check out the gradient of this mofo
    % this can be done with imgradient() you chump...
%     maskX = [-1 0 -1; -2 0 2; -1 0 1];
%     maskY = [-1 -2 -1; 0 0 0; 1 2 1];
%     derX = conv2(double(img_filtd_LP), maskX);
%     derY = conv2(double(img_filtd_LP), maskY);
%     gradMag = sqrt(derX.^2 + derY.^2);
%     gradMag = gradMag/max(max(gradMag));
% 
%     [~,thr1] = edge(img_filtd_LP,'sobel');
%     bwIMG1 = edge(img_filtd_LP, 'sobel', thr1*.6);
%     [~,thr2] = edge(img_filtd_HP,'sobel');
%     bwIMG2 = edge(img_filtd_HP, 'sobel', thr2*.9);
%     [~,thr3] = edge(img_filtd_BP,'sobel');
%     bwIMG3 = edge(img_filtd_BP, 'sobel', thr3*.5);
    
    [~,thr1] = edge(img_filtd_LP,'canny');
    bwIMG1 = edge(img_filtd_LP, 'canny', thr1);
    [~,thr2] = edge(img_filtd_HP,'canny');
    bwIMG2 = edge(img_filtd_HP, 'canny', thr2);
    [~,thr3] = edge(img_filtd_BP,'canny');
    bwIMG3 = edge(img_filtd_BP, 'canny', thr3);
    
%     figure, imshow(T1), figure, imshow(T2), figure, imshow(T3)
    
    % linear structure elements used for dilation
    se90_L = strel('line', 10, 90);
    se0_L = strel('line', 10, 0);
    se90_B = strel('line', 8, 90);
    se0_B = strel('line', 8, 0);
    se90_H = strel('line', 7, 90);
    se0_H = strel('line', 7, 0);
%     seDsk = strel('disk',5);
    
    % diamond shape used for erosion to compensate for original dilation
    seD_L = strel('diamond',5);
    seD_B = strel('diamond',4);
    seD_H = strel('diamond',4);
    
    bwIMG1 = bwIMG1(3:end-2, 3:end-2);
    bwIMG2 = bwIMG2(3:end-2, 3:end-2);
    bwIMG3 = bwIMG3(3:end-2, 3:end-2);
    
    temp_img = temp_img(3:end-2, 3:end-2);
    
    % dilate black and white gradient image and fill holes
    bwC_D1 = imdilate(bwIMG1, [se90_L se0_L]);
    bwC_F1 = imfill(bwC_D1, 'holes');
    bwC_D2 = imdilate(bwIMG2, [se90_H se0_H]);
    bwC_F2 = imfill(bwC_D2, 'holes');
    bwC_D3 = imdilate(bwIMG3, [se90_B se0_B]);
    bwC_F3 = imfill(bwC_D3, 'holes');
%   bwC_F = imopen(bwC_F, seDsk);
   

    
    % erode to compensate for dilation
    bwC_F1 = imerode(bwC_F1,seD_L);
    bwC_F1 = imerode(bwC_F1,seD_L);
    bwC_F2 = imerode(bwC_F2,seD_H);
    bwC_F2 = imerode(bwC_F2,seD_H);
    bwC_F3 = imerode(bwC_F3,seD_B);
    bwC_F3 = imerode(bwC_F3,seD_B);
    
%     figure, imshow(bwIMG1);
%     figure, imshow(bwC_F1);
%     figure, imshow(bwIMG2);
%     figure, imshow(bwC_F2);
%     figure, imshow(bwIMG3);
%     figure, imshow(bwC_F3);
%     figure, imshow(temp_img, []);
%     
    cc1 = bwconncomp(bwC_F1);
    cc2 = bwconncomp(bwC_F2);
    cc3 = bwconncomp(bwC_F3);
%     figure, imshow(bwC_F);

    s1 = regionprops(cc1, 'centroid', 'area', 'eccentricity',...
                'perimeter', 'convexarea');
    s2 = regionprops(cc2, 'centroid', 'area', 'eccentricity',...
                'perimeter', 'convexarea');
    s3 = regionprops(cc3, 'centroid', 'area', 'eccentricity',...
                'perimeter', 'convexarea');

    labeled1 = labelmatrix(cc1);
    labeled2 = labelmatrix(cc2);
    labeled3 = labelmatrix(cc3);
    
    arThresh = 1000;
    
    ind1 = find([s1.Area]<arThresh);
    ind2 = find([s2.Area]<arThresh);
    ind3 = find([s3.Area]<arThresh);
    
    for j = 1:numel(ind1)
        bwC_F1(labeled1==ind1(j)) = 0;
    end
    for j = 1:numel(ind2)
        bwC_F2(labeled2==ind2(j)) = 0;
    end
    for j = 1:numel(ind3)
        bwC_F3(labeled3==ind3(j)) = 0;
    end
    
    figure,subplot(1,2,1), imshow(bwIMG1), title('lowpass results');
    subplot(1,2,2), imshow(bwC_F1), title('lowpass results');
    figure,subplot(1,2,1), imshow(bwIMG2), title('highpass results');
    subplot(1,2,2), imshow(bwC_F2), title('highpass results');
    figure, subplot(1,2,1), imshow(bwIMG3), title('bandpass results');
    subplot(1,2,2),, imshow(bwC_F3),  title('bandpass results');
    figure, imshow(temp_img, []);
    
    inds2 = (bwC_F2 == 1);
    inds3 = (bwC_F3 == 1);
    bwC_FF = bwC_F1;
    bwC_FF(inds2) = 1;
    bwC_FF(inds3) = 1;
    
    % temporarily setting bwC_FF to just the bandpass filter
    bwC_FF = bwC_F3;
    
    se90_F = strel('line', 10, 90);
    se0_F = strel('line', 10, 0);
    
    seD_F = strel('diamond',5);
    
    bwC_FF = imdilate(bwC_FF, [se90_F, se0_F]);
    bwC_FF = imfill(bwC_FF, 'holes');
    bwC_FF = imerode(bwC_FF, seD_F);
    
    bwC_em = padarray(bwC_FF, [1 0], 1, 'pre');
    bwC_FF = imfill(bwC_em, 'holes');
    bwC_FF = bwC_FF(2:end,:);
    bwC_em = padarray(bwC_FF, [0 1], 1, 'pre');
    bwC_FF = imfill(bwC_em, 'holes');
    bwC_FF = bwC_FF(:, 2:end);
    bwC_em = padarray(bwC_FF, [1 0], 1, 'post');
    bwC_FF = imfill(bwC_em, 'holes');
    bwC_FF = bwC_FF(1:end-1, :);
    bwC_em = padarray(bwC_FF, [0 1], 1, 'post');
    bwC_FF = imfill(bwC_em, 'holes');
    bwC_FF = bwC_FF(:, 1:end-1);
    
    ccF = bwconncomp(bwC_FF);

    sF = regionprops(ccF, 'centroid', 'area', 'eccentricity',...
                'perimeter', 'convexarea');

    labeledF = labelmatrix(ccF);
    
    arThresh = 8000;
    
    indF = find([sF.Area]<arThresh);

    for j = 1:numel(indF)
        bwC_FF(labeledF==indF(j)) = 0;
    end
    
    figure, imshow(bwC_FF)
    
%     bwC_FF_hull = bwconvhull(bwC_FF);
%     figure, imshow(bwC_FF_hull);
%     perim1 = bwperim(bwC_FF_hull);
    perim2 = bwperim(bwC_FF);
    
   
    
    img2 = temp_img;
%     img2(perim1 == 1) = max(max(temp_img));
    img2(perim2 == 1) = max(max(temp_img));
    ax = figure, imshow(img2,[]);
    cdata = print(ax, '-RGBImage');
    filestr = strcat('T:\Marino\Microscopy\150814\PNGs\Lbld_IMG_0',num2str(i),'.png');
    imwrite(cdata, filestr);
%     
%     bwC_act_FF = activecontour(temp_img, bwC_FF_hull);
%     figure, imshow(bwC_act_FF);

%     profile viewer
    
    close all
    
end