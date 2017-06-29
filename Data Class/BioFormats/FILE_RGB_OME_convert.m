function fileImgOME = FILE_RGB_OME_convert(fileImg,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 17.10.2014

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'fileImg',@(x)exist(x,'file'))
addParamValue(ip,'objOmeTiffMeta',[],@(x)isobject(x))
addParamValue(ip,'objSrcMeta',[],@(x)(isobject(x) || iscell(x)))
addParamValue(ip,'verbose', false, @(x)islogical(x))
parse(ip,fileImg,varargin{:});

objOmeTiffMeta = ip.Results.objOmeTiffMeta;
objSrcMeta = ip.Results.objSrcMeta;
verbose = ip.Results.verbose;

%%
img4D = FILE_RGB_split(fileImg,varargin{:});
[imgHeight,imgWidth,numFrame,numChannel] = size(img4D);

%% fill metadata model of OME.TIFF
if isempty(objOmeTiffMeta)
    objOmeTiffMeta = classOmeTiffMetadata; %generate basic metadata structure
end %if

%set the dimension order of the file
set_dim_size(objOmeTiffMeta,imgWidth,imgHeight,1,numChannel,numFrame)

if not(isempty(objSrcMeta))
    set_image_file(objSrcMeta,fileImg)
    if isobject(objSrcMeta)
        set_general_meta(objOmeTiffMeta,objSrcMeta)
        for idxChannel = 1:numChannel
            set_channel_meta(objOmeTiffMeta,objSrcMeta,idxChannel)
        end %for
    elseif iscell(objSrcMeta) %multiple meta sources
        for idxSrc = 1:numel(objSrcMeta)
            set_general_meta(objOmeTiffMeta,objSrcMeta{idxSrc})
            for idxChannel = 1:numChannel
                set_channel_meta(objOmeTiffMeta,objSrcMeta{idxSrc},idxChannel)
            end %for
        end %for
    end %if
end %if

%% convert
[pathImgOME,nameImgOME] = fileparts(fileImg);
fileImgOME = fullfile(pathImgOME,[nameImgOME '.ome.tiff']);
fprintf('Prepare Output: %s:\n',fileImgOME)

objImgWriter = bfsave_initialize(fileImgOME,...
    get_meta_data(objOmeTiffMeta),varargin{:});
bio_formats_write(img4D,objImgWriter)
% bfsave(img4D,fileImgOME,'metadata',get_meta_data(objOmeTiffMeta))
end %fun