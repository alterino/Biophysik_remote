im = imread('T:\Marino\Microscopy\161027 - DIC Toydata\160308\Sample3\DIC_160308_2033.tif');
figure;imagesc(im);colormap(gray)

%% Search for texture in the image
imEnt = entropyfilt(im, ones(9,9));
figure;imagesc(imEnt),colormap(gray)

%% Smooth it out a little
se = strel('disk',9);
entSmooth = imclose(imEnt, se);
figure;imagesc(entSmooth),colormap(gray)

%% find 3 levels in the smoothed image
% I sped it up some by only passing in every 20th pixel, that's a viable
% option here, but if you have less structure in the images, I'd instead
% train the gmm on a subregion of interest in the image
tic();
skipSize = 30;
linearIm = entSmooth(:);
gmm = fitgmdist(linearIm(1:skipSize:end), 3, 'replicates',3);
idx = reshape(cluster(gmm, entSmooth(:)), size(entSmooth));
toc();

% Order the clustering so that the indices are from min to max cluster mean
[~,sortIdx] = sort(gmm.mu);
newIdx = sortIdx(idx);

figure;imagesc(newIdx)


%% This is some cleanup shenanigans
% Put all the small blobs with high intensity in the middle component
% instead, that way if they aren't part of something bigger, they disappear
bwInterior = (newIdx == 3);
cc = bwconncomp(bwInterior);

sizeThresh = 10000;
bSmall = cellfun(@(x)(length(x) < sizeThresh), cc.PixelIdxList);

newIdx(vertcat(cc.PixelIdxList{bSmall})) = 2;

%% A distance transform on the highest component (we'll use it for region growing)
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


%% Plot the results on top of the original image
lcm = jet(20);

figure;imagesc(im);colormap(gray);
hold on;

labels = unique(finalLabelIm(finalLabelIm>0));
for i=1:length(labels)
    bwC = false(size(finalLabelIm));
    bwC(finalLabelIm == labels(i)) = true;

    colorIdx = mod(i-1,20)+1;
    
    [B,L] = bwboundaries(bwC,'noholes');
    for k = 1:length(B)
       plot(B{k}(:,2), B{k}(:,1), '-', 'Color', lcm(colorIdx,:));
    end
end
hold off

