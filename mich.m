%function [peaks] = mich(imgray,i)
function mich (imgray,i)
imfilt = imgray;
filt5 = fspecial('gaussian', [5 5], .3);
for j = 1:5000 %number of low pass filter iterations
    imfilt = imfilter(imfilt, filt5, 'symmetric');%, 'replicate');
end

peaks = max(0,imgray-imfilt);
peaks = medfilt2(peaks,[3 3]);

imwrite(peaks, sprintf('michneg%d.tif',i));
figure, imshow(imfilt, []), figure, imshow(imgray-imfilt, []), figure, imshow(imgray, [])
figure, imshow(peaks, [])

grad = imgradient(peaks, 'prewitt');

figure, imshow(grad, [])
