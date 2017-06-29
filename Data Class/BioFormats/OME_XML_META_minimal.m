function metadata = OME_XML_META_minimal(imgSize, imgType, varargin)
%written by
%C.P.Richter
%Division of Biophysics / Group J.Piehler
%University of Osnabrueck

ip = inputParser;
addRequired(ip,'imgSize');
addRequired(ip,'imgType');
addOptional(ip,'dimensionOrder', 'XYTCZ', @(x) ismember(x, getDimensionOrders()));
ip.parse(imgSize,imgType,varargin{:});
input = ip.Results;

imageIndex = 0;

%%
toInt = @(x) javaObject('ome.xml.model.primitives.PositiveInteger', ...
    javaObject('java.lang.Integer', x));
OMEXMLService = javaObject('loci.formats.services.OMEXMLServiceImpl');
metadata = OMEXMLService.createOMEXMLMetadata();
metadata.createRoot();
metadata.setImageID('Image:0', imageIndex);
metadata.setPixelsID('Pixels:0', imageIndex);
metadata.setPixelsBinDataBigEndian(java.lang.Boolean.TRUE, imageIndex, 0);

% Set dimension order
dimensionOrderEnumHandler = javaObject('ome.xml.model.enums.handlers.DimensionOrderEnumHandler');
dimensionOrder = dimensionOrderEnumHandler.getEnumeration(input.dimensionOrder);
metadata.setPixelsDimensionOrder(dimensionOrder, imageIndex);

pixelTypeEnumHandler = javaObject('ome.xml.model.enums.handlers.PixelTypeEnumHandler');
if strcmp(imgType, 'single')
    pixelsType = pixelTypeEnumHandler.getEnumeration('float');
else
    pixelsType = pixelTypeEnumHandler.getEnumeration(imgType);
end
metadata.setPixelsType(pixelsType, imageIndex);

sizeZ = imgSize(input.dimensionOrder == 'Z');
sizeC = imgSize(input.dimensionOrder == 'C');
sizeT = imgSize(input.dimensionOrder == 'T');

metadata.setPixelsSizeX(toInt(imgSize(1)), imageIndex);
metadata.setPixelsSizeY(toInt(imgSize(2)), imageIndex);
metadata.setPixelsSizeZ(toInt(sizeZ), imageIndex);
metadata.setPixelsSizeC(toInt(sizeC), imageIndex);
metadata.setPixelsSizeT(toInt(sizeT), imageIndex);

% Set channels ID and samples per pixel
for i = 1: sizeC
    metadata.setChannelID(['Channel:0:' num2str(i-1)], imageIndex, i-1);
    metadata.setChannelSamplesPerPixel(toInt(1), imageIndex, i-1);
end
end %fun

function dimensionOrders = getDimensionOrders()
% List all values of DimensionOrder
dimensionOrderValues = javaMethod('values', 'ome.xml.model.enums.DimensionOrder');
dimensionOrders = cell(numel(dimensionOrderValues), 1);
for i = 1 :numel(dimensionOrderValues),
    dimensionOrders{i} = char(dimensionOrderValues(i).toString());
end
end