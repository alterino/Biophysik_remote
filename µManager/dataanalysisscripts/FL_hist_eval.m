close all, clear all, clc

allFiles = dir( 'T:\Marino\Microscopy\Raw Images for Michael\compiled\*.tif' );
filenames = {allFiles.name};

objMMW = classMicroManagerWrapper;

datafile_str =...
 'T:\Marino\Repository\µManager\dataanalysisscripts\FL_hist_eval\data.csv';
        
titlestr = {'filename', 'mean', 'variance', 'minimum', 'maximum',...
                                                               'skewness'};

data = titlestr;

for i = 1:numel(filenames)
   
    img = im2double(imread(filenames{i}));
    img_sc = scale_input(objMMW, img);
    
    dims = size(img);
    
    img_vec = reshape(img, 1, dims(1)*dims(2));
    mn = mean(img_vec);
    vr = var(img_vec);
    mini = min(img_vec);
    mx = max(img_vec);
    skw = skewness(img_vec);
    
    data = [data; {filenames{i}, mn, vr, mini, mx, skw}];
    
    ax = figure, hist(img_vec,100), title('histogram of intensity values')
    grid on %, axis([0 .05 0 8e4])
    
    temp = filenames{i};
    temp = temp(1:end-4);
    
    filestr = strcat('T:\Marino\Repository\µManager\dataanalysisscripts\FL_hist_eval\',...
                                        temp, '_hist.png');
    
    cdata = print(ax, '-RGBImage');
    cdata = imresize(im2double(rgb2gray(cdata)), [dims(1), dims(2)]);
    cdata_img = [cdata, img_sc];
    imwrite(cdata_img, filestr);
    
    pause(2)
    close all
    
end

xlswrite(datafile_str, data);