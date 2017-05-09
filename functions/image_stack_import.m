function [imgStack,objImgReader,fileIn] = image_stack_import(fileIn,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 07.10.2014
%modified 24.11.2014
%modified 20.05.2015: adds support for ROI

bfCheckJavaPath;

if nargin == 0
    [fileName,filePath] = uigetfile(bfGetFileExtensions);
    fileIn = fullfile(filePath,fileName);
    
    objImgReader = [];
    TOI = [];
    ROI = [];
    verbose = true;
else
    ip = inputParser;
    ip.KeepUnmatched = true;
    addParamValue(ip,'ObjImgReader', [])
    addParamValue(ip,'FrameRange', [], @(x) isrow(x) | isempty(x))
    addParamValue(ip,'ROI', [], @(x) (isvector(x) & numel(x) == 4) | isempty(x))
    addParamValue(ip,'verbose', true, @(x) isscalar(x) & (islogical(x) | (x == 0 | x == 1)))
    parse(ip,varargin{:});
    
    TOI = ip.Results.FrameRange;
    objImgReader = ip.Results.ObjImgReader;
    ROI = ip.Results.ROI;
    verbose = ip.Results.verbose;
end %if

%%
fprintf('Prepare Input: %s:\n',fileIn)

if isempty(objImgReader)
    objImgReader = bfGetReader(fileIn,0);
end %if

if isempty(TOI)
    numFrame = objImgReader.getImageCount();
    TOI = 1:numFrame;
else
    lastFrame = objImgReader.getImageCount();
    numFrame = numel(TOI);
    if min(TOI) < 1 || max(TOI) > lastFrame %error
        fprintf('Error: Framerange not available.\n')
        imgStack = [];
        return
    end %if
end %if

if isempty(ROI)
    ROI = [1 1 objImgReader.getSizeX() objImgReader.getSizeY()];
end %if

%% allocate space to hold image
switch objImgReader.getBitsPerPixel();
    case 8
        imgType = 'uint8';
    case 16
        imgType = 'uint16';
    case 32
        imgType = 'uint32';
    case 64
        imgType = 'uint64';
end %switch
imgStack = zeros(ROI(4),ROI(3),numFrame,imgType);

%% image reading
reverseStr = '';
for idxFrame = 1:numel(TOI)
    imgStack(:,:,idxFrame) = bfGetPlane(objImgReader,TOI(idxFrame),ROI(1),ROI(2),ROI(3),ROI(4));
    
    if verbose
        msg = sprintf('Processed %d/%d',idxFrame, numFrame);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end %if
end
fprintf('\n')
end