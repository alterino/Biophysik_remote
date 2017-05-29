function [x, y] = getScreenLocations( n )
%getScreenLocations Returns screen pixel locations selected by user by taking a
%screenshot the size of the screen
%   n - number of points to select

screen_dims = get(0,'screensize');
% capture_fig = figure('Position', Pix_SS);
img = screencapture(0, 'Position', screen_dims);

h_fig = figure;
% warning('off')
figure(h_fig), imshow(img);
[x,y] = ginput(n);
x = round(x); y = round(y);
% x = screen_dims(3) - x + 1;
y = screen_dims(4) - y + 1; 


close(h_fig);


end

