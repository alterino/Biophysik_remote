function objImgWriter = bfsave_initialize(outputPath,metadata,varargin)
bfCheckJavaMemory();

% Check for required jars in the Java path
bfCheckJavaPath();

% Input check
ip = inputParser;
ip.KeepUnmatched = true;
ip.addRequired('outputPath', @ischar);
ip.addRequired('metadata', @(x) isa(x, 'loci.formats.ome.OMEXMLMetadata'));
ip.addParamValue('Compression', '',  @(x) ismember(x, getCompressionTypes()));
ip.addParamValue('BigTiff', false , @islogical);
ip.parse(outputPath, metadata, varargin{:});
input = ip.Results;

% Create ImageobjImgWriter
objImgWriter = javaObject('loci.formats.ImageWriter');
objImgWriter.setWriteSequentially(true);
objImgWriter.setMetadataRetrieve(input.metadata);
if ~isempty(input.Compression)
    objImgWriter.setCompression(input.Compression)
end
if input.BigTiff
    objImgWriter.getWriter(outputPath).setBigTiff(input.BigTiff)
end
objImgWriter.setId(outputPath);
end %fun

function compressionTypes = getCompressionTypes()

% List all values of Compression
objImgWriter = loci.formats.ImageobjImgWriter();
compressionTypes = arrayfun(@char, objImgWriter.getCompressionTypes(),...
    'UniformOutput', false);
end