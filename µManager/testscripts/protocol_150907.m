
dx = 30;
dy = 30;
r = 200;
lambda = 488;

R = set_stage_path(objMicMan,dx,dy,r);
dirStr = 'X:\Marino\Microscopy\150904\FL_eval\';

files = dir('T:\Marino\Microscopy\150904');
filenames = {files.name};

addpath('T:\Marino\Microscopy\150904');

for i = 1:size(R,1)
    xyPosMicron = R(i,:);
    set_xy_pos_micron(objMicMan,xyPosMicron)

    
    img = uint16(snap_img_fluorescence(objMicMan,lambda));
    img_sc = scale_input(objMicMan, img);
    set_laser_state(objMicMan.Laser, lambda, 0);
    
    assess_image_variance(objMicMan, img);
    
    % pattern
%     img = scale_input(objMicMan, im2double(imglambda));
    imgStr = strcat(dirStr, 'imglambda_0', num2str(i), '.tif');
    imwrite(img, imgStr);
    
    if(objMicMan.LocationClassifier ~= -1)
    
        [thetaD, centroyd] = seek_pattern_orientation(objMicMan, img);

        thetaD2 = 90-abs(thetaD);
        if (thetaD < 0)
            thetaD2 = -thetaD2;
        end
    
    end
    
    % if(~isempty(thetaD) || abs(thetaD) < 75)
    %    objMicMan.LocationClassifier = -1;
    % end
    
    
    if(objMicMan.LocationClassifier ~= -1)
        
        linez = cell(numel(centroyd), 1);
        
        for j = 1:numel(centroyd)
            
            linez{j} = create_linez(objMicMan, img, thetaD, centroyd{j});
            temp = linez{j};
            if(~isempty(temp))
                hold on, plot(temp(:,1), temp(:,2), 'b.');
            end
        end
        ax = gca;
        s = getframe(ax);
        axStr = strcat(dirStr, 'img_lnz_0', num2str(i), '.png');
        imwrite(s.cdata, axStr);
        img_lnz = rgb2gray(s.cdata);
        img_lnz = img_lnz(1:size(img,1),1:size(img,2));
        
        H = fspecial('gaussian', 50, 50/6);
        
        img_sm = medfilt2(img, [2 2]);
        img_sm = imfilter(img_sm, H, 'replicate');
        
        [thresh, intVals_cell, intVals] = global_thresh_calc(objMicMan, img_sm, linez);
        [abvThresh, belThresh] =...
            classify_pts(objMicMan, thresh, intVals_cell, linez);
        
        abvLinez = abvThresh;
        
        for j = 1:numel(abvThresh)
            tempA = abvThresh{j};
            tempB = belThresh{j};
            hold on, plot(tempA(:,1), tempA(:,2), 'g.', tempB(:,1),...
            tempB(:,2), 'r.')
        end
        ax = gca;
        s = getframe(ax);
        axStr = strcat(dirStr, 'img_lnz_threshd_0', num2str(i), '.png');
        imwrite(s.cdata, axStr);
        img_threshd = rgb2gray(s.cdata);
        img_threshd = img_threshd(1:size(img,1),1:size(img,2));
        
        [img_rot, linez_abv_rot] =...
            rotate_all(objMicMan, img, abvLinez, thetaD2);
        ax = figure, set(ax, 'Position', [1000 200 1000 1000]);
        imshow(img_rot, []);
        
        for j = 1:numel(linez_abv_rot)
            
            tempLine = linez_abv_rot{j};
            hold on, plot(tempLine(:,1), tempLine(:,2), 'b.');
            
        end
        
%         ax = gca;
        s = getframe(ax);
        axStr = strcat(dirStr, 'img_rtd_0', num2str(i), '.png');
%         img_threshd = s.cdata;
%         imwrite(s.cdata, axStr);
        
%         recWidth = 54;
%         
%         [imgs_cr, recs] = extract_AOIs(objMicMan, img_rot, linez_abv_rot, recWidth);
%         
%         nhood = ones(9);
%         n = 9;
%         
%         [imgs_std, std_nrm, imgs_mn, mn_nrm, coeff_var] =...
%             acquire_local_stats(objMicMan, imgs_cr, nhood, n);
%         
%         strBnds = [30, 60];
%         [xThresh, rightIndx, leftIndx, img_bw] =...
%             acq_stripe_border_CV(objMicMan, coeff_var, imgs_cr, strBnds);

        img_comped = [im2uint16(img_sc), im2uint16(img_threshd)];
        imgStr = strcat(dirStr, 'img_cmped_0', num2str(i), '.png');
        imwrite(img_comped, imgStr);

    
    else
        img_comped = uint16(img_sc);
        imgStr = strcat(dirStr, 'img_cmped_0', num2str(i), 'x', '.png');
        imwrite(img_comped, imgStr);
        figure, imshow(img, []);
       dims = size(img);
       hold on, plot(round(dims(2)/2), round(dims(1)/2), 'rx', 'MarkerSize', 20)
%         figure, set(gca, 'Position', [1000 200 1000 1000]);
%         imshow(img_sc)
%         figure, imshow(img)
%         ax = gca;
%         s = getframe(ax);
%         axStr = strcat(dirStr, 'img_sc_0', num2str(i), '.png');
%         imwrite(img, axStr);
   
    end
    
    pause(.5)
        
    close all
    
end
