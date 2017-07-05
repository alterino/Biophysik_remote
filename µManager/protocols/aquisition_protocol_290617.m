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
set_camera_ROI(objMicMan,[400 400 1200 1200])
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
wvlnth = 561;
set_exposure_time(objMicMan,100) %[ms]

[scanFluor,metaFluor] = acq_path_fluorescense(objMicMan,x,y,wvlnth); %acqures images along the path
scanFluor = stitch_img(objMicMan,scanFluor,bad);

timeStamp = datestr(now,'yymmdd_HHMM');
imwrite(uint16(max(0,scanFluor)),sprintf('%s_%d_%s.tif','Fluor',wvlnth,timeStamp),'compression','none')
save(sprintf('%s_%d_%s_%s.mat','Fluor',wvlnth,timeStamp,'META'),'metaFluor')

%%
set_auto_focus_state(objMicMan,0)
set_objective_stage_z_position_micron(objMicMan,0)
