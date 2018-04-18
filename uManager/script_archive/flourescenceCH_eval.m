close all, clear all, clc

allFiles = dir( 'T:\Marino\Microscopy\Raw Images for Michael\compiled\*.tif' );
filenames = {allFiles.name};

timeMat = zeros(numel(filenames));



for i=1:numel(filenames)
    
    % convert image to double between 0 and 1
    img = im2double(imread(filenames{i}));
    
    % scale image to full range
    img = img-min(min(img));
    img = img/max(max(img));
    
    dims = size(img);
    
    % reshaping image to be a vector
    % img_resh = reshape(img, [1 dims(1)*dims(2)]);
    
    % lets try some thresholding        
    
    % group pixels into 3 groups by 2 thresholds
    threshInt = multithresh(img,2);
    
    % separate images for viewing
    img_sg1 = img;
    img_sg1(img<max(threshInt)) = 0;
    img_sg2 = img;
    img_sg2(img < min(threshInt)) = 0;
    img_sg2(img >= max(threshInt)) = 0;
    imgbw = im2bw(img,max(threshInt));
    
    % separate image into thresholded and not thresholded  
    img_nz = img-img_sg1;
    
    % median filter to remove noise above threshold
    img_sg1F = medfilt2(img_sg1, [3 3]);
    img_sg2F = medfilt2(img_sg2, [3 3]);
    
    
    imgbw = medfilt2(imgbw, [3 3]);
    
    % linear structure elements used for dilation
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    % diamond shape used for erosion to compensate for original dilation
    seD = strel('diamond',1);
    
    % dilate, fill, and erode to give fuller objects
    imgbw_D = imdilate(imgbw, [se90 se0]);
    imgbw_F = imfill(imgbw_D, 'holes');   
    bwC_F = imerode(imgbw_F, seD);
    bwC_F = imerode(bwC_F, seD);    
            
    % regionprops obtained in order to use elliptical fit for pattern
    % analysis
    cc = bwconncomp(bwC_F);
    labeled = labelmatrix(cc);
    
    s = regionprops(cc, 'Area', 'Orientation', 'MajorAxisLength',...
            'MinorAxisLength', 'Eccentricity', 'Centroid');
    
    % used to remove shapes with area less than 1000 pixels
    flsPos = find(cell2mat({s.Area})<1000);
    
    for j=1:numel(flsPos)        
        bwC_F(labeled==flsPos(j)) = 0;
    end
    
    % replaces previous connected component matrix with filtered one
    cc = bwconncomp(bwC_F);
    labeled = labelmatrix(cc);

    s = regionprops(cc, 'Area', 'Orientation', 'MajorAxisLength',...
        'MinorAxisLength', 'Eccentricity', 'Centroid');
        
    % obtains maximum major axis length from the ellipses that were fit in
    % order to, ideally, assess the orientation of the longest shape
    % determined by thresholding
    k = find(cell2mat({s.MajorAxisLength})==max(cell2mat({s.MajorAxisLength})));
    
    figure(1), imshow(bwC_F)
    
    % used for plotting the ellipse determined by the ellipse detected in
    % the image with the largest major axis***************************
    phi = linspace(0, 2*pi, 50);
    cosphi = cos(phi);
    sinphi = sin(phi);

    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength/2;
    b = s(k).MinorAxisLength/2;
    
    thetaD = s(k).Orientation;

    theta = pi*s(k).Orientation/180;
    R = [ cos(theta)    sin(theta)
          -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;

    hold on
    plot(x, y, 'r', 'LineWidth', 2) %***********************************

    figure(2), imshow(img), title('Original Image')
   
    % this completes orientation determination ************************
    
    % **** now for the pattern correlation algorithm *******************
    
    % represents angle between pattern and vertical axis 
    thetaD_p = -(90-thetaD);
    pattern_temp = floures_pattern_gen(45, 70, size(img), 1);
    pattern_rotd = imrotate(pattern_temp, thetaD_p, 'crop');
    
    rotImg = imrotate(img, 90-thetaD);
   
    figure(3), imshow(pattern_rotd);    
    
    % this was a try to do without convolution, which takes too much time,
    % but the pattern matrix must be the same size. A more efficient
    % algorithm should be explored once the conv approach is demonstrated
%     img_Four = fft2(img);
%     patt_Four = fft2(pattern_rotd);
%     
%     prod_Four = img_Four.*patt_Four;
%     
%     corr_res = ifft2(prod_Four);
%     figure, imshow(corr_res);

    % computes convolution of pattern with image to look for local maxima
    % and minima to locate clean stripe patterns
    tic
    img_corr = conv2(img, pattern_rotd, 'same');
    toc
    figure(4), mesh(img_corr);
    s(k).Orientation;
    
%     thetaP = thetaD+90;
%     slpe = atan(thetaP);
%     slpe = round(slpe);
    
    % extracts values from center line, either horizontal center or
    % vertical depending on orientation of the stripe pattern
    if(abs(thetaD)>45)
        centerY = ceil(size(img_corr,1)/2);
        centerLin = img_corr(centerY,:);
        xVec = 1:size(img_corr,2);
    else
        centerY = ceil(size(img_corr,2)/2);
        centerLin = img_corr(:,centerY)';
        xVec = 1:size(img_corr,1);
    end

    
    dy_cent = diff(centerLin)./diff(xVec);
    zerCross = diff(sign(dy_cent), 1, 2);

    indX_up = find(zerCross>0);
    indX_down = find(zerCross<0);
    
    % plots local minima and maxima
    if(abs(thetaD)>45)  
        hold on, plot(indX_up, repmat(centerY,1,length(indX_up)), 'b*',...
                     indX_down, repmat(centerY,1,length(indX_down)), 'g*');
    else
        hold on, plot(repmat(centerY,1,length(indX_up)), indX_up, 'b*',...
                      repmat(centerY,1,length(indX_down)),indX_down, 'g*');
    end
    
%      % plots center line intensities and first derivative
%     figure(5),
%     subplot(1,2,1)
%     plot(1:length(dy_cent), dy_cent);
%     grid on, legend('derivative')
%     subplot(1,2,2)
%     plot(1:length(centerLin), centerLin)
%     grid on, legend('center line')
    
    % converts phiD to be consistent with requirements for the
    % calculations that follow
    if(sign(thetaD)>0)
        phiD = thetaD*pi/180;
    else
        phiD = (90+thetaD)*pi/180;
    end
    
    % calculates pixel distances between local maxima and minima in order
    % to use these indicators to evaluate the clearness of the pattern
    distsMaxes = diff(indX_down)*sin(phiD);
    distsMins = diff(indX_up)*sin(phiD);
    
    aveDistMax = mean(distsMaxes);
    aveDistMin = mean(distsMins);
    
    outStr1 = sprintf('Average distance between peaks is %d.\nAverage distance between troughs is %d.\n',...
                                        aveDistMax, aveDistMin);
    
    aveMax = mean(centerLin(indX_down));
    aveMin = mean(centerLin(indX_up));
    outStr2 = sprintf('Average Maximum value is %d.\nAverage Minimum value is %d',...
                                aveMax, aveMin);
                                    
    disp(outStr1), disp(outStr2)
    
    % alright let's figure out how to determine a line along the
    % maximum intensity value of the stripe
    
    slop = -tand(thetaD);
    
    b = s(k).Centroid(2)-slop.*s(k).Centroid(1);
    
    x=1:.002:size(img,2);
    y = slop*x+b;
    
    rnded = [round(x); round(y)]';
    x = [];
    y = [];
    datapts = unique(rnded, 'rows');
    
    % eliminate values from the line not in the image **************
    inds1 = datapts(:,1);
    inds2 = datapts(:,2);
    inds2(inds2<1) = 0;
    
    inds1((inds1>size(img,2)),:) = 0;
    inds2((inds2>size(img,1)),:) = 0;
    
    rowNums = [find(inds1==0), find(inds2==0)];
    rowNums = sort(unique(rowNums));
    
    datapts(rowNums,:) = []; 
    %**************************************************************
    
    figure(2), hold on, plot(datapts(:,1),datapts(:,2), 'b.');   
    intVals1 = zeros(size(datapts,1),1);
    intVals2 = zeros(size(datapts,1),1);

    
    
    % break this into a function to be repeated for each line in the image,
    % also needs to be adjusted for stripes that are not approximately
    % vertical
    
    % create lines for stripes appropriate distances from the center line
    
    theta_shft = 90-thetaD_p;
    centDist = 114; % distance between center of stripes based on template
    
    lineCnt = 1; 
    
    shftX = sind(theta_shft)*centDist;
    shftY = cosd(theta_shft)*centDist;
    
    if(sign(thetaD_p)==-1)
        shftY = -shftY;
    end
    
    if(sign(shftX) == sign(shftY))
        shftX = abs(shftX); shftY = abs(shftY);
    end
    
    pts_cell = {datapts};
    condisch_var = datapts;
    temp = datapts;
    
    while(~isempty(temp))
        ptsX = datapts(:,1) - shftX*lineCnt;
        ptsY = datapts(:,2) - shftY*lineCnt;
        condisch_var = [ptsX, ptsY];
        
        rowNums = sort(unique([find(ptsX<1); find(ptsY<1)]));
        temp = condisch_var;
        chk_cell{lineCnt+1} = temp;
        temp(rowNums,:) = [];
        
        if ~isempty(temp)
            lineCnt = lineCnt + 1
            pts_cell{lineCnt} = temp;
        end
            
    end
    
    newCnt = 1;
    temp = datapts;
    
    while(~isempty(temp))
        ptsX = datapts(:,1) + shftX*newCnt;
        ptsY = datapts(:,2) + shftY*newCnt;
        
        condisch_var = [ptsX, ptsY];
        
        rowNums = sort(unique([find(ptsX>dims(2)); find(ptsY>dims(1))]));
        temp = condisch_var;
        chk_cell{lineCnt+1} = temp;
         temp(rowNums,:) = [];
        
        if ~isempty(temp)
            lineCnt = lineCnt + 1
            pts_cell{lineCnt} = temp;
            newCnt = newCnt+1;
        end
    end
    
    for q = 1:length(pts_cell)
       
        currpts = pts_cell{q};
        figHandle = figure(2);
        figure(2), hold on, plot(currpts(:,1),currpts(:,2), 'g.'); 
        
    end
    
    saveas(figHandle, 'figure.tif', 'tif')

    
    %*********************************************************************
    
    % lets see how the image looks smoothed out
    
    H = fspecial('gaussian', 50, 50/6);
    
    img_sm = medfilt2(img, [2 2]);
    img_sm = imfilter(img_sm, H, 'replicate');
    
    for q=1:size(datapts,1)
       intVals1(q) = img(datapts(q,2), datapts(q,1));
       intVals2(q) = img_sm(datapts(q,2), datapts(q,1));     
    end
    
    figure, imshow(img_sm), title('smoothed image')
    figure, plot(1:length(intVals1),intVals1, 'b.',...
                    1:length(intVals2), intVals2, 'g.');
    figure, subplot(1,2,1), hist(intVals1), subplot(1,2,2), hist(intVals2)
    
    
    pause
    
    close all
    
    
end