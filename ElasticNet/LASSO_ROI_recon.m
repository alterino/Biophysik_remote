function [imgRecon,alpha,numRegion,infoRegionRecon] = ...
    LASSO_ROI_recon(img,psfStd,varargin)
objParser = inputParser;
objParser.KeepUnmatched = true;
addRequired(objParser,'img',@ismatrix)
addRequired(objParser,'psfStd',@(x)isscalar(x) && x > 0)
addParamValue(objParser,'mask',[],@ismatrix);
addParamValue(objParser,'facUpSamp',10,@(x)isscalar(x) && x > 0 && rem(x,1) == 0);
parse(objParser,img,psfStd,varargin{:});
input = objParser.Results;

%%
[imgHeight,imgWidth] = size(img);
if isempty(input.mask) %take whole image as input
    input.mask = ones(imgHeight,imgWidth);
end %if

%%
if any(input.mask(:)) %make sure there are regions of interest
    infoRegion = label(input.mask,8); %
    infoRegionRecon = nn_upsample(infoRegion,input.facUpSamp);
    imgRecon = zeros(size(infoRegionRecon));
    numRegion = numel(unique(infoRegion(:)))-1;
    for idxRegion = numRegion:-1:1;
        [i,j] = find(infoRegion == idxRegion);
        coordsRegion(idxRegion).PixelList = [j,i];
        coordsRegion(idxRegion).BoundingBox = [min([j,i]),max([j,i])-min([j,i])+1];
        
        % requieres image processing toolbox
        % infoRegion = bwconncomp(input.mask);
        % coordsRegion = regionprops(infoRegion,{'BoundingBox','PixelList'});
        % numRegion = numel(coordsRegion);
        
        [i,j] = find(infoRegionRecon == idxRegion);
        coordsRegionRecon(idxRegion).PixelIdxList = sub2ind(size(infoRegionRecon),i,j);
        
        % requieres image processing toolbox
        % maskRecon = imresize(input.mask,input.facUpSamp,'nearest');
        % infoRegionRecon = bwconncomp(maskRecon);
        % coordsRegionRecon = regionprops(infoRegionRecon,'PixelIdxList');
        % imgRecon = zeros(size(maskRecon));
        
        % for idxRegion = numRegion:-1:1;
        %     fprintf('Processing: %d/%d\n',idxRegion, numRegion);
        
        %% make regions quadratic (req for the LASSO algorithm)
        i0_ = coordsRegion(idxRegion).BoundingBox(2);
        roiHeight_ = coordsRegion(idxRegion).BoundingBox(4);
        j0_ = coordsRegion(idxRegion).BoundingBox(1);
        roiWidth_ = coordsRegion(idxRegion).BoundingBox(3);
        if roiHeight_ < roiWidth_
            appendSize = (roiWidth_-roiHeight_);
            if i0_ + roiHeight_ + appendSize - 1 <= imgHeight
                appendSide = 'lower';
                i0 = i0_;
                j0 = j0_;
                roiHeight = roiHeight_ + appendSize;
                roiWidth = roiWidth_;
            else
                if i0_ - appendSize >= 1
                    appendSide = 'upper';
                    i0 = i0_ - appendSize;
                    j0 = j0_;
                    roiHeight = roiHeight_ + appendSize;
                    roiWidth = roiWidth_;
                else
                    appendSide = 'upperlower';
                    appendUpper = i0_ + roiHeight_ + appendSize - 1 - imgHeight;
                    
                    i0 = i0_ - appendUpper;
                    j0 = j0_;
                    roiHeight = roiHeight_ + appendSize;
                    roiWidth = roiWidth_;
                    %skip temporary
                    %can only occur if the image is not square
                end %if
            end %if
        elseif roiWidth_ < roiHeight_
            appendSize = (roiHeight_-roiWidth_);
            if j0_ + roiWidth_ + appendSize - 1 <= imgWidth
                appendSide = 'right';
                i0 = i0_;
                j0 = j0_;
                roiHeight = roiHeight_;
                roiWidth = roiWidth_ + appendSize;
            else
                if j0_ - appendSize >= 1
                    appendSide = 'left';
                    i0 = i0_;
                    j0 = j0_ - appendSize;
                    roiHeight = roiHeight_;
                    roiWidth = roiWidth_ + appendSize;
                else
                    appendSide = 'leftright';
                    appendLeft = j0_ + roiWidth_ + appendSize - 1 - imgWidth;
                    
                    i0 = i0_;
                    j0 = j0_ - appendLeft;
                    roiHeight = roiHeight_;
                    roiWidth = roiWidth_ + appendSize;
                    %skip temporary
                    %can only occur if the image is not square
                end %if
            end %if
        elseif roiWidth_ == roiHeight_
            appendSide = 'none';
            i0 = i0_;
            j0 = j0_;
            roiHeight = roiHeight_;
            roiWidth = roiWidth_;
        end %if
        
        %% extract subregion
        imgRoi = img(i0:i0+roiHeight-1,...
            j0:j0+roiWidth-1);
        binaryRoiRecon = false([roiHeight roiWidth]);
        binaryRoiRecon(sub2ind([roiHeight roiWidth],...
            coordsRegion(idxRegion).PixelList(:,2)-i0+1,...
            coordsRegion(idxRegion).PixelList(:,1)-j0+1)) = 1;
        %upsample subregion mask
        binaryRoiRecon = nn_upsample(binaryRoiRecon,input.facUpSamp);
        %     binaryRoiRecon = imresize(binaryRoiRecon,input.facUpSamp,'nearest');
        
        %% LASSO reconstruction
        [K2,K2T] = kernel_wrapper(roiHeight,psfStd,varargin{:});
        [imgRoiRecon,alpha(idxRegion)] = LASSO_image_recon_auto_regul(imgRoi,K2,K2T,varargin{:});
        
        %% in case: crop quadratic ROI before output to the reconstruction
        switch appendSide
            case 'upper'
                imgRoiRecon = imgRoiRecon(input.facUpSamp*appendSize+1:end,:);
                binaryRoiRecon = binaryRoiRecon(input.facUpSamp*appendSize+1:end,:);
            case 'lower'
                imgRoiRecon = imgRoiRecon(1:end-input.facUpSamp*appendSize,:);
                binaryRoiRecon = binaryRoiRecon(1:end-input.facUpSamp*appendSize,:);
            case 'upperlower'
                imgRoiRecon = imgRoiRecon(input.facUpSamp*appendUpper+1:end-input.facUpSamp*(appendSize-appendUpper),:);
                binaryRoiRecon = binaryRoiRecon(input.facUpSamp*appendUpper+1:end-input.facUpSamp*(appendSize-appendUpper),:);
            case 'left'
                imgRoiRecon = imgRoiRecon(:,input.facUpSamp*appendSize+1:end);
                binaryRoiRecon = binaryRoiRecon(:,input.facUpSamp*appendSize+1:end);
            case 'right'
                imgRoiRecon = imgRoiRecon(:,1:end-input.facUpSamp*appendSize);
                binaryRoiRecon = binaryRoiRecon(:,1:end-input.facUpSamp*appendSize);
            case 'leftright'
                imgRoiRecon = imgRoiRecon(:,input.facUpSamp*appendLeft+1:end-input.facUpSamp*(appendSize-appendLeft));
                binaryRoiRecon = binaryRoiRecon(:,input.facUpSamp*appendLeft+1:end-input.facUpSamp*(appendSize-appendLeft));
            case 'none'
        end %switch
        
        imgRecon(coordsRegionRecon(idxRegion).PixelIdxList) = imgRoiRecon(binaryRoiRecon);
    end %for
    % make the output sparse (saves a lot of space because the output is mostly zeros)
    imgRecon = sparse(imgRecon/input.facUpSamp^2);
else %no regions of interest present
    alpha = nan;
    imgRecon = [];
end %if
end %fun