%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

%modified 17.10.2014

[fileName,filePath] = uigetfile('*.vsi');
[filePath,fileName,fileExt] = fileparts(fullfile(filePath,fileName));
fileIn = fullfile(filePath,[fileName fileExt]);

%%
bfCheckJavaPath;
fprintf('Prepare Input: %s:\n',fileIn)
objImgReader = bfGetReader(fileIn);
numFrames = objImgReader.getImageCount();
imgWidth = getSizeX(objImgReader);
imgHeight = getSizeY(objImgReader);

%% METADATA
fprintf('Processing Metadata: %s:\n',strrep(fileIn,'vsi','txt'))
objMetaAscii = classCellSenseMetadata;
load_ascii(objMetaAscii,'fileIn',strrep(fileIn,'vsi','txt'))

if get_file_size(objMetaAscii) > 4 %[gigabyte]
    useBigTIFF = true;
else
    useBigTIFF = false;
end %if

set_laser_wavelength_index(objMetaAscii,640)

metadata = create_minimal_OME_XML_metadata(...
    [imgWidth,imgHeight,20,1,1],...
    'uint16', 'dimensionOrder', 'XYTZC');
metadata = add_user_specific_OME_XML_Metadata(metadata);
metadata = add_setup_specific_OME_XML_Metadata(metadata,objMetaAscii);
metadata = add_experiment_specific_OME_XML_Metadata(metadata);

%% TRANSLATE
fileOut = fullfile(filePath,[fileName '.ome.tiff']);
fprintf('Prepare Output: %s:\n',fileOut)

objImgWriter = bfsave_initialize(...
    fileOut,metadata,'BigTiff',useBigTIFF);
profile on
for idxFrame = 1:20
    bfsave_append_plane(objImgWriter,...
        bfGetPlane(objImgReader,idxFrame),idxFrame)
    
    fprintf('Processed %d/%d\n',idxFrame, numFrames);
end
close(objImgWriter)
profile viewer