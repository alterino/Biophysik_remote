clearvars -except testIMG

% lab path
imgPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif';
outPATH = 'T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\Processed\';

% home path
% imgPATH = 'D:\OS_Biophysik\DIC_images\DIC_160308_2033.tif';
% outPATH = 'D:\OS_Biophysik\Processed\';

if( ~exist( 'testIMG' ) )
    testIMG = imread(imgPATH);
end

figure(1);imagesc(testIMG);colormap(gray)

dims = size(testIMG);

numCols = dims(2)/600;
numRows = dims(1)/600;
imgStack = uint16(zeros(600, 600, numCols*numRows));

segManager = classSegmentationManager;

% breaking up larger image
tempIDX = 0;
for i=1:numCols
    for j=1:numRows
        tempIDX = tempIDX + 1;
        imgStack( :,:, tempIDX ) =...
            uint16( testIMG( 600*(i-1)+1:600*i, 600*(j-1)+1:600*j ) );
    end
end
clear tempIDX
imgCount = size(imgStack, 3);
imEnt = zeros( size( imgStack ) );

for i = 1:imgCount
    
    im = imgStack(:,:,i);
    
    % Search for texture in the image
    imEnt(:,:,i) = entropyfilt(im, ones(9,9));
end

imEnt = img_stack_to_img_2D( imEnt, [15 15] );

% Smooth it out a little
se = strel('disk',9);
entSmooth = imclose(imEnt, se);
figure(3);imagesc(entSmooth);colormap(gray)

% find 3 levels in the smoothed image
% I sped it up some by only passing in every 30th pixel
tic();
skipSize = 30;
linearIm = entSmooth(:);
options = statset( 'MaxIter', 200 );
gmm = fitgmdist(linearIm(1:skipSize:end), 3, 'replicates',3, 'Options', options);
idx = reshape(cluster(gmm, entSmooth(:)), size(entSmooth));
toc();

% Order the clustering so that the indices are from min to max cluster mean
[~,sortIdx] = sort(gmm.mu);
newIdx = sortIdx(idx);

figure(4);imagesc(newIdx)

% This is some cleanup shenanigans
% Put all the small blobs with high intensity in the middle component
% instead, that way if they aren't part of something bigger, they disappear
bwInterior = (newIdx == 3);
% We can use the distance transform to assing all "level-2" pixels to their nearest
% "level-3", we'll do this per connected component so they are connected
labelIm = bwlabel(bwInterior);
[~,backIdx] = bwdist(bwInterior);

finalLabelIm = labelIm;

cc = bwconncomp(newIdx > 1);
for i=1:cc.NumObjects
    labels = labelIm(cc.PixelIdxList{i});
    labels = labels(labels > 0);
    
    if ( isempty(labels) )
        continue;
    end
    
    closestIdx = backIdx(cc.PixelIdxList{i});
    assignLabel = labelIm(closestIdx);
    
    finalLabelIm(cc.PixelIdxList{i}) = assignLabel;
end

% Plot the results on top of the original image
lcm = jet(20);

figure;imagesc(im);colormap(gray);
hold on;

labels = unique(finalLabelIm(finalLabelIm>0));
tic
for i=1:length(labels)
    bwC = false(size(finalLabelIm));
    bwC(finalLabelIm == labels(i)) = true;

    colorIdx = mod(i-1,20)+1;
    
    [B,L] = bwboundaries(bwC,'noholes');
    for k = 1:length(B)
       plot(B{k}(:,2), B{k}(:,1), '-', 'Color', lcm(colorIdx,:));
    end
    
    fprintf( 'completed label %i of %i, t=%.2f\n', i, length(labels), toc);
end
hold off

