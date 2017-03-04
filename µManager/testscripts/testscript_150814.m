%%
% set_auto_focus_state(objMicMan,1)

hfig = figure;

%analysze frame for pattern
% [thetaD, centroyd] = seek_pattern_orientation(objMicMan, img_FL);
% shft = 114;
% shftFac = 0;
% q = 1;
% allesKlar = false;
% while(~allesKlar)
% 
%     datapts = create_line(objMicMan, img_FL, thetaD, centroyd, shft*(shftFac));        
%     allesKlar = isempty(datapts);
% 
%     if (~isempty(datapts))
%         linez{q} = datapts;
%         q = q+1;
%         shftFac = shftFac + 1;
%     end
% 
% end
% 
% shftFac = -1;
% allesKlar = false;
% 
% while(~allesKlar)
% 
%     datapts = create_line(objMicMan, img_FL, thetaD, centroyd, shft*(shftFac));       
%     allesKlar = isempty(datapts);
% 
%     if (~isempty(datapts))
%         linez{q} = datapts;
%         q = q+1;
%         shftFac = shftFac - 1;
%     end
% 
% end
% 
% H = fspecial('gaussian', 50, 50/6);
%     
% img_sm1 = medfilt2(img_FL, [2 2]);
% img_sm1 = imfilter(img_sm1, H, 'replicate');
% 
% [thresh, intVals_cell] = global_thresh_calc(objMicMan, img_sm1, linez);
% [abvThresh, belThresh] = classify_pts(objMicMan, img_sm1,...
%                                         thresh, intVals_cell, linez);
%                              
% abvThresh_comp = [];
% for j = 1:numel(abvThresh)
%    abvTemp = abvThresh{j};
%    belTemp = belThresh{j};
%    hold on, plot(abvTemp(:,1), abvTemp(:,2), 'g.', belTemp(:,1),...
%                     belTemp(:,2), 'k.')
%                 abvThresh_comp = [abvThresh_comp; abvTemp];
% end
% 
% 
% [count, decis1] = classify_image_FL(objMicMan, img_FL, abvThresh_comp);
% 
% 
% if(decis1 == 1)
profile on
for iter = 1:1
    %if pattern present take DIC
    %set revolver to DIC
     set_filter_revolver_position(objMicMan,5)

    %open lamp shutter
    set_tranmission_lamp_shutter_state(objMicMan,1)
    %read camera
    img_DIC = get_actual_image(objMicMan);
    %analysze frame for live cell
    img_sm2 = smooth_img_DIC_20x(objMicMan, img_DIC);
    img_bw = segment_image_DIC(objMicMan, img_sm2);
    
    draw_boundaries(objMicMan,img_DIC,img_bw)
    [indsD, indsA, indsM, numLive] = classify_cells_DIC(objMicMan, img_bw);
    plot_classifier(objMicMan, indsD, indsA, indsM)
    magnif = 60;
    
    decis2 = classify_image_DIC(objMicMan, numLive, magnif);
    
    set_tranmission_lamp_shutter_state(objMicMan,0)
    
    %take fluorescent picture
%set revolver to fluorescent
 set_filter_revolver_position(objMicMan,0)
%switch laser on
set_laser_state(objMicMan.Laser,561,1);
%read camera
img_FL = get_actual_image(objMicMan);
%switch laser off
set_laser_state(objMicMan.Laser,561,0);

figure(hfig);imagesc(img_FL); axis image

set_xy_rel_pos_micron(objMicMan,[100 0])
end
profile viewer
% end

%move on
