get_cellsense_interface(objMicMan)
scan_and_lock_into_auto_focus(objMicMan)
set_pixel_binning(objMicMan,1)
set_camera_ROI(objMicMan,[400 400 1200 1200])
set_central_xy_pos(objMicMan)

ROI = get_camera_ROI(objMicMan);
pxSize = get_img_px_size(objMicMan); %[µm]

fac = 15;
[x,y,bad] = set_rectangular_path(objMicMan,fac,fac); %[µm] generates the path coordinates using non-overlapping steps

%% DIC scan
set_transmission_lamp_power(objMicMan,1)
set_transmission_lamp_voltage(objMicMan,5.5)

set_exposure_time(objMicMan,100) %[ms]

[scanDIC,metaDIC] = acq_path_DIC(objMicMan,x,y); %acqures images along the path
scanDIC = stitch_img(objMicMan,scanDIC,bad);

% [img,x,y,img_] = acq_rectangular_path_DIC(objMicMan,20,20);

timeStamp = datestr(now,'yymmdd_HHMM');
imwrite(uint16(max(0,scanDIC)),sprintf('%s_%s.tif','DIC',timeStamp),'compression','none')
save(sprintf('%s_%s_%s.mat','DIC',timeStamp,'META'),'metaDIC')

%% Fluorescense
wvlnth = 405;
set_exposure_time(objMicMan,100) %[ms]

[scanFluor640,metaFluor] = acq_path_fluorescense(objMicMan,x,y,wvlnth); %acqures images along the path
scanFluor640 = stitch_img(objMicMan,scanFluor640,bad);

timeStamp = datestr(now,'yymmdd_HHMM');
imwrite(uint16(max(0,scanFluor640)),sprintf('%s_%d_%s.tif','Fluor',wvlnth,timeStamp),'compression','none')
save(sprintf('%s_%d_%s_%s.mat','Fluor',wvlnth,timeStamp,'META'),'metaFluor')

scanFluor640 = norm2quantile(scanFluor640,[0.01 0.99]);

%% selection
range = quantile(scanDIC(:),[0.01 0.99]);
scanDIC = min(1,max(0,repmat((scanDIC-range(1))/diff(range),[1,1,3])));
scanDIC(:,:,1) = scanDIC(:,:,1) + 0.5*scanFluor561;
scanDIC(:,:,2) = scanDIC(:,:,2) + 0.5*scanFluor640;

listCoordXY = select_cells_from_overview(objMicMan,(scanDIC),ROI);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for idxFrame = 1:10
    for idxPos = 1:size(listCoordXY,1);
        set_xy_pos_micron(objMicMan,listCoordXY(idxPos,:)) %move stage
        pause(0)

        %% DIC
        set_exposure_time(objMicMan,50) %[ms]
        [img{idxPos,1}(:,:,idxFrame),meta{idxPos,1}(idxFrame)] = snap_img_DIC(objMicMan);
        
        %% Fluor        
        %640nm
%         set_exposure_time(objMicMan,500) %[ms]
%         [img{idxPos,2}(:,:,idxFrame),meta{idxPos,2}(idxFrame)] = snap_img_fluorescence(objMicMan,640);
        
%         set_exposure_time(objMicMan,30) %[ms]
%         img{idxPos,2}(:,:,:,idxFrame) = mov_fluorescence(objMicMan,640,100);
%         meta{idxPos,2}(idxFrame) = get_acq_meta(objMicMan);
        
    end
    pause(5*60)
end