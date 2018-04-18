function screenShot = get_screen_shot(ROI)
if nargin == 0 || isempty(ROI)
ROI = get(0,'ScreenSize');
end %if    

rect = java.awt.Rectangle(ROI(1), ROI(2), ROI(3), ROI(4));
robot = java.awt.Robot;
jImage = robot.createScreenCapture(rect);

h = jImage.getHeight;
w = jImage.getWidth;

pixelsData = reshape(typecast(jImage.getData.getDataStorage, 'uint8'), 4, w, h);
screenShot = cat(3, ...
    transpose(reshape(pixelsData(3, :, :), w, h)), ...
    transpose(reshape(pixelsData(2, :, :), w, h)), ...
    transpose(reshape(pixelsData(1, :, :), w, h)));
end %fun