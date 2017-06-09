function [x, y] = getScreenLocations(n)
%getScreenLocations Returns screen pixel locations selected by user by taking a
%screenshot the size of the screen
%   n - number of points to select

if(~exist('n','var'))
    n=1;
end

orig_state = warning;
screen_dims = get(0,'screensize');
img = screencapture(0, 'Position', screen_dims);

h_fig = figure;
warning('off');
figure(h_fig), imshow(img);
set(h_fig, 'units', 'normalized', 'outerposition', [0 0 1 1]);
set(gca,'units','normalized','position',[0 0 1 1])
[x,y] = ginput(n);
x = round(x); y = round(y);
y = screen_dims(4) - y + 1; 

close(h_fig);
warning(orig_state)

end