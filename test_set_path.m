
function [x,y,bad] = test_set_path(pxSize,numX,numY,stage_center, img_dims)
%calculate stepsize to produce no overlap
% pxSize = get_img_px_size(this); %[µm]
imgWidth = img_dims(2)*pxSize;
imgHeight = img_dims(1)*pxSize;

totalHeight = numY*imgHeight;
totalWidth = numX*imgWidth;

[X,Y] = meshgrid(...
    (-totalWidth/2+imgWidth/2:imgWidth:totalWidth/2-imgWidth/2)+stage_center(1),...
    (-totalHeight/2+imgHeight/2:imgHeight:totalHeight/2-imgHeight/2)+stage_center(2));
Y(:,2:2:end) = flipud(Y(:,2:2:end));
x = X(:);
y = Y(:);

%check that the stage does not leave the safety region
dr = sqrt((X-stage_center(1)).^2+(Y-stage_center(2)).^2);
bad = (dr > 1250);
x(bad) = [];
y(bad) = [];
end %fun