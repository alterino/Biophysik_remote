function [x_scan, y_scan] = image_center_to_scan_center( x_img, y_img, numX, numY, pxSize, img_dims, stage_center )

% need to get pxSize here
% pxSize = 1;

% imgWidth = this.CoreAPI.getImageWidth()*pxSize;
% imgHeight = this.CoreAPI.getImageHeight()*pxSize;
imgHeight = img_dims(1)*pxSize; imgWidth = img_dims(2)*pxSize;
totalWidth = numX*imgWidth;
totalHeight = numY*imgHeight;

x_scan = x_img*pxSize - totalWidth/2 + stage_center(1);
y_scan = y_img*pxSize - totalHeight/2 + stage_center(2);

end