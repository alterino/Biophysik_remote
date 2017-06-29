function bio_formats_write(img4D,writer)
% Load conversion tools for saving planes
switch class(img4D)
    case {'int8', 'uint8'}
        getBytes = @(x) x(:);
    case {'uint16','int16'}
        getBytes = @(x) javaMethod('shortsToBytes', 'loci.common.DataTools', x(:), 0);
    case {'uint32','int32'}
        getBytes = @(x) javaMethod('intsToBytes', 'loci.common.DataTools', x(:), 0);
    case {'single'}
        getBytes = @(x) javaMethod('floatsToBytes', 'loci.common.DataTools', x(:), 0);
    case 'double'
        getBytes = @(x) javaMethod('doublesToBytes', 'loci.common.DataTools', x(:), 0);
end

% Save planes to the writer
reverseStr = '';

zctCoord = [size(img4D, 3) size(img4D, 4) 1];
for index = 1 : prod(zctCoord)
    [idxT, idxC, idxZ] = ind2sub(zctCoord, index);
    plane = img4D(:,:,idxT,idxC,idxZ)';
    writer.saveBytes(index-1, getBytes(plane));
    
    msg = sprintf('T: %d/%d\nC: %d/%d\nZ: %d/%d\n',...
        idxT,zctCoord(1),idxC,zctCoord(2),idxZ,zctCoord(3));
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
writer.close();