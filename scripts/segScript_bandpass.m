% lab path
imgPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif';
outPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\';

% home path
% imgPATH = 'D:\OS_Biophysik\DIC_images\DIC_160308_2033.tif';
% outPATH = 'D:\OS_Biophysik\Processed\';

scale_factor = 0.7;

testIMG = imread(imgPATH);
img_max = max( max( testIMG ));

dims = size(testIMG);

numCols = dims(2)/600;
numRows = dims(1)/600;
imgStack = uint16(zeros(600, 600, numCols*numRows));

segManager = classSegmentationManager;

% breaking up larger image
tempIDX = 0;
for i=1:numCols
    for j=1:numRows
        tempIDX = tempIDX + 1;
        imgStack( :,:, tempIDX ) =...
            uint16( testIMG( 600*(i-1)+1:600*i, 600*(j-1)+1:600*j ) );
    end
end
clear tempIDX
imgCount = size(imgStack, 3);

formatOut = 'yymmdd';
date_str = datestr( now, formatOut );

% fucking with images
tic
for lowrbound = 0.0:.1:1.5
    
%     for uprbound = ( lowrbound+.3 ):.3:3.3
    for uprbound = 2.1:.3:3.3
        
        title_str_bandpass = sprintf( 'bandpass_lowrBound-%.1f_uprbound-%.1f_sf_%.2f',...
            lowrbound, uprbound, scale_factor );
        title_str_segged = strcat( title_str_bandpass, '_segged' );
        title_str_binary = strcat( title_str_bandpass, '_binary' );
        
        bandpass_str = strcat( outPATH, title_str_bandpass, '.tif' );
        segged_str = strcat( outPATH, title_str_segged, '.jpg');
        binary_str = strcat( outPATH, title_str_binary, '.mat');
        
        img_stack_out = zeros( 600, 1200, imgCount );
        img_stack_seg = zeros( 600, 600, imgCount );
        for i=1:imgCount
            temp_img = imgStack(:,:,i);
            
            [imgOut, imgOutScld] = segManager.bandpassFFT( temp_img,...
                lowrbound, uprbound );
            imgSeg = segManager.imgSegmentSobel( imgOut, scale_factor );
            img_stack_seg(:,:,i) = imgSeg;
            cellPerim = bwperim( imgSeg );

            tempImgSeg = temp_img;
            tempImgSeg( cellPerim == 1 ) = img_max;
            
            img_stack_out(:, 1:600, i) = imgOut;
            img_stack_out(:, 601:1200, i) = tempImgSeg;

        end
        
        [ bandpassIMG, segIMG ] = reshape_DIC_stack( img_stack_out );
        
        imwrite( bandpassIMG, bandpass_str );
        imwrite( im2uint8(segIMG) , segged_str );
        save( binary_str, 'img_stack_seg' );
        
        fprintf('stack %.1f-%.1f complete, t= %.1f seconds\n', lowrbound, uprbound, toc);
        
    end
end