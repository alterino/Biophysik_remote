function metadata = meta_2_oem_xml( filename, old_metadata )
%META_2_OEM_XML Summary of this function goes here
%   Detailed explanation goes here

if( ~isempty( old_metadata ) )
    metadata = old_metadata;
    metadata.setExperimenterGroupLeader('J.Piehler', 0, 0);
    metadata.setExperimenterGroupName('Universitaet Osnabrueck Department of Biophysics', 0); 
else
    metadata = initialize_metadata();
end

filetype = filename( max( strfind(filename, '.' ) )+1:end );

    
toInt = @(x) javaObject('ome.xml.model.primitives.PositiveInteger', ...
                        javaObject('java.lang.Integer', x));

switch filetype
    case 'txt'
        metadata = parse_txt_cell( raw_meta, metadata );
    case 'oex'
        metadata = parse_oex_struct( raw_meta, metadata );
    otherwise
        error('unknown file extension specified')
end

end


function metadata = parse_txt_cell( filename, metadata )

reader = TIRF3MetaReader(filename);






    





end