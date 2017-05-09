imgPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif';
outPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\';
testIMG = imread(imgPATH);
dims = size(testIMG);

numCols = dims(2)/600;
numRows = dims(1)/600;
imgStack = zeros(600, 600, numCols*numRows);

segManager = classSegmentationManager;

% breaking up larger image
tempIDX = 0;
for i=1:numRows
    for j=1:numCols
        tempIDX = tempIDX + 1;
        imgStack( :,:, tempIDX ) =...
            testIMG( 600*(i-1)+1:600*i, 600*(j-1)+1:600*j );
    end
end

clear tempIDX
imgCount = size(imgStack, 3);

formatOut = 'yymmdd';
date_str = datestr( now, formatOut );

% fucking with images
tic
for uprbound = .1:.1:.9
    for lowrbound = .1:.1:.9
        
        img_stack_out = zeros( 600, 1800, imgCount );
        
        for i=1:imgCount
            
            %     temp_img_seg = segManager.imgSegmentSobel( imgStack(:,:,i) );
            %     cellPerim = bwperim( temp_img_seg );
            
            imgScaled = imgStack(:,:,i); % scaling by individual image fucks
                            % up final image when concatenated
%             imgScaled = imgScaled - min(min(imgScaled));
%             imgScaled = imgScaled./max(max(imgScaled));
            
            imgSTD = stdfilt( imgStack(:,:,i), ones(11) );
            imgSTD_scaled = imgSTD - min(min(imgSTD));
            imgSTD_scaled = imgSTD_scaled./max(max(imgSTD_scaled));
            
            [imgOut1, imgOutScld1] = segManager.lowpassFFT(imgScaled, uprbound);
            [imgOut2, imgOutScld2] = segManager.highpassFFT(imgScaled, lowrbound);
            %     origCheck = imgOut1 + imgOut2;
            
            imgSeg1 = segManager.imgSegmentSobel( imgOut1 );
            imgSeg2 = segManager.imgSegmentSobel( imgOut2 );
            cellPerim1 = bwperim( imgSeg1 );
            cellPerim2 = bwperim( imgSeg2 );
            
            %     temp_img_seg = imgStack(:,:,i);
            %     temp_img_seg(cellPerim==1) = 0;
            imgOut1( cellPerim1 == 1 ) = 1;
            imgOut2( cellPerim2 == 1 ) = 1;
            %             figure(1), imshow( imgScaled );
            %     subplot(1,2,2), imshow( origCheck, [] );
            %     figure(2), imshow( imgOut, [] );
            %             figure(2), imshow( imgOut1 );
            %             figure(3), imshow( imgOut2 );
            %             imtool( imgSTD , [] );
            
            img_stack_out( :, 1:600, i ) = imgOut1;
            img_stack_out( :, 601:1200, i ) = imgOut2;
            img_stack_out( :, 1201:1800, i ) = imgSTD_scaled;
        end
        
        stack_name = sprintf('DIC_160308_2033_lowr-%.2f_upr-%.2f.mat',...
                                                      lowrbound, uprbound);                                          
        out_filename = strcat( outPATH, stack_name );
        save( out_filename, 'img_stack_out' );
        fprintf('stack %.1f-%.1f complete, t= %.1f seconds\n', lowrbound, uprbound, toc);
    end
end