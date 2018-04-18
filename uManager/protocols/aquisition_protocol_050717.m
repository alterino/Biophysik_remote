addpath(genpath(pwd))

objMicMan = classMicroManagerWrapper;
initialize_micro_manager(objMicMan,'')

%%
update_screen_shot(objMicMan.ScreenShot)

get_laser(objMicMan)
set_laser_state_toggle_pos(objMicMan.Laser,561)

get_cleanup_filter(objMicMan)
cleanup_filter_dropdown_pos(objMicMan.CleanupFilter)

scan_and_lock_into_auto_focus(objMicMan)
set_pixel_binning(objMicMan,1)
cam_ROI_BB = [400 400 1200 1200];
set_camera_ROI(objMicMan,cam_ROI_BB)
set_central_xy_pos(objMicMan)

fac = 15;
[x,y,bad] = set_rectangular_path(objMicMan,fac,fac); %[µm] generates the path coordinates using non-overlapping steps

%% DIC scan
set_transmission_lamp_power(objMicMan,1)
set_transmission_lamp_voltage(objMicMan,5.5)

set_exposure_time(objMicMan,100) %[ms]

[scanDIC,metaDIC] = acq_path_DIC(objMicMan,x,y); %acqures images along the path
scanDIC = stitch_img(objMicMan,scanDIC,bad);

timeStamp = datestr(now,'yymmdd_HHMM');
imwrite(uint16(max(0,scanDIC)),sprintf('%s_%s.tif','DIC',timeStamp),'compression','none')
save(sprintf('%s_%s_%s.mat','DIC',timeStamp,'META'),'metaDIC')

%% Fluorescense
% wvlnth = 561;
% set_exposure_time(objMicMan,100) %[ms]
% 
% [scanFluor,metaFluor] = acq_path_fluorescense(objMicMan,x,y,wvlnth); %acqures images along the path
% scanFluor = stitch_img(objMicMan,scanFluor,bad);
% 
% timeStamp = datestr(now,'yymmdd_HHMM');
% imwrite(uint16(max(0,scanFluor)),sprintf('%s_%d_%s.tif','Fluor',wvlnth,timeStamp),'compression','none')
% save(sprintf('%s_%d_%s_%s.mat','Fluor',wvlnth,timeStamp,'META'),'metaFluor')
% 
% dic_scan = uint16(max(0, scanDIC));
% fluor_scan = uint16(max(0,scanFluor));

% the above needs to be replaced with acquiring only images in ROIs

wvlnth = 561;
set_exposure_time(objMicMan,100) %[ms]

wind = 9;
[bw_img, cc, stats] = ...
    process_and_label_DIC( scanDIC, cam_ROI_BB(3:4) , wind );

keeper_count = 0;
keeper_idx = [];
for i = 1:length(stats)
    if( ~(stats(i).BoundingBox(3) > img_dims(2) ||...
            stats(i).BoundingBox(4) > img_dims(1) ) )
        stats(i).keepBool = true;
        keeper_count = keeper_count + 1;
        keeper_idx = [keeper_idx; i];
    else
        stats(i).keepBool = false;
    end
end

dic_stack = zeros(img_dims(1), img_dims(2), keeper_count);
fluor_stack = zeros(img_dims(1), img_dims(2), keeper_count);
dic_stack_bw = zeros(img_dims(1), img_dims(2), keeper_count);
fluor_stack_bw = zeros(img_dims(1), img_dims(2), keeper_count);
img_idx = 0;
stat_dist_vec = zeros( length(stats_update), 1 );
weights = [10 1 1 10];

for i = 1:keeper_count
   % insert acquisition for updated DIC image here
   updated_DIC_img = '??';
   [bw_img, cc, stats_update] = ...
        process_and_label_DIC( dic_scan, img_dims, wind );
    keeper_stats = stats(i);
%     keeper_stats(i).candidates = stats_update;
    
    for j = 1:length(stats_update)
        stats_update(j).center_dist = norm( stats_update(j).Centroid - keeper_stats.Centroid ); 
        stats_update(j).area_diff = abs( keeper_stats.Area - stats_update(j).Area );
        stats_update(j).convex_diff = abs( keeper_stats.ConvexArea - stats_update(j).ConvexArea );
        stats_update(j).eccent_diff = abs( keeper_stats.Eccentricity - stats_update(j).Eccentricity );
        stat_dist_vec(j) = weights(1)*stats_update(j).center_dist +...
                           weights(2)*stats_update(j).area_diff +...
                           weights(3)*stats_update(j).convex_diff +...
                           weights(4)*stats_update(j).eccent_diff;
    end
    
    keeper_stats(i).candidate_stats = stats_update;
    keeper_stats(i).candidate_dists = stat_dist_vec;
        
   
   % insert acquisition for updated fluorescence image here 
   fluor_img = '??';
end

% insert fluorescence eval here

% and maybe a secondary backup protocol to find more images starting with
% fluorescence channel



%%
set_auto_focus_state(objMicMan,0)
set_objective_stage_z_position_micron(objMicMan,0)
