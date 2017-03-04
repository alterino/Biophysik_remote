imgPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif';
testIMG = imread(imgPATH);
dims = size(testIMG);

numCols = dims(2)/600;
numRows = dims(1)/600;
imgStack = zeros(600, 600, numCols*numRows);

segManager = classSegmentationManager;

% breaking up larger image
for i=1:numCols
    for j=1:numRows
        
        imgStack( :,:, i*j ) =...
            testIMG( 600*(i-1)+1:600*i, 600*(j-1)+1:600*j );
        
    end
end

imgCount = size(imgStack, 3);

% fucking with images
for i=1:imgCount
    
%     temp_img_seg = segManager.imgSegmentSobel( imgStack(:,:,i) );
%     cellPerim = bwperim( temp_img_seg );
    
    uprbound = 999;
    [imgOut, imgOutScld] = segManager.lowpassFFT(imgStack(:,:,i), uprbound);
    
    
    temp_img_seg = imgStack(:,:,i);
    temp_img_seg(cellPerim==1) = 0;
    figure(1), imshow( imgStack(:,:,i), [] );
    figure(2), imshow( imgOut, [] );
    figure(3), imshow( imgOutScld, [] );
    
    
    
end