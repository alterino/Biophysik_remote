function metadata = create_minimal_OME_XML_metadata(imgSize, imgType, varargin)
% Input check
ip = inputParser;
addRequired(ip,'imgSize');
addRequired(ip,'imgType');
addOptional(ip,'dimensionOrder', 'XYZCT', @(x) ismember(x, getDimensionOrders()));
ip.parse(imgSize,imgType,varargin{:});
input = ip.Results;

toInt = @(x) javaObject('ome.xml.model.primitives.PositiveInteger', ...
                        javaObject('java.lang.Integer', x));
OMEXMLService = javaObject('loci.formats.services.OMEXMLServiceImpl');
metadata = OMEXMLService.createOMEXMLMetadata();
metadata.createRoot();
metadata.setImageID('Image:0', 0);
metadata.setPixelsID('Pixels:0', 0);
metadata.setPixelsBinDataBigEndian(java.lang.Boolean.TRUE, 0, 0);

% Set dimension order
dimensionOrderEnumHandler = javaObject('ome.xml.model.enums.handlers.DimensionOrderEnumHandler');
dimensionOrder = dimensionOrderEnumHandler.getEnumeration(input.dimensionOrder);
metadata.setPixelsDimensionOrder(dimensionOrder, 0);

pixelTypeEnumHandler = javaObject('ome.xml.model.enums.handlers.PixelTypeEnumHandler');
if strcmp(imgType, 'single')
    pixelsType = pixelTypeEnumHandler.getEnumeration('float');
else
    pixelsType = pixelTypeEnumHandler.getEnumeration(imgType);
end
metadata.setPixelsType(pixelsType, 0);

sizeZ = imgSize(input.dimensionOrder == 'Z');
sizeC = imgSize(input.dimensionOrder == 'C');
sizeT = imgSize(input.dimensionOrder == 'T');

metadata.setPixelsSizeX(toInt(imgSize(1)), 0);
metadata.setPixelsSizeY(toInt(imgSize(2)), 0);
metadata.setPixelsSizeZ(toInt(sizeZ), 0);
metadata.setPixelsSizeC(toInt(sizeC), 0);
metadata.setPixelsSizeT(toInt(sizeT), 0);

% Set channels ID and samples per pixel
for i = 1: sizeC
    metadata.setChannelID(['Channel:0:' num2str(i-1)], 0, i-1);
    metadata.setChannelSamplesPerPixel(toInt(1), 0, i-1);
end
end %fun

function dimensionOrders = getDimensionOrders()

% List all values of DimensionOrder
dimensionOrderValues = javaMethod('values', 'ome.xml.model.enums.DimensionOrder');
dimensionOrders = cell(numel(dimensionOrderValues), 1);
for i = 1 :numel(dimensionOrderValues)
    dimensionOrders{i} = char(dimensionOrderValues(i).toString());
end
end