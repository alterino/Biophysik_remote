% figure
% fig_handle = figure;
% jFigPeer = get(fig_handle,'JavaFrame');
% jWindow = jFigPeer.fHG2Client.getWindow;
% % figure(fig_handle, 'Visible', 'off');
% fig_handle.Visible = 'off';
% jWindow.setUndecorated(1);
% com.sun.awt.AWTUtilities.setWindowOpacity(jWindow,0.2)
% fig_handle.Visible = 'on';

% % Sets the units of your root object (screen) to pixels
% set(0,'units','pixels');
% % Obtains this pixel information
% Pix_SS = get(0,'screensize');
% capture_fig = figure('Position', Pix_SS);
% img = screencapture(0, 'Position', Pix_SS);
% figure('units','normalized','outerposition',[0 0 1 1])
% figureFullScreen(); imshow(img)

% imageData = screencapture(capture_fig, Pix_SS );
% figure('Position', Pix_SS), imshow(imageData);

% close all
% % set(0, 'DefaultFigureVisible', 'off')
% % set(0, 'DefaultAxesVisible', 'off')
% Pix_SS = get(0,'screensize');
% % capture_fig = figure('Position', Pix_SS);
% img = screencapture(0, 'Position', Pix_SS);
%
% h_fig = figure('Visible', 'off');
% figure(h_fig), imshow(img);
% [x,y] = ginput(1);

% image analysis for microscope automation
if( exist('img','var')==0 )
    [~, result] = dos('getmac');
    if(strcmp(result(160:176), '64-00-6A-43-EF-0A'))
        img = imread('T:\Marino\Microscopy\170523\DIC_170523_1537.tif'); % lab path
    else
        img = imread('D:\OS_Biophysik\Microscopy\170523\DIC_170523_1537.tif'); % home path
    end
end

% placeholder for generating image stack
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

