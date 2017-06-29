function metadata = initialize_CellSense_OME_XML_Metadata(objImgReader)
metaCore = toArray(getCoreMetadataList(objImgReader));
metaCore = metaCore(1);

OMEXMLService = loci.formats.services.OMEXMLServiceImpl();
metadata = OMEXMLService.createOMEXMLMetadata();
metadata.createRoot();
metadata.setImageID('Image:0', 0);
metadata.setPixelsID('Pixels:0', 0);
metadata.setPixelsBinDataBigEndian(java.lang.Boolean.TRUE, 0, 0);

% Set dimension order
dimensionOrderEnumHandler = ome.xml.model.enums.handlers.DimensionOrderEnumHandler();
dimensionOrder = dimensionOrderEnumHandler.getEnumeration(metaCore.dimensionOrder);
metadata.setPixelsDimensionOrder(dimensionOrder, 0);

pixelTypeEnumHandler = ome.xml.model.enums.handlers.PixelTypeEnumHandler();
pixelsType = pixelTypeEnumHandler.setEnumeration('uint16');
metadata.setPixelsType(pixelsType, 0);

toInt = @(x) ome.xml.model.primitives.PositiveInteger(java.lang.Integer(x));
metadata.setPixelsSizeX(toInt(metaCore.sizeX), 0);
metadata.setPixelsSizeY(toInt(metaCore.sizeY), 0);
metadata.setPixelsSizeZ(toInt(metaCore.sizeZ), 0);
metadata.setPixelsSizeC(toInt(metaCore.sizeC), 0);
metadata.setPixelsSizeT(toInt(metaCore.sizeT), 0);

% Set channels ID and samples per pixel
for i = 1: sizeC
    metadata.setChannelID(['Channel:0:' num2str(i-1)], 0, i-1);
    metadata.setChannelSamplesPerPixel(toInt(1), 0, i-1);
end
end %fun