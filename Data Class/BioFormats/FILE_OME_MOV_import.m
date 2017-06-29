function [img5D,objImgReader,fileImg] = FILE_OME_MOV_import(fileImg,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 21.10.2015: added loadFOI, loadCOI & appropriate adressing into 5D-OME-TIFF files

bfCheckJavaPath;

if nargin == 0
    [fileName,filePath] = uigetfile(bfGetFileExtensions);
    fileImg = fullfile(filePath,fileName);
    
    objImgReader = [];
    loadROI = [];
    loadFOI = [];
    loadCOI = [];
    loadTOI = [];
    
    verbose = true;
else
    ip = inputParser;
    ip.KeepUnmatched = true;
    addRequired(ip,'fileImg',@(x)exist(x,'file'))
    addParamValue(ip,'ObjImgReader', [])
    addParamValue(ip,'LoadROI', [], @(x) (isvector(x) & numel(x) == 4) | isempty(x)) %region of interest [x0 y0 w h]
    addParamValue(ip,'LoadFOI', []) %focal plane of interest
    addParamValue(ip,'LoadCOI', []) %color/channel of interest
    addParamValue(ip,'LoadTOI', []) %time of interest
    addParamValue(ip,'verbose', true, @(x) isscalar(x) & (islogical(x) | (x == 0 | x == 1)))
    parse(ip,fileImg,varargin{:});
    
    objImgReader = ip.Results.ObjImgReader;
    loadROI = ip.Results.LoadROI;
    loadFOI = ip.Results.LoadFOI;
    loadCOI = ip.Results.LoadCOI;
    loadTOI = ip.Results.LoadTOI;
    verbose = ip.Results.verbose;
end %if

fprintf('\nLoading Image: %s:\n',fileImg)

%%
if isempty(objImgReader)
    objImgReader = bfGetReader(fileImg);
end %if

%%
if isempty(loadROI) %if no ROI is specified -> take the whole x-y-plane
%     if useImplicitROI
%         objOmeTiffMeta = classOmeTiffMetadata(objImgReader);
%         [roiVertX,roiVertY] = get_ROI(objOmeTiffMeta);
%         
%     else
    loadROI = [1 1 getSizeX(objImgReader) getSizeY(objImgReader)];
%     end %if
else %check validity of the requested region
    
end %if

%%
if isempty(loadTOI) %if no TOI is specified -> take the whole time-series
    numFrame = getSizeT(objImgReader);
    loadTOI = 1:numFrame;
else %check validity of the requested region
    numFrame = numel(loadTOI);
    if min(loadTOI) < 1 || max(loadTOI) > getSizeT(objImgReader) %error
        fprintf('Error: Framerange not available.\n')
        [img5D,objImgReader,fileImg] = deal([]);
        return
    end %if
end %if

%%
if isempty(loadCOI)
    numChannel = getSizeC(objImgReader);
    loadCOI = 1:numChannel;
else %check validity of the requested region
    lastChannel = getSizeC(objImgReader);
    numChannel = numel(loadCOI);
    if min(loadCOI) < 1 || max(loadCOI) > lastChannel %error
        fprintf('Error: Channelrange not available.\n')
        [img5D,objImgReader,fileImg] = deal([]);
        return
    end %if
end %if

%%
if isempty(loadFOI)
    numFocii = getSizeZ(objImgReader);
    loadFOI = 1:numFocii;
else %check validity of the requested region
    numFocii = numel(loadFOI);
end %if

%% allocate space to hold image
switch getBitsPerPixel(objImgReader);
    case 8
        imgType = 'uint8';
    case 16
        imgType = 'uint16';
    case 32
        imgType = 'uint32';
    case 64
        imgType = 'uint64';
end %switch

%% predict memory consumption
memImg5D = IMG_mem_size(loadROI(4),loadROI(3),imgType,...
    'numFrame',numFrame,'imgDepth',numFocii,'numChannel',numChannel)*1e-9; %[gb]
if memImg5D > 14
    fprintf('Image requieres to much memory: >%dGB\n',14)
    [img5D,objImgReader,fileImg] = deal([]);
    return
end %if

%% image reading
img5D = zeros(loadROI(4),loadROI(3),numFrame,numChannel,numFocii,imgType);

reverseStr = '';
for idxZ = 1:numFocii
    for idxC = 1:numChannel
        for idxT = 1:numFrame
            %load from file
            img5D(:,:,idxT,idxC,idxZ) = ...
                bfGetPlane(objImgReader,getIndex(objImgReader,...
                loadFOI(idxZ)-1,loadCOI(idxC)-1,loadTOI(idxT)-1)+1,...
                loadROI(1),loadROI(2),loadROI(3),loadROI(4));
            
            msg = sprintf('T: %d/%d\nC: %d/%d\nZ: %d/%d\n',...
                idxT,numFrame,idxC,numChannel,idxZ,numFocii);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end %for
    end %for
end %for
fprintf('\n')
end %fun