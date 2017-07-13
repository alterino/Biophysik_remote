function [imgPtsX, imgPtsY] = scan_center_to_img_idx( x, y, numX, numY, pxSize, img_dims, stage_center )
if( length(x) > 1 || length(y) > 1 )
    error('x and y should be scalar inputs')
end

%             pxSize = get_img_px_size(this);
%             ROI = get_camera_ROI(this);
imgWidth = img_dims(2);
imgHeight = img_dims(1);

totalHeight = numY*imgHeight*pxSize;
totalWidth = numX*imgWidth*pxSize;

x_start_idx = uint16( ( ( x - stage_center(1) + totalWidth/2)/pxSize - imgWidth/2 )/imgWidth + 1 );
y_start_idx = uint16( ( ( y - stage_center(2) + totalHeight/2)/pxSize - imgHeight/2 )/imgHeight + 1 );

imgPtsX = uint16( meshgrid( (x_start_idx-1)*imgWidth+1:x_start_idx*imgWidth ) );
imgPtsY = uint16( meshgrid( (y_start_idx-1)*imgHeight+1:y_start_idx*imgHeight )' );
end