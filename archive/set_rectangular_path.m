function [x,y,bad] = set_rectangular_path(this,numX,numY)
%calculate stepsize to produce no overlap
%             pxSize = get_img_px_size(this); %[µm]
pxSize = .108; %[µm]
%             imgWidth = this.CoreAPI.getImageWidth()*pxSize;
%             imgHeight = this.CoreAPI.getImageHeight()*pxSize;
imgWidth = 1200*pxSize; imgHeight = 1200*pxSize;

totalHeight = numY*imgHeight;
totalWidth = numX*imgWidth;

[X,Y] = meshgrid(...
    (-totalWidth/2+imgWidth/2:imgWidth:totalWidth/2-imgWidth/2)+this.XYStageCtr(1),...
    (-totalHeight/2+imgHeight/2:imgHeight:totalHeight/2-imgHeight/2)+this.XYStageCtr(2));
Y(:,2:2:end) = flipud(Y(:,2:2:end));

imgWidth = 1200; imgHeight = 1200;
% testX = uint16( ( ( X - this.XYStageCtr(1) + totalWidth/2)/pxSize - imgWidth/2 )/imgWidth + 1 );
% testY = uint16( ( (Y - this.XYStageCtr(2) + totalHeight/2)/pxSize - imgHeight/2 )/imgHeight + 1 ) ;

[testX, testY] = scan_center_to_img_idx( this, X(1,3), Y(2,1), numX, numY );

x_img = max( max( double(testX) ) ) - imgWidth/2; y_img = max( max( double(testY) ) ) - imgHeight/2;

[x_scan, y_scan] = image_center_to_scan_center( this, x_img, y_img, numX, numY );

x = X(:);
y = Y(:);

%check that the stage does not leave the safety region
dr = sqrt((X-this.XYStageCtr(1)).^2+(Y-this.XYStageCtr(2)).^2);
bad = (dr > this.XYStageMaxRadius);
x(bad) = [];
y(bad) = [];
end %fun

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