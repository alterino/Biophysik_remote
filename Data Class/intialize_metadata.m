function metadata = intialize_metadata()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

OMEXMLService = javaObject('loci.formats.services.OMEXMLServiceImpl');
metadata = OMEXMLService.createOMEXMLMetadata();

metadata.setExperimenterGroupLeader('J.Piehler', 0, 0);
metadata.setExperimenterGroupName('Universitaet Osnabrueck Department of Biophysics', 0); 


end

