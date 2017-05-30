get_cellsense_interface(objMicMan)
scan_and_lock_into_auto_focus(objMicMan)
set_camera_ROI(objMicMan,[200 200 600 600])
set_central_xy_pos(objMicMan)

ROI = get_camera_ROI(objMicMan);
pxSize = get_img_px_size(objMicMan); %[µm]

fac = 15;
[x,y,bad] = set_rectangular_path(objMicMan,fac,fac); %[µm] generates the path coordinates using non-overlapping steps

%% DIC scan
set_tranmission_lamp_power(objMicMan,1)
set_tranmission_lamp_voltage(objMicMan,6)

set_exposure_time(objMicMan,50) %[ms]

[scanDIC,metaDIC] = acq_path_DIC(objMicMan,x,y); %acqures images along the path
scanDIC = stitch_img(objMicMan,scanDIC,bad);

timeStamp = datestr(now,'yymmdd_HHMM');
imwrite(uint16(max(0,scanDIC)),sprintf('%s_%s.tif','DIC',timeStamp),'compression','none')
save(sprintf('%s_%s_%s.mat','DIC',timeStamp,'META'),'metaDIC')

%% Fluorescense
wvlnth = 640;
set_exposure_time(objMicMan,500) %[ms]

[scanFluor640,metaFluor] = acq_path_fluorescense(objMicMan,x,y,wvlnth); %acqures images along the path
scanFluor640 = stitch_img(objMicMan,scanFluor640,bad);

timeStamp = datestr(now,'yymmdd_HHMM');
imwrite(uint16(max(0,scanFluor640)),sprintf('%s_%d_%s.tif','Fluor',wvlnth,timeStamp),'compression','none')
save(sprintf('%s_%d_%s_%s.mat','Fluor',wvlnth,timeStamp,'META'),'metaFluor')

scanFluor640 = norm2quantile(scanFluor640,[0.01 0.99]);

%% selection
scanDIC = repmat(0.5*norm2quantile(scanDIC,[0.01 0.99]),[1,1,3]);
scanDIC(:,:,1) = scanDIC(:,:,1) + 0.5*scanFluor561;
scanDIC(:,:,2) = scanDIC(:,:,2) + 0.5*scanFluor640;

listCoordXY = select_cells_from_overview(objMicMan,scanDIC,ROI);


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
        
        set_exposure_time(objMicMan,30) %[ms]
        img{idxPos,2}(:,:,:,idxFrame) = mov_fluorescence(objMicMan,640,100);
        meta{idxPos,2}(idxFrame) = get_acq_meta(objMicMan);
        
    end
    pause(5*60)
end


%% image analysis
% if( exist(img,1)==0 )
%     img = imread('D:\OS_Biophysik\Microscopy\170523\DIC_170523_1537.tif');
% end
% placeholder for generating image stack
% assumes a 2D image composed of 600x600 images
img_stack = img_2D_to_img_stack(img, [600, 600] );
% placeholder for generating gmm model or, alternatively, loading previous
% model
% gmm = generate_gmm_entropy();
% load( **insert gmm file here** );
load( 'gmm.mat' )
bw_stack = zeros( size(img_stack) );

for i = 1:size(img_stack)
    if( max(max( img_stack(:,:,i) ) ) == 0 )
        continue
    else
        [clustered_img, ~] = ...
            cluster_img_entropy( img_stack(:,:,i), [], gmm, 9, 1000);
        bw_stack(:,:,i) = (clustered_img > 1);
        temp_perim = bwperim( bw_stack(:,:,i) );
        temp_img = img_stack(:,:,i);
        temp_img(temp_perim==1) = max(max(temp_img));
        figure(1), subplot(1,2,1), imshow( temp_img, [] );
        subplot(1,2,2), imshow( bw_stack(:,:,i) );
    end
end

% placeholder for generating connected components structure
bw_img = img_stack_to_img_2D(bw_stack, [20 20] );
cc = bwconncomp(bw_img);
cc_props = get_cc_regionprops(cc);

keep_idx = [];
for i = 1:length( cc_props )
    bnd_box = cc_props(i).BoundingBox;
    if( cc_props(i).Area>1000 && bnd_box(3)<600 && bnd_box(4)<600  )
        keep_idx = [keep_idx; i];
    end
end

cc_props = cc_props(keep_idx);
cc.PixelIdxList = cc.PixelIdxList(keep_idx);
licing_cc.NumObjects = length(keep_idx);












