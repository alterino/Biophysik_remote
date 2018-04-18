close all, clear all, clc

allFiles = dir('T:\Marino\Microscopy\Strip Pattern\compiled\*.tif');
filenames = {allFiles.name};

objMMW = classMicroManagerWrapper;

imgs_cell = cell(1,numel(filenames)*4);

totCnt = 0;

for i = 1:numel(filenames)
   
    img = im2double(imread(filenames{i}));
    img_cnt = 4;
    
    imgs_prsd = parse_images(objMMW, img);
    

    for j = 1:numel(imgs_prsd)
                
        imgs_prsd{j} = scale_input(objMMW, imgs_prsd{j});
        totCnt = totCnt + 1;
        imgs_cell{totCnt} = imgs_prsd{j};
            
    end

end

for i=1:numel(imgs_cell)
    
    img = imgs_cell{i};
    
    img_sc = scale_input(objMMW, img);
    
    % function finds orientation of stripes (ideally) and returns the
    % angle, thetaD, and the center of mass of the region
    [thetaD, centroyd] = seek_pattern_orientation(objMMW, img_sc);
    
    linez = cell(numel(centroyd), 1);
    
    figure, imshow(img_sc)
    
    for j = 1:numel(centroyd)
       
        % creates a line along the region of interest determined by 
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
%         [img_rot, linez_abv_rot] =...
%                             rotate_all(objMMW, img_sc, abvLinez, thetaD2);
        img_rot = img;
        linez_abv_rot = abvLinez;
        

        figure, imshow(img_rot);

        for j = 1:numel(linez_abv_rot)
            tempLine = linez_abv_rot{j};
            hold on, plot(tempLine(:,1), tempLine(:,2), 'b.');       
        end
        
        % rectangular width set to 54 here accounting for a stripe width of
        % 24 and 15 pixels to either side
        [imgs_cr, recs] = extract_AOIs(objMMW, img_rot, linez_abv_rot, 54);
        
        nhood = ones(9);
        n = 9;
        
        [imgs_std, std_nrm, imgs_mn, mn_nrm, coeff_var] =...
                            acquire_local_stats(objMMW, imgs_cr, nhood, n);
           
        for j = 1:numel(std_nrm)
            figure, imshow(imgs_cr{j}), title('image'); 
            figure, imshow(std_nrm{j}), title('std');
            figure, imshow(imgs_mn{j}), title('mn');
            figure, imshow(coeff_var{j}), title('coeff_var');
            var_thresh = 1.2*graythresh(coeff_var{j});
            var_bw = im2bw(coeff_var{j}, var_thresh);
            figure, imshow(var_bw);
        end
        
        strBnds = [15, 30];
        
        [xThresh, rightIndx, leftIndx, img_bw] =...
                 acq_stripe_border_CV(objMMW, coeff_var, imgs_cr, strBnds);
        
        
    
    end
    
    
    
      
    pause
    
    close all
    
    
end