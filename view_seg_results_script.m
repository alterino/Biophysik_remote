imgPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif';
testIMG = imread(imgPATH);
dims = size(testIMG);

numCols = dims(2)/600;
numRows = dims(1)/600;

clear imgPATH testIMG dims


data_dir_str = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\';
data_dir = dir( strcat( data_dir_str, '*.mat' ) );


filestr = cell( length(data_dir), 1 );
for i = 1:length( data_dir )
    
    
    temp_str = strcat( data_dir_str, data_dir(i).name );
    
    if( strcmp( temp_str(end-24:end-23), 'bp' ) )
        bandpass_flag = 1;
    else
        bandpass_flag = 0;
    end
    
    filestr{i} = temp_str;
    load( filestr{i}, 'img_stack_out' );
    
    switch bandpass_flag
        case 0
%             uprBound = filestr{i};
%             uprBound = uprBound(end-7:end-4);
%             lowrBound = filestr{i};
%             lowrBound = lowrBound(end-16:end-13);
%             title_str_highpass = strcat( 'highpass_lowrBound- ', lowrBound );
%             title_str_lowpass = strcat( 'lowpass_uprBound- ', uprBound );
%             
%             lowPassIMG = zeros( 9000, 9000 );
%             highPassIMG = zeros( 9000, 9000 );
%             if( i == 50 )
%                 stdIMG = zeros( 9000, 9000 );
%             end
%             for j = 1:size(img_stack_out, 3)
%                 tempIMG = img_stack_out(:,:,j);
% %                 figure(1), imshow( tempIMG, [] )
%                 col_idx = mod(j, 15);
%                 row_idx = ceil( j/15 );
%                 
%                 if(row_idx == 0), row_idx = 15; end
%                 if(col_idx == 0), col_idx = 15; end
%                 
%                 lowPassIMG( 1+(row_idx-1)*600:600+(row_idx-1)*600,...
%                     1+(col_idx-1)*600:600+(col_idx-1)*600 ) = tempIMG( :, 1:600 );
%                 highPassIMG( 1+(row_idx-1)*600:600+(row_idx-1)*600,...
%                     1+(col_idx-1)*600:600+(col_idx-1)*600 ) = tempIMG( :, 601:1200 );
%                 if( i == 50 )
%                     stdIMG( 1+(row_idx-1)*600:600+(row_idx-1)*600,...
%                         1+(col_idx-1)*600:600+(col_idx-1)*600 ) = tempIMG( :, 1201:1800 );
%                 end
%             end
%             
%             lowpass_str = strcat( data_dir_str, title_str_lowpass, '.tif' );
%             highpass_str = strcat( data_dir_str, title_str_highpass, '.tif' );
%             if( i == 1 )
%                 std_str = strcat( data_dir_str, 'stdfilt.tif' );
%                 imwrite( stdIMG, std_str );
%             end
%             imwrite( lowPassIMG, lowpass_str );
%             imwrite( highPassIMG, highpass_str );
            
        case 1
            
            uprBound = filestr{i};
            uprBound = uprBound(end-7:end-4);
            lowrBound = filestr{i};
            lowrBound = lowrBound(end-16:end-13);
            title_str_bandpass = strcat( 'bandpass_lowrBound-', lowrBound,...
                '_uprbound-', uprBound );
            title_str_segged = strcat( title_str_bandpass, '_segged' );
            
            bandPassIMG = zeros( 9000, 9000, 'uint16' );
            segIMG = zeros( 9000, 9000, 'uint16' );
            for j = 1:size(img_stack_out, 3)
                tempIMG = uint16( img_stack_out(:,:,j) );
%                 figure(1), imshow( tempIMG, [] )
                col_idx = mod(j, 15);
                row_idx = ceil( j/15 );
                
                if(row_idx == 0), row_idx = 15; end
                if(col_idx == 0), col_idx = 15; end
                
                bandPassIMG( 1+(row_idx-1)*600:600+(row_idx-1)*600,...
                    1+(col_idx-1)*600:600+(col_idx-1)*600 ) = tempIMG( :, 1:600 );
                segIMG( 1+(row_idx-1)*600:600+(row_idx-1)*600,...
                    1+(col_idx-1)*600:600+(col_idx-1)*600 ) = tempIMG( :, 601:1200 );
            end
            
            bandpass_str = strcat( data_dir_str, title_str_bandpass, '.tif' );
            segged_str = strcat( data_dir_str, title_str_segged, '.jpg');
            
            imwrite( bandPassIMG, bandpass_str );
            imwrite( segIMG, segged_str );
            
        otherwise
            disp( 'error, bandpass flag not correctly instantiated\n' )
    end
end