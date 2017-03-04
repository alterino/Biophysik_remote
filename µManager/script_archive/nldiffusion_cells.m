close all, clear all, clc

filepath = 'T:\Marino\Microscopy\150624\Image_';
imgNums = 1:12;


threshMat = [];
minSTDmat = zeros(1,length(imgNums));

% used to observe timing of sigma calculation
tic

for i=6:12
% for i=1:1
    
    % creates names for files; this would be better implemented by
    % extracting filenames from folder of interest
    if(i<10)
        str = strcat(filepath,'0',num2str(imgNums(i)),'.tif');
    else
        str = strcat(filepath,num2str(imgNums(i)),'.tif');
    end
    
    % cell array of images; this could also be implemented as a 3d array of
    % images for increased flexibility
    imgs{i} = imread(str);
    temp_img = imgs{i}; % just to avoid typing goddamn curly brackets on this keyboard
    
    % NLDIF  Nonlinear Diffusion
%
%    y = NLDIF( u, lambda, sigma, m, stepsize, steps, verbose, drawstep ) returns the 
%    image y as the result of the application of the Non Linear diffusion
%    to the image u.
    
    diffFiltX = [1 -1];
    diffFiltY = [1; -1];
    
    diffsX = abs(imfilter(double(temp_img), diffFiltX));
    diffsY = abs(imfilter(double(temp_img), diffFiltY));
    
    xVec = reshape(diffsX,1,size(diffsX,1)*size(diffsX,2));
    yVec = reshape(diffsY,1,size(diffsY,1)*size(diffsY,2));
          
    [countsX, centersX] = hist(xVec,200);
    [countsY, centersY] = hist(yVec,200);
    
    pkXind = find(countsX == max(countsX));
    pkYind = find(countsY == max(countsY));
      
    % indices for modeling the peak to threshold values
    inFitXinds1 = pkXind+1:pkXind+5;
    inFitYinds1 = pkYind+1:pkYind+5;
    
    % indices for modeling the minimal values
    inFitXinds2 = length(centersX)-4:length(centersX);
    inFitYinds2 = length(centersY)-4:length(centersY);
    
    % perform linear regression based on 5 bins next to peak
    inFitX1 = polyfit(centersX(inFitXinds1),countsX(inFitXinds1),1);
    inFitY1 = polyfit(centersY(inFitYinds1),countsX(inFitYinds1),1);
    
    % perform linear regression based on 5 last bins
    inFitX2 = polyfit(centersX(inFitXinds2),countsX(inFitXinds2),1);
    inFitY2 = polyfit(centersY(inFitYinds2),countsX(inFitYinds2),1);  
    
    % create linespace with sufficient resolution to calculate a suitable
    % intersection
    xlinSpX = linspace(min(centersX), max(centersX), 10000);
    xlinSpY = linspace(min(centersY), max(centersY), 10000);
    
    % generate samples of the model to determine intersection
    modlX1 = xlinSpX * inFitX1(1) + inFitX1(2);
    modlY1 = xlinSpY * inFitY1(1) + inFitY1(2);   
    modlX2 = xlinSpX * inFitX2(1) + inFitX2(2);
    modlY2 = xlinSpY * inFitY2(1) + inFitY2(2); 
    
    % calculate distance between corresponding points in each model
    distX = abs(modlX1-modlX2);
    distY = abs(modlY1-modlY2);
      
    intX_th = xlinSpX(distX == min(distX));
    intY_th = xlinSpY(distY == min(distY));
    
    % calculate closest point in bin values to theoretical intersection
    temp = abs(intX_th - centersX);
    intX_ak = centersX(temp == min(temp));
    temp = abs(intY_th - centersY);
    intY_ak = centersY(temp == min(temp));
    
    
