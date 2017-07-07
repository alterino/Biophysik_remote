function [imgPtsX, imgPtsY] = scan_center_to_img_idx( this, x, y, numX, numY )
if( length(x) > 1 || length(y) > 1 )
    error('x and y should be scalar inputs')
end

pxSize = .108;
imgWidth = 1200;
imgHeight = 1200;
totalHeight = numY*imgHeight*pxSize;
totalWidth = numX*imgWidth*pxSize;

x_start_idx = uint16( ( ( x - this.XYStageCtr(1) + totalWidth/2)/pxSize - imgWidth/2 )/imgWidth + 1 );
y_start_idx = uint16( ( ( y - this.XYStageCtr(2) + totalHeight/2)/pxSize - imgHeight/2 )/imgHeight + 1 );

imgPtsX = uint16( meshgrid( (x_start_idx-1)*imgWidth+1:x_start_idx*imgWidth ) );
imgPtsY = uint16( meshgrid( (y_start_idx-1)*imgHeight+1:y_start_idx*imgHeight )' );
end

function [x_scan, y_scan] = image_center_to_scan_center( this, x_img, y_img, numX, numY )


pxSize = .108;

% imgWidth = this.CoreAPI.getImageWidth()*pxSize;
% imgHeight = this.CoreAPI.getImageHeight()*pxSize;
imgHeight = 1200*pxSize; imgWidth = 1200*pxSize;
totalWidth = numX*imgWidth;
totalHeight = numY*imgHeight;

x_scan = x_img*pxSize - totalWidth/2 + this.XYStageCtr(1);
y_scan = y_img*pxSize - totalHeight/2 + this.XYStageCtr(2);

end