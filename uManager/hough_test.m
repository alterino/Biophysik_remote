allfiles = dir('T:\Marino\Microscopy\Raw Images for Michael\compiled\*.tif');
filenames = {allfiles.name};

for i=1:numel(filenames)


    I = imread(filenames{i});
    rot = I;
    rotI = imadjust(rot);

    BW = edge(rotI,'canny');
    figure, imshow(BW);
    [H,T,R] = hough(BW);
    P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    x = T(P(:,2)); y = R(P(:,1));
    % Find lines and plot them
    lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
    figure, imshow(rotI), hold on
    max_len = 0;
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
    
    pause, close all

end