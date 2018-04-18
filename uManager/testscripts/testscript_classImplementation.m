close all, clear variables, clc

allFiles = dir( 'T:\Marino\Microscopy\150902\FL_eval\archived\noise_imgs\*.png' );
filenames = {allFiles.name};

objMMW = classMicroManagerWrapper;

for i=1:numel(filenames)
    tic
    img = (imread(filenames{i}));
    
    if(length(size(img)) > 2), img = rgb2gray(img); end
    
    img = im2double(img);
    
%     img_sc = img-min(min(img));
%     img_sc = img_sc./max(max(img_sc));
    img_sc = img;
    [thetaD, centroyd] = seek_pattern_orientation(objMMW, img);
    
    thetaD2 = 90-abs(thetaD);
    if (thetaD < 0)
        thetaD2 = -thetaD2;
    end
    
%     if (~isempty(thetaD))
%         img_sc = imrotate(img_sc, thetaD2);
%     end
    
    [thetaD, centroyd] = seek_pattern_orientation(objMMW, img_sc);
    
    linez = cell(numel(centroyd), 1);
    
    figure, imshow(img_sc, [])
    
    for j = 1:numel(centroyd)
       
        linez{j} = create_linez(objMMW, img, thetaD, centroyd{j});
        temp = linez{j};
        if(~isempty(temp))
            hold on, plot(temp(:,1), temp(:,2), 'b.');
        end
    end
    H = fspecial('gaussian', 50, 50/6);
    
    img_sm = medfilt2(img_sc, [2 2]);
    img_sm = imfilter(img_sm, H, 'replicate');
     
    [thresh, intVals_cell, intVals] = global_thresh_calc(objMMW, img_sm, linez);
    [abvThresh, belThresh] =...
                classify_pts(objMMW, thresh, intVals_cell, linez);
    
    abvLinez = abvThresh;
    
    for j = 1:numel(abvThresh)
        tempA = abvThresh{j};
        tempB = belThresh{j};
        hold on, plot(tempA(:,1), tempA(:,2), 'g.', tempB(:,1),...
                                                        tempB(:,2), 'r.')
    end
    
    if (~isempty(abvLinez))
            thetaD2 = 90-abs(thetaD);
            if (thetaD < 0)
                thetaD2 = -thetaD2;
            end
        [img_rot, linez_abv_rot] =...
                            rotate_all(objMMW, img_sc, abvLinez, thetaD2);

        figure, imshow(img_rot, []);

        for j = 1:numel(linez_abv_rot)

            tempLine = linez_abv_rot{j};
            hold on, plot(tempLine(:,1), tempLine(:,2), 'b.');       

        end
        
        recWidth = 91;
        
        [imgs_cr, recs] = extract_AOIs(objMMW, img_rot, linez_abv_rot, recWidth);
        
        nhood = ones(9);
        n = 9;
        
        [imgs_std, std_nrm, imgs_mn, mn_nrm, coeff_var] =...
                            acquire_local_stats(objMMW, imgs_cr, nhood, n);
        
        
        
        for j = 1:numel(std_nrm)
            figure, imshow(coeff_var{j}), title('coeff_var');
            var_thresh = 1.2*graythresh(coeff_var{j});
            var_bw = im2bw(coeff_var{j}, var_thresh);
            figure, imshow(var_bw);
        end
        
        strBnds = [40, 60]; 
        [xThresh, rightIndx, leftIndx, img_bw] =...
                 acq_stripe_border_CV(objMMW, coeff_var, imgs_cr, strBnds);
        
    end
    
    
    toc
      
    pause
    
    close all
    
    
end