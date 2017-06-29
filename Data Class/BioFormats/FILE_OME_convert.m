function FILE_OME_convert(fileImg,varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 17.10.2014

ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip,'fileImg',@(x)exist(x,'file'))
addParamValue(ip,'objOmeTiffMeta',[],@(x)isobject(x))
addParamValue(ip,'verbose', false, @(x)islogical(x))
parse(ip,fileImg,varargin{:});

objOmeTiffMeta = ip.Results.objOmeTiffMeta;
verbose = ip.Results.verbose;

%%
[pathImgOME,nameImgOME,formatImg] = fileparts(fileImg);

%% fill metadata model of OME.TIFF
if isempty(objOmeTiffMeta)
    objOmeTiffMeta = classOmeTiffMetadata;
end %if

%% load imagestack into memory
imgStack = FILE_MOV_import(fileImg,varargin{:});

[imgHeight,imgWidth,numFrame] = size(imgStack);
set_dim_size(objOmeTiffMeta,imgWidth,imgHeight,1,1,numFrame)

% retrieve meta information

%     if strcmp(formatImg,'.vsi')
%         if exist(strrep(fileImg,'.vsi','.txt'),'file')
%             
%             [~,objMetaSrc] = FILE_META_cellsense_vsi(fileImg);
%         end %if
%     end %if
% end %if
% metadata = add_user_specific_OME_XML_Metadata(metadata,varargin{:});
% metadata = add_setup_specific_OME_XML_Metadata(metadata,objMetaSrc,varargin{:});

%% convert to OME.TIFF
fileImgOME = fullfile(pathImgOME,[nameImgOME '.ome.tiff']);
fprintf('Prepare Output: %s:\n',fileImgOME)

bfsave(imgStack,fileImgOME,'metadata',get_meta_data(objOmeTiffMeta));
end %fun