%     mseX = sum( (countsX - modlX).^2 ) / length(modlX);
%     mseY = sum( (countsY - modlY).^2 ) / length(modlY);
    
    %%%%%%%%%%%%%%%% for now this does nothing really. It will be the
    %%%%%%%%%%%%%%%% update function but currently it only is a general
    %%%%%%%%%%%%%%%% framework with no update rule. The performance of the
    %%%%%%%%%%%%%%%% initial threshold will be observed and the update
    %%%%%%%%%%%%%%%% function developed accordingly
    for z=1:1
       
        % this will be the threshold update loop that is currently a for
        % loop for testing but will eventually be a while loop based on an
        % error threshold
        
        intXind = find(centersX == intX_ak);
        intYind = find(centersY == intY_ak);
        
        % perform linear regression based for x <= threshold
        [upFitX1, errStrX1] = polyfit(centersX(1:intXind),countsX(1:intXind),1);
        [upFitY1, errStrY1] = polyfit(centersY(1:intYind),countsX(1:intYind),1);
        
        % perform linear regression based for x >= threshold
        [upFitX2, errStrX2] = polyfit(centersX(intXind:end),countsX(intXind:end),1);
        [upFitY2, errStrY2] = polyfit(centersY(intYind:end),countsX(intYind:end),1);
        
        modlupdX1 = centersX * upFitX1(1) + upFitX1(2);
        modlupdX2 = centersX * upFitX2(1) + upFitX2(2);
        
        modlupdY1 = centersY * upFitY1(1) + upFitY1(2);
        modlupdY2 = centersY * upFitY2(1) + upFitY2(2);
        
        errX1 = abs( modlupdX1(1:intXind) - countsX(1:intXind) );
        errX2 = abs( modlupdX2(intXind:end) - countsX(intXind:end) );
        
        errY1 = abs( modlupdY1(1:intYind) - countsY(1:intYind) );
        errY2 = abs( modlupdY2(intYind:end) - countsY(intYind:end) );
        
%         figure, hist(errX1,5), title('x1 error'), grid on
%         figure, hist(errX2,100), title('x2 error'), grid on
%         figure, hist(errY1,5), title('y1 error'), grid on
%         figure, hist(errY2,100), title('y2 error'), grid on
        
        figure
        plot(centersX, countsX, 'bo', centersX(1:intXind), modlupdX1(1:intXind), 'b-',...
            centersX(intXind:end), modlupdX2(intXind:end), 'g-');
        title( 'xdata' ), grid on
        
        figure
        plot(centersY, countsY, 'bo', centersY(1:intYind), modlupdY1(1:intYind), 'b-',...
            centersY(intYind:end), modlupdY2(intYind:end), 'g-');
        title( 'ydata' ), grid on 
        
    end
    
    % until the threshold algorithm is optimized, we will simply take the
    % larger of those determined by the x and y directions
    
    thresh_temp = min([intX_th, intY_th])*.5;
    
 %%%%%******** end threshold determination section************************    
    

  % sigma determination - this algorithm determines an appropriate sigma by
  % using a 64x64 window and determining the block of lowest variation. The
  % standard deviation of this block will then be considered the standard
  % deviation of the noise and thus used for the Gaussian smoothing
  % parameter in the diffusion algorithm
  
  
  % ***** this section takes approximatelz 2.5 minutes per image and so
  % will be used to determine an approximation suitable for the images of
  % interest and then left out for further development******************
  
  winDim = 64;
  minSTD = inf;
  
  % since this shit takes forever it is omitted for now, with the sigma
  % chosen as the average determined from running this code once, which was
  % 159.2623, or rounded to 159 for simplicity.
  
  sigmo = 159;    

%   for j=1:size(temp_img,1)-(winDim-1)
%       
%       t = toc;
%       fprintf('row number %d begins at time t = %d\n', j, t)
%       
%       for k=1:size(temp_img,2)-(winDim-1)
%      
%           currWin = temp_img(j:j+winDim-1,k:k+winDim-1);          
%           currSTD = std2(currWin);      
%            
%           if(currSTD < minSTD)
%               minSTD = currSTD;
%           end           
%       end
%       
%       fprintf('currSTD = %d.\n',currSTD)
%       
%   end
%   
%   minSTDmat(i) = minSTD;
%   fprintf('minSTD of image = %d.\n',minSTD)


% try finding variance using imfilter

temp_img = double(temp_img);
imgMu = imfilter(temp_img,ones(winDim)/winDim^2);
imgVar = imfilter((imgMu-temp_img).^2,ones(winDim)/winDim^2);
minSTDmat2(i) = sqrt(min(min(imgVar(ceil(winDim/2):end-floor(winDim/2),...
                                    ceil(winDim/2):end-floor(winDim/2)))));
  
  %***************** end minSTD estimation algorithm**********************
  
  
  
  % now lets try to run the algorithm for 10 iterations with the determined
  % values for lambda (threshold) and for sigma (sigmo), the standard
  % devation of the Gaussian
  
     for j=10:5:30
         
        figure, imshow(uint16(temp_img)), title('original image')
        fprintf('about to enter nldiff at t = %d\n', toc);
        y = nldif(temp_img, thresh_temp, sigmo, 8, 0.2, j, 2, 1, 'imscale');
        fprintf('completed nldiff at t= %d\n', toc);
        
        figure, imshow(uint16(y));
        
        filestr = strcat('./difftestimages/difftestimg_0', num2str(i), '_',...
                                             'steps_', num2str(j),'.tif');
        imwrite(uint16(y),filestr);
        

        close all
     
     end
    
end
       
